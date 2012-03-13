<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $scan_args = array(
        'date' => preg_match('#^\d{4}-\d\d-\d\d$#', $_GET['date']) ? $_GET['date'] : null,
        'month' => preg_match('#^\d{4}-\d\d$#', $_GET['month']) ? $_GET['month'] : null,
        'place' => is_numeric($_GET['place']) ? $_GET['place'] : null,
        'user' => preg_match('/^\w+$/', $_GET['user']) ? $_GET['user'] : null
        );
    
    $scans = get_scans($context->db, $scan_args, 50);
    
    foreach($scans as $i => $scan)
    {   
        $user = get_user($context->db, $scans[$i]['user_id']);
        
        $scans[$i]['user_name'] = $user['name'] ? $user['name'] : 'Anonymous';
        $scans[$i]['city_name'] = $scan['place_name'] ? $scan['place_name'] : 'Unknown City';
    }
    
    $context->sm->assign('scans', $scans);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("uploads.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>