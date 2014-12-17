<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
    $atlas_data = array(
        'atlas_title' => $_POST['atlas_title'],
        'atlas_text'  => $_POST['atlas_text'],
        'page_zoom'   => sprintf('%d', $_POST['page_zoom']),
        'paper_size'  => $_POST['paper_size'],
        'orientation' => $_POST['orientation'],
        'provider'    => $_POST['provider'],
        'pages'       => (is_array($_POST['pages']) ? $_POST['pages'] : array()),
        'private'     => filter_var($_REQUEST['private'], FILTER_VALIDATE_BOOLEAN),
        );

    if($_POST['overlay'])
        $atlas_data['overlay'] = $_POST['overlay'];
    
    if(isset($_POST['clone_id']) && !empty($_POST['clone_id'])){
        $atlas_data['clone_id'] = trim($_POST['clone_id']);
    }elseif(isset($_POST['refresh_id']) && !empty($_POST['refresh_id'])){
         $atlas_data['refresh_id'] = trim($_POST['refresh_id']);
    } 

    $context->sm->assign('atlas_data', $atlas_data);
    
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("make-step4-layout.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
