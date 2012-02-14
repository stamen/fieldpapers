<?php

    header('HTTP/1.1 500');

?><?php
   /**
    * Display page for a single print with a given ID.
    *
    * When this page receives a POST request, it's probably from compose.py
    * (check the API_PASSWORD) with new information on print components for
    * building into a new PDF.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.auth.php';
    require_once 'lib.forms.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    
    enforce_master_on_off_switch($language);

    // Getting the correct form id
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
        
        foreach($_POST['fields'] as $_field)
        {
            $field = add_form_field($dbh, $form['id'], $_field['name']);
            
            if(!$field)
            {
                die_with_code(400, "I don't know that field");
            }
        
            $field['type'] = $_field['type'];
            $field['label'] = $_field['label'];
            set_form_field($dbh, $field);
        }

        // manually-defined form title from add-form.php wins here
        $form['title'] = $form['title'] ? $form['title'] : $_POST['title'];

        $form['http_method'] = $_POST['http_method'];
        $form['action_url'] = $_POST['action_url'];

        set_form($dbh, $form);

        finish_form($dbh, $form['id']);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
