<?php
   /**
    * Individual page for the print
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    require_once 'lib.scans.php';
    
    $scan_id = $_GET["id"];

    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    $sm = get_smarty_instance();
    
    $scan = get_scan($dbh, $scan_id);
    $sm->assign('scan', $scan);
    
    $notes = get_scan_notes($dbh, $scan_id);
    $sm->assign('notes', $notes);
    
    // Needed?
    $user_id = $_SESSION['user']['id'];
    $sm->assign('user_id', $user_id);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("scan.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("scan.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
