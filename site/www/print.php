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
    
    $sm = get_smarty_instance();
    
    $print = get_print($dbh,$print_id);
    
    $sm->assign('print', $print);
    
        
    if ($print['selected_page'])
    {
        $pages = array($print['selected_page']);
    } else {
        $pages = get_print_pages($dbh, $print_id);
    }
    
    $sm->assign('pages', $pages);
    
    $user = get_user($dbh, $print['user_id']);
    if ($user['name'])
    {
        $sm->assign('user_name', $user['name']);
    } else {
        $sm->assign('user_name', 'Anonymous');
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
