<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $atlas_data = array(
        'atlas_title' => $_POST['atlas_title'],
        'page_zoom' => sprintf('%d', $_POST['page_zoom']),
        'paper_size' => $_POST['paper_size'],
        'orientation' => $_POST['orientation'],
        'provider' => $_POST['provider'],
        'form_url' => $_POST['form_url'],
        'form_id' => $_POST['form_id'],
        'pages' => (is_array($_POST['pages']) ? $_POST['pages'] : array())
        );

    $context->sm->assign('atlas_data', $atlas_data);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("make-step4-layout.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>