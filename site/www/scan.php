<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $scan = get_scan($context->db, $scan_id);
    $context->sm->assign('scan', $scan);
    
    if($scan['print_id'] && $print = get_print($context->db, $scan['print_id']))
    {
        $context->sm->assign('print', $print);
    }
    
    $notes = get_scan_notes($context->db, array('scan' => $scan['id']));
    $context->sm->assign('notes', $notes);
    
    $form = get_form($context->db, $print['form_id']);
    $context->sm->assign('form', $form);
    
    if($user = get_user($context->db, $scan['user_id']))
    {
        $context->sm->assign('user', $user);
    }
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("scan.html.tpl");
    
    } elseif($context->type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("scan.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
