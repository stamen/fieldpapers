<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);

    /**** ... ****/
    
    $scan_args = array(
        'date' => preg_match('#^\d{4}-\d\d-\d\d$#', $_GET['date']) ? $_GET['date'] : null,
        'month' => preg_match('#^\d{4}-\d\d$#', $_GET['month']) ? $_GET['month'] : null,
        'place' => is_numeric($_GET['place']) ? $_GET['place'] : null,
        'user' => preg_match('/^\w+$/', $_GET['user']) ? $_GET['user'] : null
        );
    
    $title = get_args_title($context->db, $scan_args);
    $scans = get_scans($context->db, $scan_args, 50);
    $users = array();
    
    foreach($scans as $i => $scan)
    {   
        $user_id = $print['user_id'];
        
        if(is_null($users[$user_id]))
            $users[$user_id] = get_user($context->db, $user_id);
        
        $scans[$i]['user'] = $users[$user_id];
        
        if($scan['print_id'])
            $scans[$i]['print'] = get_print($context->db, $scan['print_id']);
    }
    
    $context->sm->assign('title', $title);
    $context->sm->assign('scans', $scans);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("snapshots.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>