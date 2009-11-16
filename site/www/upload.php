<?php
   /**
    * Upload form for new scans.
    *
    * Each time this page is accessed a new scan is created and some old unfulfilled ones are culled.
    *
    * Requires global site API password, shows an HTML upload form.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $user = $user_id ? get_user($dbh, $user_id) : add_user($dbh);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $dbh->query('START TRANSACTION');
    $scan = add_scan($dbh, $user['id']);
    flush_scans($dbh, 3600);
    $dbh->query('COMMIT');

    $s3post = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? s3_get_post_details($scan['id'], time() + 600, '')
        : null;

    $localpost = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? null
        : local_get_post_details($scan['id'], time() + 600, '');

    $sm = get_smarty_instance();
    $sm->assign('s3post', $s3post);
    $sm->assign('localpost', $localpost);
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("upload.html.tpl");

?>
