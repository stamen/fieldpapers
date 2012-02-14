<?php
   /**
    * POST endpoint for pulling messages from the queue.
    *
    * Gets new messages, existing messages, accepts visibility timeout, and deletes messages.
    */

    require_once '../lib/lib.everything.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    
    enforce_master_on_off_switch('');

    if($_POST['password'] != API_PASSWORD)
        die_with_code(401, 'Sorry, bad password');
    
    $delete = ($_POST['delete'] == 'yes') ? true : false;
    $timeout = is_numeric($_POST['timeout']) ? $_POST['timeout'] : null;
    $message_id = is_numeric($_POST['id']) ? $_POST['id'] : null;
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($message_id && $delete) {
        add_log($dbh, "Deleting message {$message_id}");

        $dbh->query('START TRANSACTION');
        delete_message($dbh, $message_id);
        $dbh->query('COMMIT');
    
        echo "OK\n";
    
    } elseif($message_id && $timeout) {
        add_log($dbh, "Postponing message {$message_id} for {$timeout} seconds");

        $dbh->query('START TRANSACTION');
        postpone_message($dbh, $message_id, $timeout);
        $dbh->query('COMMIT');
    
        echo "OK\n";
    
    } elseif($timeout) {
        $dbh->query('START TRANSACTION');
        $message = get_message($dbh, $timeout);
        $dbh->query('COMMIT');
        
        header('Content-Type: text/plain');
        
        if($message) {
            add_log($dbh, "Dequeued message {$message['id']} with {$timeout} second timeout");
    
            printf("%d %s\n", $message['id'], $message['content']);
        
        } else {
            echo "0\n";
        }
    }

?>
