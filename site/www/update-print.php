<?php

    require_once '../lib/lib.everything.php';

    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    enforce_master_on_off_switch($language);
    enforce_api_password($_POST['password']);

    /**** ... ****/
    
    $dbh =& get_db_connection();

    $print_id = $_GET['id'] ? $_GET['id'] : null;
    $print = get_print($dbh, $print_id);
    
    if(!$print)
    {
        die_with_code(400, "I don't know that print");
    }
    
    if($progress = $_POST['progress'])
    {
        $dbh->query('START TRANSACTION');
        
        $print['progress'] = $progress;
        set_print($dbh, $print);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
