<?php

    require_once 'JSON.php';
    require_once 'PEAR.php';
    require_once 'DB.php';
    require_once 'output.php';
    require_once 'FPDF/fpdf.php';
    require_once 'Crypt/HMAC.php';
    require_once 'HTTP/Request.php';
    require_once 'Net/URL.php';
    
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

    function &get_db_connection()
    {
        return DB::connect(DB_DSN);
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
        }
        
        foreach(array_keys($languages) as $language)
        {
            // any one of en-us, en-gb, etc.
            if(preg_match('/^en\b/', $language))
                return 'en';

            // any one of de, de-ch, etc.
            if(preg_match('/^de\b/', $language))
                return 'de';

            // nl or nl-be
            if(preg_match('/^nl\b/', $language))
                return 'nl';
        }
        
        // english is the default
        return 'en';
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
    
    function add_print(&$dbh, $user_id)
    {
        while(true)
        {
            $print_id = generate_id();
            
            $q = sprintf('INSERT INTO prints
                          SET id = %s, user_id = %s',
                         $dbh->quoteSmart($print_id),
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_print($dbh, $print_id);
        }
    }
    
    function add_scan(&$dbh, $user_id)
    {
        while(true)
        {
            $scan_id = generate_id();
            
            $q = sprintf('INSERT INTO scans
                          SET id = %s, user_id = %s',
                         $dbh->quoteSmart($scan_id),
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            add_step($dbh, $scan_id, 0);
            
            return get_scan($dbh, $scan_id);
        }
    }
    
    function add_user(&$dbh)
    {
        while(true)
        {
            $user_id = generate_id();
            
            $q = sprintf('INSERT INTO users
                          SET id = %s',
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_user($dbh, $user_id);
        }
    }
    
    function add_step(&$dbh, $scan_id, $number)
    {
        $q = sprintf('INSERT INTO steps
                      SET scan_id = %s, number = %d',
                     $dbh->quoteSmart($scan_id),
                     $number);

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                return false;

            die_with_code(500, "{$res->message}\n{$q}\n");
        }

        $q = sprintf('UPDATE scans
                      SET last_step = %s
                      WHERE id = %s',
                     $number,
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function add_message(&$dbh, $content)
    {
        $q = sprintf('INSERT INTO messages
                      SET content = %s, available = NOW()',
                     $dbh->quoteSmart($content));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function get_prints(&$dbh, $count)
    {
        // TODO: ditch dependency on table_columns()
        $column_names = array_keys(table_columns($dbh, 'prints'));
        
        $woeid_column_names = in_array('place_woeid', $column_names)
            ? 'country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,'
            : '';
        
        $zoom_column_name = in_array('zoom', $column_names)
            ? 'zoom,'
            : '';
        
        $q = sprintf("SELECT {$woeid_column_names}
                             {$zoom_column_name}
                             id, north, south, east, west,
                             (north + south) / 2 AS latitude,
                             (east + west) / 2 AS longitude,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM prints
                      ORDER BY created DESC
                      LIMIT %d",
                      $count);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
        {
            $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $row['id'], $row['id']);
            $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $row['id']);

            $rows[] = $row;
        }
        
        return $rows;
    }
    
    function get_print(&$dbh, $print_id)
    {
        // TODO: ditch dependency on table_columns()
        $column_names = array_keys(table_columns($dbh, 'prints'));
        
        $orientation_column_name = in_array('orientation', $column_names)
            ? 'orientation,'
            : '';
        
        $q = sprintf("SELECT {$orientation_column_name}
                             id, north, south, east, west, zoom,
                             (north + south) / 2 AS latitude,
                             (east + west) / 2 AS longitude,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,
                             user_id
                      FROM prints
                      WHERE id = %s",
                     $dbh->quoteSmart($print_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $print_id, $print_id);
        $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $print_id);
        
        return $row;
    }
    
    function get_scans(&$dbh, $count, $include_private=false)
    {
        // TODO: ditch dependency on table_columns()
        $column_names = array_keys(table_columns($dbh, 'prints'));
        
        $woeid_column_names = in_array('place_woeid', $column_names)
            ? 'p.place_name AS print_place_name, p.place_woeid AS print_place_woeid,'
            : '';
        
        $q = sprintf("SELECT {$woeid_column_names}
                             s.id, s.print_id, s.last_step,
                             s.min_row, s.min_column, s.min_zoom,
                             s.max_row, s.max_column, s.max_zoom,
                             s.description, s.is_private, s.will_edit,
                             (p.north + p.south) / 2 AS print_latitude,
                             (p.east + p.west) / 2 AS print_longitude,
                             UNIX_TIMESTAMP(s.created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(s.created) AS age,
                             s.user_id
                      FROM scans AS s
                      LEFT JOIN prints AS p
                        ON p.id = s.print_id
                      WHERE s.last_step = %d
                        AND %s
                      ORDER BY s.created DESC
                      LIMIT %d",
                     STEP_FINISHED,
                     ($include_private ? '1' : "s.is_private='no'"),
                     $count);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $rows[] = $row;
        
        return $rows;
    }
    
    function get_scan(&$dbh, $scan_id)
    {
        $q = sprintf('SELECT id, print_id, last_step,
                             min_row, min_column, min_zoom,
                             max_row, max_column, max_zoom,
                             description, is_private, will_edit,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM scans
                      WHERE id = %s',
                     $dbh->quoteSmart($scan_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    
    function get_user(&$dbh, $user_id)
    {
        $q = sprintf('SELECT id, name,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age
                      FROM users
                      WHERE id = %s',
                     $dbh->quoteSmart($user_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    
    function get_step_description($number)
    {
        switch($number)
        {
            case STEP_UPLOADING:
                return 'Preparing for upload';

            case STEP_QUEUED:
                return 'Queued for processing';

            case STEP_SIFTING:
                return 'Sifting';

            case STEP_FINDING_NEEDLES:
                return 'Finding needles';

            case STEP_READING_QR_CODE:
                return 'Reading QR code';

            case STEP_TILING_UPLOADING:
                return 'Tiling and uploading';

            case STEP_FINISHED:
                return 'Finished';

            case STEP_BAD_QRCODE:
                return 'We could not read the QR code';

            case STEP_ERROR:
                return 'A temporary error has occured';

            case STEP_FATAL_QRCODE_ERROR:
                return 'We could not read the QR code';

            case STEP_FATAL_ERROR:
                return 'A permanent error has occured';
        }

        return new PEAR_Error('dunno');
    }
    
    function get_step(&$dbh, $scan_id, $number=false)
    {
        if(is_numeric($number)) {
            $q = sprintf('SELECT *
                          FROM steps
                          WHERE scan_id = %s
                            AND number = %d',
                         $dbh->quoteSmart($scan_id),
                         $number);

        } else {
            $q = sprintf('SELECT *
                          FROM steps
                          WHERE scan_id = %s
                          ORDER BY created DESC
                          LIMIT 1',
                         $dbh->quoteSmart($scan_id));
        }
                     
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    
    function get_steps(&$dbh, $scan_id, $limit=100)
    {
        $q = sprintf('SELECT scan_id, number,
                             user_id, created
                      FROM steps
                      WHERE scan_id = %s
                      ORDER BY created DESC
                      LIMIT %d',
                     $dbh->quoteSmart($scan_id),
                     $limit);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $steps = array();
        
        while($step = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $steps[] = $step;

        return $steps;
    }
    
    function get_message(&$dbh, $timeout)
    {
        $res = $dbh->query('LOCK TABLES messages WRITE');
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $q = sprintf('SELECT id, content
                      FROM messages
                      WHERE available < NOW()
                        AND deleted = 0
                      ORDER BY available ASC
                      LIMIT 1');

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        if($msg = $res->fetchRow(DB_FETCHMODE_ASSOC)) {
            postpone_message($dbh, $msg['id'], $timeout);

        } else {
            $msg = false;
        }

        $res = $dbh->query('UNLOCK TABLES');
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        return $msg;
    }
    
    function set_print(&$dbh, $print)
    {
        $old_print = get_print($dbh, $print['id']);
        
        if(!$old_print)
            return false;

        $update_clauses = array();
        $column_names = array_keys(table_columns($dbh, 'prints'));

        // TODO: ditch dependency on table_columns()
        foreach(array('north', 'south', 'east', 'west', 'zoom', 'orientation', 'user_id', 'country_name', 'country_woeid', 'region_name', 'region_woeid', 'place_name', 'place_woeid') as $field)
            if(in_array($field, $column_names) && !is_null($print[$field]))
                if($print[$field] != $old_print[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($print[$field]));

        if(empty($update_clauses)) {
            error_log("skipping print {$print['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf("UPDATE prints
                          SET {$update_clauses}
                          WHERE id = %s",
                         $dbh->quoteSmart($print['id']));
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_print($dbh, $print['id']);
    }
    
    function set_scan(&$dbh, $scan)
    {
        $old_scan = get_scan($dbh, $scan['id']);
        
        if(!$old_scan)
            return false;

        $update_clauses = array();

        foreach(array('print_id', 'last_step', 'user_id', 'min_row', 'min_column', 'min_zoom', 'max_row', 'max_column', 'max_zoom', 'description', 'is_private', 'will_edit') as $field)
            if(!is_null($scan[$field]))
                if($scan[$field] != $old_scan[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($scan[$field]));

        if(empty($update_clauses)) {
            error_log("skipping scan {$scan['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf("UPDATE scans
                          SET {$update_clauses}
                          WHERE id = %s",
                         $dbh->quoteSmart($scan['id']));
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_scan($dbh, $scan['id']);
    }
    
    function postpone_message(&$dbh, $message_id, $timeout)
    {
        $q = sprintf('UPDATE messages
                      SET available = NOW() + INTERVAL %d SECOND
                      WHERE id = %d',
                     $timeout,
                     $message_id);

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
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
    * @param    $object_id      Name to assigned
    * @param    $content_bytes  Content of file
    * @param    $mime_type      MIME/Type to assign
    * @return   mixed   URL of uploaded file on success, false or PEAR_Error on failure.
    */
    function s3_post_file($object_id, $content_bytes, $mime_type)
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
    * @param    string  $format     Response format for redirect URL
    * @return   array   Associative array with:
    *                   - "access": AWS access key
    *                   - "policy": base64-encoded policy
    *                   - "signature": base64-encoded, signed policy
    *                   - "acl": allowed ACL
    *                   - "key": upload key
    *                   - "bucket": bucket ID
    *                   - "redirect": URL
    */
    function s3_get_post_details($scan_id, $expires, $format=null)
    {
        $acl = 'public-read';
        $key = "scans/{$scan_id}/\${filename}";
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan_id).(is_null($format) ? '' : "&format={$format}");
        $access = AWS_ACCESS_KEY;
        $bucket = S3_BUCKET_ID;
        
        $policy = array('expiration' => gmdate('Y-m-d', $expires).'T'.gmdate('H:i:s', $expires).'Z',
                        'conditions' => array(
                            array('bucket' => $bucket),
                            array('acl' => $acl),
                            array('starts-with', '$key', "scans/{$scan_id}/"),
                            array('redirect' => $redirect)));

        $policy = base64_encode(json_encode($policy));
        $signature = base64_encode(s3_sign_auth_string($policy));

        return compact('access', 'policy', 'signature', 'acl', 'key', 'redirect', 'bucket');
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
    
?>
