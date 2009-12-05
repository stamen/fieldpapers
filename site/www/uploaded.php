<?php
   /**
    * Post-upload page, with an interstitial information-gathering
    * form after a scan image has been successfully uploaded.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'Net/URL.php';
    
    $url = $_GET['url'] ? $_GET['url'] : null;
    $scan_id = $_GET['scan'] ? $_GET['scan'] : null;
    $object_id = $_GET['key'] ? $_GET['key'] : null;
    $expected_etag = $_GET['etag'] ? $_GET['etag'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    if($scan_id)
        $scan = get_scan($dbh, $scan_id);

    if($scan && $object_id && $expected_etag)
    {
        $url = s3_unsigned_object_url($object_id, time() + 300, 'HEAD');
        $etag_match = verify_s3_etag($object_id, $expected_etag);
        
        $attempted_upload = true;
        $acceptable_upload = $etag_match;
        
    } elseif($scan && $url) {
        // it's probably fine if a whole URL is being sent over
        $attempted_upload = true;
        $acceptable_upload = preg_match('#^http://#', $url);
    }
    
    if($attempted_upload && !$acceptable_upload)
        die_with_code(400, 'Sorry, something about your file was bad');

    if($acceptable_upload && $scan && $scan['last_step'] <= 1)
    {
        $dbh->query('START TRANSACTION');

        $added = add_step($dbh, $scan['id'], 1);
        
        if($added)
            add_message($dbh, $url);
        
        $scan = get_scan($dbh, $scan['id']);
        $parsed_url = parse_url($url);
        $scan['base_url'] = "http://{$parsed_url['host']}".dirname($parsed_url['path']);
        set_scan($dbh, $scan);
        
        $dbh->query('COMMIT');
        
        //header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan['id']));
        //exit();
    }

    if($attempted_upload)
        header('Location: http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.urlencode($scan['id']));
    
    $sm = get_smarty_instance();
    $sm->assign('scan', $scan);
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("uploaded.html.tpl");

?>
