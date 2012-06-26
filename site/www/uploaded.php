<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
    $url = $_GET['url'] ? $_GET['url'] : null;
    $scan_id = $_GET['scan'] ? $_GET['scan'] : null;
    $object_id = $_GET['key'] ? $_GET['key'] : null;
    $expected_etag = $_GET['etag'] ? $_GET['etag'] : null;

    if($scan_id)
        $scan = get_scan($context->db, $scan_id);

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

    if($acceptable_upload && $scan && !$scan['decoded'])
    {
        $context->db->query('START TRANSACTION');

        $message = array('action' => 'decode',
                         'scan_id' => $scan['id'],
                         'url' => $url);
        
        add_message($context->db, json_encode($message));
        
        $scan = get_scan($context->db, $scan['id']);
        $parsed_url = parse_url($url);
        $scan['base_url'] = "http://{$parsed_url['host']}".dirname($parsed_url['path']);
        $scan['progress'] = 0.1; // the first 10% is just getting the thing uploaded

        set_scan($context->db, $scan);
        
        $context->db->query('COMMIT');
    }

    if($attempted_upload)
        header('Location: http://'.get_domain_name().get_base_dir().'/snapshot.php?id='.urlencode($scan['id']));
    
    exit();
    
    //
    // Old form stuff down here.
    //
    
    if($attempted_upload)
        header('Location: http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.urlencode($scan['id']));
    
    $context->sm->assign('scan', $scan);
    $context->sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("uploaded.html.tpl");

?>
