<?php

    require_once '../lib/lib.everything.php';

    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    
    enforce_master_on_off_switch($language);
    
    $form_id = $_GET['id'] ? $_GET['id'] : null;
    
    /**** ... ****/
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    $form = get_form($dbh, $form_id);
    
    if(!$form)
    {
        die_with_code(400, "I don't know that form");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        $dbh->query('START TRANSACTION');
        
        add_log($dbh, "Failing form {$form['id']}");

        fail_form($dbh, $form['id'], 1);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
