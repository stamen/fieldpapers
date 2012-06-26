<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch( $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context(False);
    
    /**** ... ****/
    
    $form_id = $_GET['id'] ? $_GET['id'] : null;
    
    $form = get_form($context->db, $form_id);
    
    if(!$form)
    {
        die_with_code(400, "I don't know that form");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        $context->db->query('START TRANSACTION');
        
        add_log($context->db, "Failing form {$form['id']}");

        fail_form($context->db, $form['id'], 1);

        $context->db->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>