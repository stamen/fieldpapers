<?php
   /**
    * POST endpoint for attaching new files to a scan, e.g. tiles.
    *
    * Requires global site API password and a scan ID, shows an HTML upload form.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    if($_GET['password'] != API_PASSWORD)
        die_with_code(401, 'Sorry, bad password');
    
    $scan_id = $_GET['scan'] ? $_GET['scan'] : null;
    $print_id = $_GET['print'] ? $_GET['print'] : null;
    $dirname = $_GET['dirname'] ? $_GET['dirname'] : null;
    $mimetype = $_GET['mimetype'] ? $_GET['mimetype'] : null;
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    /*
    $user = $user_id ? get_user($dbh, $user_id) : add_user($dbh);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
        */
    
    if($scan_id) {
        $scan = get_scan($dbh, $scan_id);
    
        $dirname = "scans/{$scan['id']}/".ltrim($dirname, '/');
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan['id']);

    } elseif($print_id) {
        $print = get_print($dbh, $print_id);
    
        $dirname = "prints/{$print['id']}/".ltrim($dirname, '/');
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?print='.rawurlencode($print['id']);
    }

    $s3post = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? s3_get_post_details(time() + 600, $dirname, $redirect, $mimetype)
        : null;

    $localpost = (AWS_ACCESS_KEY && AWS_SECRET_KEY && S3_BUCKET_ID)
        ? null
        : local_get_post_details(time() + 600, $dirname, $redirect);

    $sm = get_smarty_instance();
    $sm->assign('s3post', $s3post);
    $sm->assign('localpost', $localpost);
    $sm->assign('language', $language);
    $sm->assign('mimetype', $mimetype);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("append.html.tpl");

?>
