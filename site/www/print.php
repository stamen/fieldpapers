<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    $print = get_print($context->db, $print_id);
    
    $context->sm->assign('print', $print);
    
    if($print['selected_page']) {
        $pages = array($print['selected_page']);

    } else {
        $pages = get_print_pages($context->db, $print_id);
    }
    
    $context->sm->assign('pages', $pages);
    
    if($user = get_user($context->db, $print['user_id']))
    {
        $context->sm->assign('user', $user);
    }
    
    if($scans = get_scans($context->db, array('print' => $print['id'])))
    {
        $note_args = array('scans' => array());
        
        foreach($scans as $scan)
            $note_args['scans'][] = $scan['id'];
        
        $notes = get_scan_notes($context->db, $note_args);
        
        foreach($notes as $i => $note)
            $notes[$i]['scan'] = $scan;

        $context->sm->assign('scans', $scans);
        $context->sm->assign('notes', $notes);

    } else {
        $notes = array();
    }
    
    $activity = array(array('type' => 'print', 'print' => $print));
    $times = array($print['created']);

    foreach($scans as $scan)
    {
        $activity[] = array('type' => 'scan', 'scan' => $scan);
        $times[] = $scan['created'];
    }
        
    foreach($notes as $note)
    {
        $activity[] = array('type' => 'note', 'note' => $note);
        $times[] = $note['created'];
    }
    
    array_multisort($times, SORT_ASC, $activity);
    $context->sm->assign('activity', $activity);
        
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("print.html.tpl");
    
    } elseif($context->type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("print.xml.tpl");
    
    } elseif($context->type == 'application/geo+json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        echo print_to_geojson($print, $pages)."\n";

    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
