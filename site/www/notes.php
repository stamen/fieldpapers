<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/
    
    $note_args = array(
        'date' => preg_match('#^\d{4}-\d\d-\d\d$#', $_GET['date']) ? $_GET['date'] : null,
        'month' => preg_match('#^\d{4}-\d\d$#', $_GET['month']) ? $_GET['month'] : null,
        'place' => is_numeric($_GET['place']) ? $_GET['place'] : null,
        'user' => preg_match('/^\w+$/', $_GET['user']) ? $_GET['user'] : null
        );
    
    $notes = get_scan_notes($context->db, $note_args, 50);
    
    foreach($notes as $i => $note)
    {
        $notes[$i]['scan'] = get_scan($context->db, $note['scan_id']);
    }
    
    $context->sm->assign('notes', $notes);
    
    if($context->type == 'application/json') {
        header('Content-Type: text/plain');
        echo scan_notes_to_geojson($notes)."\n";
        
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>