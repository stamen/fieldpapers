<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context();
    
    /**** ... ****/

    $print_id = $_GET['id'] ? $_GET['id'] : null;
    $print = get_print($context->db, $print_id);
    
    if(!$print)
    {
        die_with_code(400, "I don't know that print");
    }
    
    if($progress = $_POST['progress'])
    {
        $context->db->query('START TRANSACTION');
        
        $print['progress'] = $progress;
        set_print($context->db, $print);

        $context->db->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
