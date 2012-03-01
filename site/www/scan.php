<?php
   /**
    * Individual page for the scan
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $sm = get_smarty_instance();
    
    $scan = get_scan($dbh, $scan_id);
    $sm->assign('scan', $scan);
    
    $print = get_print($dbh, $scan['print_id']);
    $sm->assign('print', $print);
    
    $notes = get_scan_notes($dbh, $scan_id);
    $sm->assign('notes', $notes);
    
    $form = get_form($dbh, $print['form_id']);
    $sm->assign('form', $form);
    
    if(preg_match('#^(\w+)/(\d+)$#', $scan['print_id'], $matches))
    {
        $print_id = $matches[1];
        $page_number = $matches[2];
        
        $sm->assign('page_number', $page_number);
    }
    
    $user = get_user($dbh, $scan['user_id']);
    
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
