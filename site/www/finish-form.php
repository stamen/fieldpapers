<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context(False);
    
    /**** ... ****/
    
    // Getting the correct form id
    $form_id = $_GET['id'] ? $_GET['id'] : null;
    
    $form = get_form($context->db, $form_id);
    
    if(!$form)
    {
        die_with_code(400, "I don't know that form");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $context->db->query('START TRANSACTION');
        
        foreach($_POST['fields'] as $_field)
        {
            $field = add_form_field($context->db, $form['id'], $_field['name']);
            
            if(!$field)
            {
                die_with_code(400, "I don't know that field");
            }
        
            $field['type'] = $_field['type'];
            $field['label'] = $_field['label'];
            set_form_field($context->db, $field);
        }

        // manually-defined form title from add-form.php wins here
        $form['title'] = $form['title'] ? $form['title'] : $_POST['title'];

        $form['http_method'] = $_POST['http_method'];
        $form['action_url'] = $_POST['action_url'];

        set_form($context->db, $form);

        finish_form($context->db, $form['id']);

        $context->db->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
