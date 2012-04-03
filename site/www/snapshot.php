<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $scan = get_scan($context->db, $scan_id);
    $context->sm->assign('scan', $scan);
        
    if ($scan['print_id'] && $scan['print_page_number'])
    {
        $print_id = $scan['print_id'];
        $print_page_number = $scan['print_page_number'];
    } elseif ($scan['print_href']) {
        $parsed_print_href = parse_url($scan['print_href']);
        parse_str($parsed_print_href['query'], $href_fragment);
        
        if(preg_match('#(\w+)\/(\w+)#', $href_fragment['id'], $m))
        {
            $print_id = $m[1];
            $print_page_number = $m[2];
        }
    }
        
    $context->sm->assign('print_id', $print_id);
    $context->sm->assign('print_page_number', $print_page_number);
    
    if($print_id && $print = get_print($context->db, $print_id))
    {
        $context->sm->assign('print', $print);
    }
    
    //Get the title of the print associated with the scan
    if ($print['title'])
    {
        $title = $print['title'];
    } else {
        $title = 'Untitled';
    }
    
    $context->sm->assign('title', $title);
    
    // Get the number of pages for the print
    $pages = get_print_pages($context->db, $print_id);
    $context->sm->assign('page_count', count($pages));
    
    $notes = get_scan_notes($context->db, array('scan' => $scan['id']));
    
    foreach($notes as $key=>$value)
    {
        $user = get_user($context->db,$notes[$key][user_id]);
        if ($user['name'])
        {
            $notes[$key]['user_name'] = $user['name'];
        } else {
            $notes[$key]['user_name'] = 'Anonymous';
        }
    }
        
    $context->sm->assign('notes', $notes);
    
    $form = get_form($context->db, $print['form_id']);
    $context->sm->assign('form', $form);
    
    if($user = get_user($context->db, $scan['user_id']))
    {
        $context->sm->assign('user', $user);
    }
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("snapshot.html.tpl");
    
    } elseif($context->type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("snapshot.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
