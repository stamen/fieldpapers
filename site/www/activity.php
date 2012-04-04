<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $print_id = $_GET['print'] ? $_GET['print'] : null;
    
    $print = get_print($context->db, $print_id);
    
    $context->sm->assign('print', $print);
    
    if($print['selected_page']) {
        $pages = array($print['selected_page']);

    } else {
        $pages = get_print_pages($context->db, $print_id);
    }
        
    $print['pages'] = $pages;
    $context->sm->assign('pages', $pages);
    
    if($user = get_user($context->db, $print['user_id']))
    {
        $context->sm->assign('user', $user);
    }
    
    $users = array();
    $user_id = $print['user_id'];
    
    if(is_null($users[$user_id]))
        $users[$user_id] = get_user($context->db, $user_id);
    
    $print['user_name'] = $users[$user_id]['name'];
    
    if($scans = get_scans($context->db, array('print' => $print['id']), 9999))
    {
        $note_args = array('scans' => array());
        
        foreach($scans as $i => $scan)
        {
            $scans[$i]['print'] = $print;
            $scans[$i]['page'] = get_print_page($context->db, $scan['print_id'], $scan['print_page_number']);
            $note_args['scans'][] = $scan['id'];
            $user_id = $scan['user_id'];
            
            if(is_null($users[$user_id]))
                $users[$user_id] = get_user($context->db, $user_id);
            
            $scans[$i]['user_name'] = $users[$user_id]['name'];
        }
        
        $notes = get_scan_notes($context->db, $note_args, 9999);
        
        foreach($notes as $i => $note)
        {
            $notes[$i]['scan'] = $scan;
            $user_id = $note['user_id'];
            
            if(is_null($users[$user_id]))
                $users[$user_id] = get_user($context->db, $user_id);
            
            $notes[$i]['user_name'] = $users[$user_id]['name'];
        }

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
    
    if($context->type == 'text/csv') { 
        header("Content-Type: text/csv; charset=UTF-8");
        header('Content-Disposition: filename="activity-'.$print['id'].'.csv"');
        echo activity_to_csv($activity)."\n";

    } elseif($context->type == 'application/geo+json' || $context->type == 'application/json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        header('Content-Disposition: filename="activity-'.$print['id'].'.geojson"');
        echo activity_to_geojson($activity);

    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
