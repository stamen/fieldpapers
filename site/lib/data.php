<?php

    require_once 'JSON.php';
    require_once 'PEAR.php';
    require_once 'DB.php';
    require_once 'output.php';
    require_once 'FPDF/fpdf.php';
    require_once 'Crypt/HMAC.php';
    require_once 'HTTP/Request.php';
    require_once 'Net/URL.php';
    
    if(!function_exists('imagecreatefromstring'))
        die_with_code(500, "Missing function imagecreatefromstring from PHP image processing and GD library");
    
    // suppress PHP notices, they are annoying.
    error_reporting(error_reporting() & ~E_NOTICE);
    
    define('STEP_UPLOADING', 0);
    define('STEP_QUEUED', 1);
    define('STEP_SIFTING', 2);
    define('STEP_FINDING_NEEDLES', 3);
    define('STEP_READING_QR_CODE', 4);
    define('STEP_TILING_UPLOADING', 5);
    define('STEP_FINISHED', 6);
    define('STEP_BAD_QRCODE', 98);
    define('STEP_ERROR', 99);
    define('STEP_FATAL_ERROR', 100);
    define('STEP_FATAL_QRCODE_ERROR', 101);
    
    class Context
    {
        // Database connection
        var $db;

        // Smarty instance
        var $sm;
        
        // Logged-in user
        var $user;
        
        // Request content-type
        var $type;
        
        function Context(&$db_link, &$smarty, $user, $type)
        {
            $this->db =& $db_link;
            $this->sm =& $smarty;
            $this->user = $user;
            $this->type = $type;
        }
        
        function close()
        {
            $this->db->disconnect();
        }
    }
    
    function &get_db_connection()
    {
        $dbh =& DB::connect(DB_DSN);
        
        if(PEAR::isError($dbh)) 
            die_with_code(500, "{$dbh->message}\n{$q}\n");
        
        return $dbh;
    }
    
    function write_userdata($id, $language)
    {
        $userdata = array('user' => $id, 'language' => $language);
        $encoded_value = json_encode($userdata);
        $signed_string = $encoded_value.' '.md5($encoded_value.COOKIE_SIGNATURE);
        
        //error_log("signing string: {$signed_string}\n", 3, dirname(__FILE__).'/../tmp/log.txt');
        return $signed_string;
    }
    
   /**
    * Return userdata (user ID, language) based on a signed string and an accept-language string.
    * @param    string  $signed_string  JSON string, generally from a cookie, signed with an MD5 hash
    * @param    string  $accept_language_header Content of the HTTP Accept-Language request header, e.g. "en-us,en;q=0.5"
    * @return   string  Array with user ID and user language.
    */
    function read_userdata($signed_string, $accept_language_header)
    {
        $default_language = get_preferred_language($accept_language_header);
        
        if(preg_match('/^(\w{8})$/', $signed_string))
        {
            // looks like an old-style user ID cookie rather than a signed string
            //error_log("found plain username in: {$signed_string}\n", 3, dirname(__FILE__).'/../tmp/log.txt');
            return array($signed_string, $default_language);
        }
    
        if(preg_match('/^(.+) (\w{32})$/', $signed_string, $m))
        {
            list($encoded_value, $found_signature) = array($m[1], $m[2]);
            $expected_signature = md5($encoded_value.COOKIE_SIGNATURE);
            
            if($expected_signature == $found_signature)
            {
                // signature checks out
                //error_log("found encoded userdata in: {$signed_string}\n", 3, dirname(__FILE__).'/../tmp/log.txt');
                $userdata = json_decode($encoded_value, true);
                $language = empty($userdata['language']) ? $default_language : $userdata['language'];
                return array($userdata['user'], $language);
            }
        }

        //error_log("found no userdata in: {$signed_string}\n", 3, dirname(__FILE__).'/../tmp/log.txt');
        return array(null, $default_language);
    }

   /**
    * Get a useful type back from an Accept header.
    *
    * If the single argument is one of "html" or "xml", just return
    * what's appropriate without pretending it's a full header.
    */
    function get_preferred_type($accept_type_header, $acceptable_types=null)
    {
        $acceptable_types = is_array($acceptable_types)
            ? $acceptable_types
            : array('application/paperwalking+xml', 'application/json', 'application/geo+json', 'text/html', 'text/csv');
        
        if($accept_type_header == 'xml')
            return 'application/paperwalking+xml';
        
        if($accept_type_header == 'html')
            return 'text/html';
        
        if($accept_type_header == 'json')
            return 'application/json';
        
        if($accept_type_header == 'geojson')
            return 'application/geo+json';
        
        if($accept_type_header == 'csv')
            return 'text/csv';
        
        // break up string into pieces (types and q factors)
        preg_match_all('#([\*a-z]+/([\*\+a-z]+)?)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?#i', $accept_type_header, $type_parse);

        $types = array();
        
        if(count($type_parse[1]))
        {
            // create a list like "text/html" => 0.8
            $types = array_combine($type_parse[1], $type_parse[4]);
            
            // set default to 1 for any without q factor
            foreach($types as $l => $val)
                $types[$l] = ($val === '') ? 1 : $val;
            
            // sort list based on weight then by given order
            $weighted_order = array_values($types);
            $given_order = range(1, count($types));
            
            array_multisort($weighted_order, SORT_DESC, SORT_NUMERIC,
                            $given_order, SORT_ASC, SORT_NUMERIC,
                            $types);

        } else {
            $types = array();

        }

        foreach(array_keys($types) as $type)
        {
            if(in_array($type, $acceptable_types))
                return $type;
        }
        
        // HTML is the default
        return 'text/html';
    }
    
   /**
    * Adapted from http://www.thefutureoftheweb.com/blog/use-accept-language-header
    */
    function get_preferred_language($accept_language_header)
    {
        // break up string into pieces (languages and q factors)
        preg_match_all('/([a-z]{1,8}(-[a-z]{1,8})?)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?/i', $accept_language_header, $lang_parse);

        $languages = array();
        
        if(count($lang_parse[1]))
        {
            // create a list like "en" => 0.8
            $languages = array_combine($lang_parse[1], $lang_parse[4]);
            
            // set default to 1 for any without q factor
            foreach($languages as $l => $val)
                $languages[$l] = ($val === '') ? 1 : $val;
            
            // sort list based on value	
            arsort($languages, SORT_NUMERIC);

        } else {
            $languages = array();

        }
        
        foreach(array_keys($languages) as $language)
        {
            // any one of en-us, en-gb, etc.
            if(preg_match('/^en\b/', $language))
                return 'en';
        }
        
        // english is the default
        return 'en';
    }
    
   /**
    * Returns count, offset, per-page, page.
    */
    function get_pagination($input)
    {
        if(is_numeric($input))
            return array(intval($input), 0, intval($input), 1);
    
        if(!is_array($input))
            return array(10, 0, 10, 1);
        
        $count = intval(is_numeric($input['count']) ? $input['count'] : 32);
        $offset = intval(is_numeric($input['offset']) ? $input['offset'] : 0);
        $perpage = intval(is_numeric($input['perpage']) ? $input['perpage'] : 32);
        $page = intval(is_numeric($input['page']) ? $input['page'] : 1);
        
        if(is_numeric($input['offset'])) {
            $perpage = $count;
            $page = 1 + floor($offset / $count);
        
        } elseif(is_numeric($input['page'])) {
            $count = $perpage;
            $offset = ($page - 1) * $perpage;
        }
        
        return array(max(0, $count), max(0, $offset), max(0, $perpage), max(1, $page));
    }

    /**
     * Returns a pagination object to be used for setting display options
     * on the front end
     */
    function create_pagination_display_obj($pagination_results, $count, $filter_args=[]){
        $pagination_results['total'] = intval($count['count']);  
        $pagination_results['more'] = (($pagination_results['offset'] + $pagination_results['perpage']) < $pagination_results['total']) ? true : false;
        $pagination_results['total_fmt'] = number_format($count['count']);
        
        // create query string from any filter args passed in, ie. time, place...       
        $filter_query = '';
        foreach($filter_args as $arg => $val){
            if(isset($val) && !empty($val)){
                $filter_query .= '&' . $arg . "=" . $val;
            }
        }
 
        // set pagination links 
        if($pagination_results['more']){
            $pagination_results['next_link'] = get_base_href() . '?page=' . ($pagination_results['page'] + 1); 
            $pagination_results['next_link'] .= $filter_query;
        }
        if($pagination_results['page'] > 1){
            $pagination_results['prev_link'] = get_base_href() . '?page=' . ($pagination_results['page'] - 1);
            $pagination_results['prev_link'] .= $filter_query;
        }

        return $pagination_results;
    }
    
    function get_args_title(&$dbh, $args)
    {
        $parts = array();
    
        if(isset($args['date']) && $time = strtotime($args['date']))
        {
            $date = date('M jS, Y', $time);
            $parts[] = "on $date";
        }
        
        if(isset($args['month']) && $time = strtotime("{$args['month']}-01"))
        {
            $month = date('F Y', $time);
            $parts[] = "during $month";
        }
        
        if(isset($args['place']))
        {
            $place_info = woeid_placeinfo($args['place']);
            $place_name = nice_placename($place_info[4]);
            if (!$place_name) {
                $place_name = "(unknown)";
            }
            $parts[] = "in $place_name";
        }
        
        if(isset($args['user']) && $user = get_user($dbh, $args['user']))
        {
            $user_name = empty($user['name']) ? 'someone' : $user['name'];
            $parts[] = "by $user_name";
        }
        
        return join(' ', $parts);
    }
    
    if(!function_exists('json_encode'))
    {
        function json_encode($value)
        {
            $json = new Services_JSON(SERVICES_JSON_LOOSE_TYPE);
            return $json->encode($value);
        }
    }
    
    if(!function_exists('json_decode'))
    {
        function json_decode($value, $assoc=false)
        {
            $json = new Services_JSON($assoc ? SERVICES_JSON_LOOSE_TYPE : null);
            return $json->decode($value);
        }
    }
    
    function generate_id()
    {
        $chars = 'qwrtpsdfghklzxcvbnm23456789';
        $id = '';
        
        while(strlen($id) < 8)
            $id .= substr($chars, rand(0, strlen($chars) - 1), 1);

        return $id;
    }
    
    function table_columns(&$dbh, $table)
    {
        $q = 'DESCRIBE '.$dbh->escapeSimple($table);

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $columns = array();
        
        while($col = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $columns[$col['Field']] = $col['Type'];

        return $columns;
    }
    
    function add_log(&$dbh, $content)
    {
        $q = sprintf('INSERT INTO logs
                      SET content = %s',
                     $dbh->quoteSmart($content));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function delete_message(&$dbh, $message_id)
    {
        $q = sprintf('UPDATE messages
                      SET deleted = 1, available = NOW()
                      WHERE id = %d',
                     $message_id);

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function verify_s3_etag($object_id, $expected_etag)
    {
        $url = s3_signed_object_url($object_id, time() + 300, 'HEAD');
        
        $req = new HTTP_Request($url);
        $req->setMethod('HEAD');
        $res = $req->sendRequest();
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        if($req->getResponseCode() == 200)
            return $req->getResponseHeader('etag') == $expected_etag;

        return false;
    }
    
   /**
    * Get a base URL (incl. trailing slash) for the current file post service.
    */
    function get_post_baseurl($dirname)
    {
        return (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
            ? s3_get_post_baseurl($dirname)
            : local_get_post_baseurl($dirname);
    }
    
   /**
    * @param    $object_id      Name to assign
    * @param    $content_bytes  Content of file
    * @param    $mime_type      MIME/Type to assign
    * @return   mixed   URL of uploaded file on success, false or PEAR_Error on failure.
    */
    function post_file($object_id, $content_bytes, $mime_type)
    {
        return (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
            ? post_file_s3($object_id, $content_bytes, $mime_type)
            : post_file_local($object_id, $content_bytes);
    }
    
   /**
    * @param    $object_id      Name to assign
    * @param    $content_bytes  Content of file
    * @return   mixed   URL of uploaded file on success, false or PEAR_Error on failure.
    */
    function post_file_local($object_id, $content_bytes)
    {
        $filepath = realpath(dirname(__FILE__).'/../www/files');
        $pathbits = explode('/', $object_id);
        
        while(count($pathbits) && is_dir($filepath) && is_writeable($filepath))
        {
            $filepath .= '/'.array_shift($pathbits);

            if(count($pathbits) >= 1)
            {
                @mkdir($filepath);
                @chmod($filepath, 0777);
            }
        }
        
        $url = 'http://'.get_domain_name().get_base_dir().'/files/'.$object_id;
        
        if($fh = @fopen($filepath, 'w'))
        {
            fwrite($fh, $content_bytes);
            chmod($filepath, 0666);
            fclose($fh);
            
            return $url;
        }
        
        return false;
    }

   /**
    * @param    $object_id      Name to assign
    * @param    $content_bytes  Content of file
    * @param    $mime_type      MIME/Type to assign
    * @return   mixed   URL of uploaded file on success, false or PEAR_Error on failure.
    */
    function post_file_s3($object_id, $content_bytes, $mime_type)
    {
        $bucket_id = S3_BUCKET_ID;
        
        $content_md5_hex = md5($content_bytes);
        $date = date('D, d M Y H:i:s T');
        
        $content_md5 = '';
        
        for($i = 0; $i < strlen($content_md5_hex); $i += 2)
            $content_md5 .= chr(hexdec(substr($content_md5_hex, $i, 2)));

        $content_md5 = base64_encode($content_md5);
        
        $sign_string = "PUT\n{$content_md5}\n{$mime_type}\n{$date}\nx-amz-acl:public-read\n/{$bucket_id}/{$object_id}";
            
        //error_log("String to sign: {$sign_string}");
        
        $crypt_hmac = new Crypt_HMAC(AWS_SECRET_KEY, 'sha1');
        $hashed = $crypt_hmac->hash($sign_string);
        
        $signature = '';
        
        for($i = 0; $i < strlen($hashed); $i += 2)
            $signature .= chr(hexdec(substr($hashed, $i, 2)));
            
        $authorization = sprintf('AWS %s:%s', AWS_ACCESS_KEY, base64_encode($signature));
        
        //error_log("Authorization header: {$authorization}");
        
        $url = "http://{$bucket_id}.s3.amazonaws.com/{$object_id}";
        
        $req = new HTTP_Request($url);

        $req->setMethod('PUT');
        $req->addHeader('Date', $date);
        $req->addHeader('X-Amz-Acl', 'public-read');
        $req->addHeader('Content-Type', $mime_type);
        $req->addHeader('Content-MD5', $content_md5);
        $req->addHeader('Content-Length', strlen($content_bytes));
        $req->addHeader('Authorization', $authorization);
        $req->setBody($content_bytes);
        
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            return $res;
        
        if($req->getResponseCode() == 200)
            return $url;

        return false;
    }

   /**
    * Sign a string with the AWS secret key, return it raw.
    */
    function s3_sign_auth_string($string)
    {
        $crypt_hmac = new Crypt_HMAC(AWS_SECRET_KEY, 'sha1');
        $hashed = $crypt_hmac->hash($string);

        $signature = '';

        for($i = 0; $i < strlen($hashed); $i += 2)
            $signature .= chr(hexdec(substr($hashed, $i, 2)));

        return $signature;
    }
    
   /**
    * @param    int     $expires    Expiration timestamp
    * @param    string  $dirname    Input with a directory name
    * @return   array   Associative array with:
    *                   - "access": AWS access key
    *                   - "policy": base64-encoded policy
    *                   - "signature": base64-encoded, signed policy
    *                   - "acl": allowed ACL
    *                   - "key": upload key
    *                   - "bucket": bucket ID
    *                   - "redirect": URL
    */
    function s3_get_post_details($expires, $dirname, $redirect, $mimetype='')
    {
        $acl = 'public-read';
        $key = rtrim($dirname, '/')."/\${filename}"; // note the literal '$'
        $access = AWS_ACCESS_KEY;
        $bucket = S3_BUCKET_ID;
        
        $policy = array('expiration' => gmdate('Y-m-d', $expires).'T'.gmdate('H:i:s', $expires).'Z',
                        'conditions' => array(
                            array('bucket' => $bucket),
                            array('acl' => $acl),
                            array('starts-with', '$key', $dirname),
                            array('redirect' => $redirect)));

        if($mimetype)
            $policy['conditions'][] = array('starts-with', '$Content-Type', $mimetype);
        
        $policy = base64_encode(json_encode($policy));
        $signature = base64_encode(s3_sign_auth_string($policy));
        $base_url = s3_get_post_baseurl($dirname);

        return compact('access', 'policy', 'signature', 'acl', 'key', 'redirect', 'bucket', 'base_url');
    }
    
    function s3_get_post_baseurl($dirname)
    {
        $bucket = S3_BUCKET_ID;
        return "http://{$bucket}.s3.amazonaws.com/".trim($dirname, '/').'/';
    }
    
   /**
    * @param    string  object_id   S3 object ID
    * @param    int     $expires    Expiration timestamp
    * @param    string  $method     HTTP method, default GET
    * @return   string  Signed URL
    */
    function s3_signed_object_url($object_id, $expires, $method='GET')
    {
        $object_id_scrubbed = str_replace('+', '%20', str_replace('%2F', '/', rawurlencode($object_id)));
        $sign_string = s3_sign_auth_string(sprintf("%s\n\n\n%d\n/%s/%s", $method, $expires, S3_BUCKET_ID, $object_id_scrubbed));
        
        return sprintf('http://%s.s3.amazonaws.com/%s?Signature=%s&AWSAccessKeyId=%s&Expires=%d',
                       S3_BUCKET_ID,
                       $object_id_scrubbed,
                       urlencode(base64_encode($sign_string)),
                       urlencode(AWS_ACCESS_KEY),
                       urlencode($expires));
    }
    
   /**
    * @param    string  object_id   S3 object ID
    * @return   string  Signed URL
    */
    function s3_unsigned_object_url($object_id)
    {
        $object_id_scrubbed = str_replace('+', '%20', str_replace('%2F', '/', rawurlencode($object_id)));
        
        return sprintf('http://%s.s3.amazonaws.com/%s',
                       S3_BUCKET_ID,
                       $object_id_scrubbed);
    }

   /**
    * @param    int     $expires    Expiration timestamp
    * @param    string  $dirname    Input with a directory name
    * @return   array   Associative array with:
    *                   - "expiration": date when this post will expire
    *                   - "signature": md5 summed, signed string
    */
    function local_get_post_details($expires, $dirname, $redirect)
    {
        $expiration = gmdate("D, d M Y H:i:s", $expires).' UTC';
        $signature = sign_post_details($dirname, $expiration, API_PASSWORD);
        $base_url = local_get_post_baseurl($dirname);
        
        return compact('dirname', 'expiration', 'signature', 'redirect', 'base_url');
    }
    
    function local_get_post_baseurl($dirname)
    {
        return 'http://'.get_domain_name().get_base_dir().'/files/'.trim($dirname, '/').'/';
    }
    
    function sign_post_details($dirname, $expiration, $api_password)
    {
        return md5(join(' ', array($dirname, $expiration, $api_password)));
    }
    
    function placename_latlon($name)
    {
        $req = new HTTP_Request('http://where.yahooapis.com/v1/places.q(' . urlencode($name) . ');count=1');
        $req->addQueryString('select', 'long');
        $req->addQueryString('format', 'json');
        $req->addQueryString('appid', GEOPLANET_APPID);

        $res = $req->sendRequest();

        if(PEAR::isError($res))
            return null;

        if($req->getResponseCode() == 200)
        {
            $rsp = json_decode($req->getResponseBody(), true);
            
            if($rsp && $rsp['places'] && $rsp['places']['place'] && $rsp['places']['place'][0])
            {
                $centroid = $rsp['places']['place'][0]['centroid'];
                return array($centroid['latitude'], $centroid['longitude']);
            }
        }
        
        return null;
    }
        
    /**
    * @param    $name   Query string for GeoPlanet API
    * @return   array   Center latitude, center longitude, and place type code
    */
    function placename_latloncode($name)
    {
        $req = new HTTP_Request('http://where.yahooapis.com/v1/places.q(' . urlencode($name) . ');count=1');
        $req->addQueryString('select', 'long');
        $req->addQueryString('format', 'json');
        $req->addQueryString('appid', GEOPLANET_APPID);

        $res = $req->sendRequest();

        if(PEAR::isError($res))
            return null;

        if($req->getResponseCode() == 200)
        {
            $rsp = json_decode($req->getResponseBody(), true);
            
            if($rsp && $rsp['places'] && $rsp['places']['place'] && $rsp['places']['place'][0])
            {
                $centroid = $rsp['places']['place'][0]['centroid'];
                return array($centroid['latitude'], $centroid['longitude'], $rsp['places']['place'][0]['placeTypeName attrs']['code']);
            }
        }
        
        return null;
    }
    
    /**
    * @param    $name   Query string for Placefinder API
    * @return   array   Latitude, Longitude, zoom level
    */
    function placefinder_placename_latlonzoom($name)
    {        
        #Yahoo provides free, non-commercial geocoding up to 2,000 requests per day via YQL tables:
        #http://developer.yahoo.com/boss/geo/docs/free_YQL.html
        #http://developer.yahoo.com/yql/console/?q=select%20*%20from%20geo.placefinder%20where%20text%3D%22sfo%22#h=select%20*%20from%20geo.placefinder%20where%20text%3D%22eureka%22
        
        $req = new HTTP_Request("http://query.yahooapis.com/v1/public/yql");
        #NOTE: This is YQL, not SQL, so SQL injection not a worry!?
        $req->addQueryString("q","select * from geo.placefinder where text='$name'" );
        $req->addQueryString("format","json");
        #$req = new HTTP_Request('http://where.yahooapis.com/geocode?q=' . urlencode($name));
        #$req->addQueryString('count', '1');
        #$req->addQueryString('flags', 'J');
        
        #TODO: Use oAuth to enable future higher rate limits
        #https://github.com/yahoo/yos-social-php5
        #$req->addQueryString('appid', GEOPLANET_APPID);

        $res = $req->sendRequest();

        if(PEAR::isError($res)) {
            return null;
        }
        
        if($req->getResponseCode() == 200)
        {
            $rsp = json_decode($req->getResponseBody(), true);
            
            if($rsp && $rsp['query']['results'] && $rsp['query']['results']['Result'])
            {
                if ( $rsp['query']['results']['Result'][0] ) {
                    $res = $rsp['query']['results']['Result'][0];
                } else {
                    $res = $rsp['query']['results']['Result'];
                }
                
                if ($res['street'])
                {
                    $zoom = 14;
                } elseif ($res['city']) {
                    $zoom = 12;
                } elseif ($res['state']) {
                    $zoom = 8;
                } elseif ($res['country']) {
                    $zoom = 6;
                } else {
                    $zoom = 10;
                }
                
                return array($res['latitude'], $res['longitude'], $zoom);
            }
        }
        
        return null;
    }
    
    function woeid_placeinfo($woeid)
    {
        $req = new HTTP_Request('http://api.flickr.com/services/rest/');
        $req->addQueryString('method', 'flickr.places.getInfo');
        $req->addQueryString('woe_id', $woeid);
        $req->addQueryString('format', 'php_serial');
        $req->addQueryString('api_key', FLICKR_KEY);

        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            return array(null, null, null, null, null, null);

        $rsp = unserialize($req->getResponseBody());
        
        if(is_array($rsp) && is_array($rsp['place']))
        {
            $place_type = $rsp['place']['place_type'];
            $place = $rsp['place'][$place_type];
            
            list($place_name, $place_woeid) = array($place['_content'], $place['woeid']);
            
            list($country, $region) = array($rsp['place']['country'], $rsp['place']['region']);
            
            if(is_array($country))
                list($country_name, $country_woeid) = array($country['_content'], $country['woeid']);
            
            if(is_array($region))
                list($region_name, $region_woeid) = array($region['_content'], $region['woeid']);
        }
        
        return array($country_name, $country_woeid, $region_name, $region_woeid, $place_name, $place_woeid);
    }
    
    function latlon_placeinfo($lat, $lon, $zoom)
    {
        $req = new HTTP_Request('http://api.flickr.com/services/rest/');
        $req->addQueryString('method', 'flickr.places.findByLatLon');
        $req->addQueryString('lat', $lat);
        $req->addQueryString('lon', $lon);
        $req->addQueryString('accuracy', $zoom);
        $req->addQueryString('format', 'php_serial');
        $req->addQueryString('api_key', FLICKR_KEY);

        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            return '';

        if($req->getResponseCode() == 200)
        {
            $rsp = unserialize($req->getResponseBody());
            
            if(is_array($rsp['places']) && is_array($rsp['places']['place']))
            {
                $places = $rsp['places']['place'];
                
                if(is_array($places[0]) && $places[0]['name'])
                {
                    list($place_name, $place_woeid) = array($places[0]['name'], $places[0]['woeid']);
                    
                    $req = new HTTP_Request('http://api.flickr.com/services/rest/');
                    $req->addQueryString('method', 'flickr.places.getInfo');
                    $req->addQueryString('woe_id', $place_woeid);
                    $req->addQueryString('format', 'php_serial');
                    $req->addQueryString('api_key', FLICKR_KEY);
            
                    $res = $req->sendRequest();
                    
                    if(PEAR::isError($res))
                        return array(null, null, null, null, null, null);
            
                    $rsp = unserialize($req->getResponseBody());
                    
                    if(is_array($rsp) && is_array($rsp['place']))
                    {
                        list($country, $region) = array($rsp['place']['country'], $rsp['place']['region']);
                        
                        if(is_array($country))
                            list($country_name, $country_woeid) = array($country['_content'], $country['woeid']);
                        
                        if(is_array($region))
                            list($region_name, $region_woeid) = array($region['_content'], $region['woeid']);
                    }
                    
                    return array($country_name, $country_woeid, $region_name, $region_woeid, $place_name, $place_woeid);
                }
            }
        }
        
        return array(null, null, null, null, null, null);
    }
    
    function wkt_to_geometry($wkt)
    {
        switch(true)
        {
            case preg_match('/^POINT *\((\S+) (\S+)\)$/i', $wkt, $p):
                return array(
                    'type' => 'Point',
                    'coordinates' => array(floatval($p[1]), floatval($p[2]))
                );
            
            case preg_match('/^POLYGON *\(\((.+)\)\)$/i', $wkt, $m):
                preg_match_all('/(-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)/', $m[1], $p, PREG_SET_ORDER);
                
                $ring = array();
                
                foreach($p as $lonlat)
                    $ring[] = array(floatval($lonlat[1]), floatval($lonlat[2]));
                
                return array(
                    'type' => 'Polygon',
                    'coordinates' => array($ring)
                );
            
            default:
                return null;
        }
    }

    function log_debug() {
        $str = "";
        foreach (func_get_args() as $v) {
            $str .= $v . " ";
        }

        error_log(rtrim($str));
    }

?>
