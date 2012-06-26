<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);

    /**** ... ****/ 
    
    $context->db->query('START TRANSACTION');
    $scan = add_scan($context->db, $context->user['id']);
    flush_scans($context->db, 3600);
    $context->db->query('COMMIT');
    
    $dirname = "scans/{$scan['id']}";
    $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan['id']);

    $s3post = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? s3_get_post_details(time() + 600, $dirname, $redirect)
        : null;

    $localpost = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? null
        : local_get_post_details(time() + 600, $dirname, $redirect);

    $context->sm->assign('s3post', $s3post);
    $context->sm->assign('localpost', $localpost);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("upload.html.tpl");
?>
