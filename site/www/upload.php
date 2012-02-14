<?php
   /**
    * Upload form for new scans.
    *
    * Each time this page is accessed a new scan is created and some old unfulfilled ones are culled.
    *
    * Requires global site API password, shows an HTML upload form.
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/ 
    
    $user = cookied_user($dbh);
    
    $dbh->query('START TRANSACTION');
    $scan = add_scan($dbh, $user['id']);
    flush_scans($dbh, 3600);
    $dbh->query('COMMIT');
    
    $dirname = "scans/{$scan['id']}";
    $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan['id']);

    $s3post = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? s3_get_post_details(time() + 600, $dirname, $redirect)
        : null;

    $localpost = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? null
        : local_get_post_details(time() + 600, $dirname, $redirect);

    $sm = get_smarty_instance();
    $sm->assign('s3post', $s3post);
    $sm->assign('localpost', $localpost);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("upload.html.tpl");
?>
