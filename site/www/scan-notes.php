<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    $notes = is_array($_POST['notes']) ? $_POST['notes'] : array();
        
    $user = get_user($context->db, $_SESSION['user']['id']);  
    
    $scan = get_scan($context->db, $scan_id);
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($scan)
        {
            $context->db->query('START TRANSACTION');
    
            set_scan_notes($context->db, $user['id'], $scan['id'], $notes);
            
            $context->db->query('COMMIT');
        }
    }
    
    $scan_notes = get_scan_notes($context->db, array('page' => 1, 'perpage' => 242), $scan ? $scan['id'] : null);
    
    if($user['id'])
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    header('Content-Type: text/tab-separated-values; charset=utf-8');
    echo "scan_id	number	note	north	west	south	east\n";
    
    foreach($scan_notes as $note)
        printf("%s	%d	%s	%.8f	%.8f	%.8f	%.8f\n",
               $note['scan_id'],
               $note['number'],
               '"'.str_replace('"', '""', $note['note']).'"',
               $note['north'],
               $note['west'],
               $note['south'],
               $note['east']);

?>