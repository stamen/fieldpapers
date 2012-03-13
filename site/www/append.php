<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_GET['password']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $scan_id = $_GET['scan'] ? $_GET['scan'] : null;
    $print_id = $_GET['print'] ? $_GET['print'] : null;
    $dirname = $_GET['dirname'] ? $_GET['dirname'] : null;
    $mimetype = $_GET['mimetype'] ? $_GET['mimetype'] : null;
        
    if($scan_id) {
        $scan = get_scan($context->db, $scan_id);
    
        $dirname = "scans/{$scan['id']}/".ltrim($dirname, '/');
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan['id']);

    } elseif($print_id) {
        $print = get_print($context->db, $print_id);
    
        $dirname = "prints/{$print['id']}/".ltrim($dirname, '/');
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?print='.rawurlencode($print['id']);
    }

    $s3post = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? s3_get_post_details(time() + 600, $dirname, $redirect, $mimetype)
        : null;

    $localpost = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? null
        : local_get_post_details(time() + 600, $dirname, $redirect);

    $context->sm = get_smarty_instance();
    $context->sm->assign('s3post', $s3post);
    $context->sm->assign('localpost', $localpost);
    $context->sm->assign('language', $language);
    $context->sm->assign('mimetype', $mimetype);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("append.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("append.xml.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
