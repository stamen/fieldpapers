<?php
   /**
    * Display page for a single print with a given ID.
    *
    * When this page receives a POST request, it's probably from compose.py
    * (check the API_PASSWORD) with new information on print components for
    * building into a new PDF.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';

    if($_SERVER['REQUEST_METHOD'] == 'POST')
        require_once 'composition.php';
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $print = get_print($dbh, $print_id);
    
    if($print && $_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        // we accept a subset of print properties here
        foreach(array('north', 'south', 'east', 'west', 'zoom', 'paper', 'last_step') as $field)
            if(isset($_POST[$field]))
                $print[$field] = $_POST[$field];
        
        add_log($dbh, "Posting additional details to print {$print['id']}");

        if($_POST['last_step'] == STEP_FINISHED)
        {
            add_log($dbh, "Composing PDF for print {$print['id']}");
            
            error_log('----------------------------------------------------------------'."\n", 3, '/home/migurski/public_html/paperwalking/compose.log');
            error_log($_POST['print_data_url']."\n", 3, '/home/migurski/public_html/paperwalking/compose.log');
            
            $data_req = new HTTP_Request($_POST['print_data_url']);
            $data_req->sendRequest();
            $data_arr = json_decode($data_req->getResponseBody(), true);

            $data_url = new Net_URL($_POST['print_data_url']);
            $data_dir = $data_url->protocol.'://'.$data_url->host.($data_url->port == 80 ? '' : ':'.$data_url->port).dirname($data_url->path);
            
            if($data_arr['preview'])
                $print['preview_url'] = "{$data_dir}/{$data_arr['preview']}";

            error_log(print_r($data_arr, 1), 3, '/home/migurski/public_html/paperwalking/compose.log');
            error_log(print_r($data_url, 1), 3, '/home/migurski/public_html/paperwalking/compose.log');
            
            foreach($data_arr['pages'] as $p => $page)
            {
                error_log($page['name']."\n", 3, '/home/migurski/public_html/paperwalking/compose.log');
                
                $url = "{$data_dir}/{$page['name']}";

                error_log($url."\n", 3, '/home/migurski/public_html/paperwalking/compose.log');
                
                $data_arr['pages'][$p]['href'] = $url;
            }

            /*
            $print_url = get_post_baseurl("prints/{$print['id']}/").'print.jpg';
            $print_req = new HTTP_Request($print_url);
            $print_req->sendRequest();
            $print_jpg = $print_req->getResponseBody();
            */
            $print = compose_map($print, $data_arr['pages']);

            error_log(print_r($print, 1), 3, '/home/migurski/public_html/paperwalking/compose.log');
        }
        
        $north = $print['north'];
        $south = $print['south'];
        $east = $print['east'];
        $west = $print['west'];
        $zoom = $print['zoom'];
        
        if(isset($north) && isset($south) && isset($east) && isset($west) && $zoom)
        {
            list($print['country_name'], $print['country_woeid'],
                 $print['region_name'], $print['region_woeid'],
                 $print['place_name'], $print['place_woeid'])
             = latlon_placeinfo(($north + $south) / 2, ($west + $east) / 2, $zoom - 1);
        }
        
        $dbh->query('START TRANSACTION');
        $print = set_print($dbh, $print);
        $dbh->query('COMMIT');
    }
    
    $sm = get_smarty_instance();
    $sm->assign('print', $print);
    $sm->assign('language', $language);
    
    print_headers($print);

    $type = $_GET['type'] ? $_GET['type'] : 'html'; //$_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("print.html.tpl");
    
    } elseif($type == 'application/xml') { 
        header("Content-Type: application/xml; charset=UTF-8");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("print.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
