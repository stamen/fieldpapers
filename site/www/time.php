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
    
    $timestamp = $_GET['date'] ? $_GET['date'] : null;

    $sm = get_smarty_instance();
    
    $date = getdate($timestamp);
    $sm->assign('date', $date);
    
    $prints = get_prints_by_month_year($dbh, $date);
    
    foreach($prints as $i => $print)
    {   
        $pages = get_print_pages($dbh, $print['id']);
        $prints[$i]['number_of_pages'] = count($pages);
        
        $user = get_user($dbh, $prints[$i]['user_id']);
        
        if ($user['name'])
        {
            $prints[$i]['user_name'] = $user['name'];
        } else {
            $prints[$i]['user_name'] = 'Anonymous';
        }
        
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
        print $sm->fetch("time.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("time.xml.tpl"); // ?
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>