<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $delete = ($_POST['delete'] == 'yes') ? true : false;
    $timeout = is_numeric($_POST['timeout']) ? $_POST['timeout'] : null;
    $message_id = is_numeric($_POST['id']) ? $_POST['id'] : null;
    
    if($message_id && $delete) {
        add_log($context->db, "Deleting message {$message_id}");

        $context->db->query('START TRANSACTION');
        delete_message($context->db, $message_id);
        $context->db->query('COMMIT');
    
        echo "OK\n";
    
    } elseif($message_id && $timeout) {
        add_log($context->db, "Postponing message {$message_id} for {$timeout} seconds");

        $context->db->query('START TRANSACTION');
        postpone_message($context->db, $message_id, $timeout);
        $context->db->query('COMMIT');
    
        echo "OK\n";
    
    } elseif($timeout) {
        $context->db->query('START TRANSACTION');
        $message = get_message($context->db, $timeout);
        $context->db->query('COMMIT');
        
        header('Content-Type: text/plain');
        
        if($message) {
            add_log($context->db, "Dequeued message {$message['id']} with {$timeout} second timeout");
    
            printf("%d %s\n", $message['id'], $message['content']);
        
        } else {
            echo "0\n";
        }
    }

?>
