<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context();
    
    /**** ... ****/

    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    $scan = get_scan($context->db, $scan_id);
    
    if(!$scan)
    {
        die_with_code(400, "I don't know that scan");
    }
    
    if($progress = $_POST['progress'])
    {
        $context->db->query('START TRANSACTION');
        
        $scan['progress'] = $progress;
        set_scan($context->db, $scan);

        $context->db->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
