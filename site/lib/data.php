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
    function get_preferred_type($accept_type_header)
    {
        if($accept_type_header == 'xml')
            return 'application/xml';
        
        if($accept_type_header == 'html')
            return 'text/html';
        
        // break up string into pieces (types and q factors)
        preg_match_all('#([\*a-z]+/([\*a-z]+)?)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?#i', $accept_type_header, $type_parse);

        $types = array();
        
        if(count($type_parse[1]))
        {
            // create a list like "text/html" => 0.8
            $types = array_combine($type_parse[1], $type_parse[4]);
            
            // set default to 1 for any without q factor
            foreach($types as $l => $val)
                $types[$l] = ($val === '') ? 1 : $val;
            
            // sort list based on value	
            arsort($types, SORT_NUMERIC);

        } else {
            $types = array();

        }
        
        foreach(array_keys($types) as $type)
        {
            // XML generally?
            if(preg_match('#^(text|application)/xml$#', $type))
                return 'application/xml';
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

            // any one of de, de-ch, etc.
            if(preg_match('/^de\b/', $language))
                return 'de';

            // nl or nl-be
            if(preg_match('/^nl\b/', $language))
                return 'nl';

            // es...
            if(preg_match('/^es\b/', $language))
                return 'es';

            // fr or fr-
            if(preg_match('/^fr\b/', $language))
                return 'fr';
            
            // ja or ja-
            if(preg_match('/^ja\b/', $language))
            return 'ja';
            
            // it or it-
            if(preg_match('/^it\b/', $language))
            return 'it';
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
        
        $papersize_column_name = in_array('paper_size', $column_names)
            ? 'paper_size,'
            : '';
        
        $orientation_column_name = in_array('orientation', $column_names)
            ? 'orientation,'
            : '';
        
        $provider_column_name = in_array('provider', $column_names)
            ? 'provider,'
            : '';
        
        $url_column_names = (in_array('pdf_url', $column_names) && in_array('preview_url', $column_names))
            ? 'pdf_url, preview_url,'
            : '';
        
        $q = sprintf("SELECT {$papersize_column_name}
                             {$orientation_column_name}
                             {$provider_column_name}
                             {$url_column_names}
                             id, north, south, east, west, zoom,
                             (north + south) / 2 AS latitude,
                             (east + west) / 2 AS longitude,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,
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
            // TODO: ditch special-case for provider
            if(empty($row['provider']))
                $row['provider'] = sprintf('http://tile.cloudmade.com/%s/2/256/{Z}/{X}/{Y}.png', CLOUDMADE_KEY);

            // TODO: ditch special-case for pdf_url
            if(empty($row['pdf_url']) && S3_BUCKET_ID)
                $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $row['id'], $row['id']);

            // TODO: ditch special-case for preview_url
            if(empty($row['preview_url']) && S3_BUCKET_ID)
                $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $row['id']);

            $rows[] = $row;
        }
        
        return $rows;
    }
    
    function get_print(&$dbh, $print_id)
    {
        // TODO: ditch dependency on table_columns()
        $column_names = array_keys(table_columns($dbh, 'prints'));
        
        $papersize_column_name = in_array('paper_size', $column_names)
            ? 'paper_size,'
            : '';
        
        $orientation_column_name = in_array('orientation', $column_names)
            ? 'orientation,'
            : '';
        
        $provider_column_name = in_array('provider', $column_names)
            ? 'provider,'
            : '';
        
        $url_column_names = (in_array('pdf_url', $column_names) && in_array('preview_url', $column_names))
            ? 'pdf_url, preview_url,'
            : '';
        
        $q = sprintf("SELECT {$papersize_column_name}
                             {$orientation_column_name}
                             {$provider_column_name}
                             {$url_column_names}
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
        
        // TODO: ditch special-case for provider
        if(empty($row['provider']))
            $row['provider'] = sprintf('http://tile.cloudmade.com/%s/2/256/{Z}/{X}/{Y}.png', CLOUDMADE_KEY);

        // TODO: ditch special-case for pdf_url
        if(empty($row['pdf_url']) && S3_BUCKET_ID)
            $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $row['id'], $row['id']);

        // TODO: ditch special-case for preview_url
        if(empty($row['preview_url']) && S3_BUCKET_ID)
            $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $row['id']);
        
        return $row;
    }
    
    function get_scans(&$dbh, $count, $include_private=false)
    {
        // TODO: ditch dependency on table_columns()
        $column_names = array_keys(table_columns($dbh, 'prints'));
        
        $woeid_column_names = in_array('place_woeid', $column_names)
            ? 'p.place_name AS print_place_name, p.place_woeid AS print_place_woeid,'
            : '';
        
        $base_url = in_array('base_url', $column_names)
            ? 's.base_url,'
            : '';
        
        $q = sprintf("SELECT {$woeid_column_names}
                             s.id, s.print_id, s.last_step,
                             s.min_row, s.min_column, s.min_zoom,
                             s.max_row, s.max_column, s.max_zoom,
                             s.description, s.is_private, s.will_edit, {$base_url}
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
        {
            // TODO: ditch special-case for base_url
            if(empty($row['base_url']))
                $row['base_url'] = sprintf('http://%s.s3.amazonaws.com/scans/%s', S3_BUCKET_ID, $row['id']);
            
            $rows[] = $row;
        }
        
        return $rows;
    }
    
    function get_scan(&$dbh, $scan_id)
    {
        // TODO: ditch dependency on table_columns()
        $column_names = array_keys(table_columns($dbh, 'scans'));
        
        $base_url = in_array('base_url', $column_names)
            ? 'base_url,'
            : '';
        
        $q = sprintf("SELECT id, print_id, last_step,
                             min_row, min_column, min_zoom,
                             max_row, max_column, max_zoom,
                             description, is_private, will_edit, {$base_url}
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM scans
                      WHERE id = %s",
                     $dbh->quoteSmart($scan_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $scan = $res->fetchRow(DB_FETCHMODE_ASSOC);

        // TODO: ditch special-case for base_url
        if(empty($scan['base_url']))
            $scan['base_url'] = sprintf('http://%s.s3.amazonaws.com/scans/%s', S3_BUCKET_ID, $scan['id']);
        
        return $scan;
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
        // TODO: ditch special-case for provider
        foreach(array('north', 'south', 'east', 'west', 'zoom', 'paper_size', 'orientation', 'provider', 'pdf_url', 'preview_url', 'user_id', 'country_name', 'country_woeid', 'region_name', 'region_woeid', 'place_name', 'place_woeid') as $field)
            if(in_array($field, $column_names) && !is_null($print[$field]))
                if($print[$field] != $old_print[$field] || in_array($field, array('provider')))
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($print[$field]));

        if(empty($update_clauses)) {
            error_log("skipping print {$print['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = "UPDATE prints
                  SET {$update_clauses}
                  WHERE id = ".$dbh->quoteSmart($print['id']);
    
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
        $column_names = array_keys(table_columns($dbh, 'scans'));

        // TODO: ditch dependency on table_columns()
        // TODO: ditch special-case for base_url
        foreach(array('print_id', 'last_step', 'user_id', 'min_row', 'min_column', 'min_zoom', 'max_row', 'max_column', 'max_zoom', 'description', 'is_private', 'will_edit', 'base_url') as $field)
            if(in_array($field, $column_names) && !is_null($scan[$field]))
                if($scan[$field] != $old_scan[$field] || in_array($field, array('base_url')))
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($scan[$field]));

        if(empty($update_clauses)) {
            error_log("skipping scan {$scan['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = "UPDATE scans
                  SET {$update_clauses}
                  WHERE id = ".$dbh->quoteSmart($scan['id']);
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_scan($dbh, $scan['id']);
    }
    
    function delete_scan(&$dbh, $scan_id)
    {
        $q = sprintf('DELETE FROM scans
                      WHERE id = %s',
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $q = sprintf('DELETE FROM steps
                      WHERE scan_id = %s',
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function flush_scans(&$dbh, $age)
    {
        $due = time() + 5;
        
        while(time() < $due)
        {
            $q = sprintf('SELECT id
                          FROM scans
                          WHERE last_step = 0
                            AND created < NOW() - INTERVAL %d SECOND
                          LIMIT 1',
                         $age);
    
            //error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
                die_with_code(500, "{$res->message}\n{$q}\n");
    
            $scan = $res->fetchRow(DB_FETCHMODE_ASSOC);
            
            if(empty($scan))
                break;

            delete_scan($dbh, $scan['id']);
        }

        return true;
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
    function s3_get_post_details($scan_id, $expires, $dirname)
    {
        $acl = 'public-read';
        $key = rtrim("scans/{$scan_id}", '/').'/'.ltrim($dirname."/\${filename}", '/');
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan_id);
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

   /**
    * @param    int     $expires    Expiration timestamp
    * @param    string  $dirname    Input with a directory name
    * @return   array   Associative array with:
    *                   - "expiration": date when this post will expire
    *                   - "signature": md5 summed, signed string
    */
    function local_get_post_details($scan_id, $expires, $dirname)
    {
        $dirname = rtrim("scans/{$scan_id}", '/').'/'.ltrim($dirname, '/');
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan_id);

        $expiration = gmdate("D, d M Y H:i:s", $expires).' UTC';
        $signature = sign_post_details($dirname, $expiration, API_PASSWORD);
        
        return compact('dirname', 'expiration', 'signature', 'redirect');
    }
    
    function sign_post_details($dirname, $expiration, $api_password)
    {
        return md5(join(' ', array($dirname, $expiration, $api_password)));
    }
    
?>
