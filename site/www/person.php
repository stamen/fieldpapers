<?php
   /**
    * Individual page for a user
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
    
    $user_id = $_GET["id"];
    
    $user = get_user($dbh, $user_id);
    
    $sm = get_smarty_instance();
    
    $sm->assign('user_id', $user_id);
    
    if ($user['name'])
    {
        $sm->assign('user_name', $user['name']);
    } else {
        $sm->assign('user_name', 'Anonymous');
    }
    
    if ($user['email'])
    {
        $sm->assign('user_email', $user['email']);
    }
    
    // Get prints by id
    $prints = get_prints_by_user_id($dbh, $user_id);
    
    foreach($prints as $i => $print)
    {   
        $pages = get_print_pages($dbh, $print['id']);
        $prints[$i]['number_of_pages'] = count($pages);
        
        if ($print['place_name'])
        {
            $place_name = explode(',', $print['place_name']);
        
            $prints[$i]['city_name'] = $place_name[0];
        } else {
            $prints[$i]['city_name'] = 'Unknown City';
        }
    }
    
    $sm->assign('prints', $prints);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("person.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("person.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
