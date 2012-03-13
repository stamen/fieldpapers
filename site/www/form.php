<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $form_id = $_GET['id'] ? $_GET['id'] : null;

    $form = get_form($context->db, $form_id);
    $user = get_user($context->db, $form['user_id']);
    
    if ($user['name'])
    {
        $form['user_name'] = $user['name'];
    } else {
        $form['user_name'] = 'Anonymous';
    }
    
    $context->sm->assign('form', $form);
    
    // Get fields
    $fields = get_form_fields($context->db, $form_id);
    $context->sm->assign('fields', $fields);
    
    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type);
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("form.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
