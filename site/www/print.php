<?php
   /**
    * Individual page for the print
    */
    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $print_id = $_GET['id'] ? $_GET['id'] : null; 
    
    if(preg_match('#^([0-9a-zA-Z]+)+/(\d+)$#', $print_id, $matches))
    {
        $print_id = $matches[1];
        $page_number = $matches[2];
    }
    
    if ($print_id && $page_number)
    {
        $sm = get_smarty_instance();
        $sm->assign('flickr_key', FLICKR_KEY);
        
        $print = get_print($dbh, $print_id);
        $sm->assign('print', $print);
        $sm->assign('place_id', $print['place_woeid']); 
        
        $zoom = 8; //Zoom should be in the database
        
        $place = latlon_placeinfo($print['north'], $print['west'], $zoom);
        $sm->assign('place', $place);
        
        $user = get_user($dbh, $print['user_id']);
        
        if ($user['name'])
        {
            $sm->assign('user_name', $user['name']);
        } else {
            $sm->assign('user_name', 'Anonymous');
        }
        
        $page = get_print_page($dbh, $print_id, $page_number);
        $sm->assign('page',$page);
        
        // For GeoJSON output
        $pages = array($page);
    } else if ($print_id) {
        $sm = get_smarty_instance();
        $sm->assign('flickr_key', FLICKR_KEY);
                   
        $print = get_print($dbh, $print_id);
        $sm->assign('print', $print);
        $sm->assign('place_id', $print['place_woeid']);
        
        $zoom = 8; //Zoom should be in the database
        
        $place = latlon_placeinfo($print['north'], $print['west'], $zoom);
        $sm->assign('place', $place);
        
        $user = get_user($dbh, $print['user_id']);
        
        if ($user['name'])
        {
            $sm->assign('user_name', $user['name']);
        } else {
            $sm->assign('user_name', 'Anonymous');
        }
        
        $pages = get_print_pages($dbh, $print_id);
        $sm->assign('pages', $pages);
    }
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("print.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("print.xml.tpl");
    
    } elseif($type == 'application/geo+json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        echo print_to_geojson($print, $pages)."\n";
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
