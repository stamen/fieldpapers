<?php
   /**
    * Individual page for the print
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    
    $timestamp = $_GET["date"];
    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    $sm = get_smarty_instance();
    
    $date = getdate($timestamp);
    $sm->assign('date', $date);
    
    $prints = get_prints_by_month_year($dbh, $date);
    $sm->assign('prints', $prints);
    
    // Get print    
    //$print = get_print($dbh, $print_id);
    //$sm->assign('print', $print);
    
    // Get pages
    //$pages = get_print_pages($dbh, $print_id);
    //$sm->assign('pages', $pages);
    
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