<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    $print = get_print($context->db, $print_id);
    $pages = get_print_pages($context->db, $print_id);
    $print['page_count'] = count($pages);
    
    $context->sm->assign('print', $print);
    
    if($print['selected_page']) {
        $context->sm->assign('pages', array($print['selected_page']));

    } else {
        $context->sm->assign('pages', $pages);
    }
    
    if($user = get_user($context->db, $print['user_id']))
    {
        $context->sm->assign('user', $user);
    }
    
    $context->sm->assign('activity', get_print_activity($context->db, $print_id));
    $context->sm->assign('providers', get_map_providers());
        
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("print.html.tpl");
    
    } elseif($context->type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("print.xml.tpl");
    
    } elseif($context->type == 'application/geo+json' || $context->type == 'application/json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        echo print_to_geojson($print, $pages)."\n";

    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
