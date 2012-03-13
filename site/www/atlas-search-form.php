<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
    
    /**** ... ****/
    
    if($_GET['error'] == 'no_response')
    {
        $context->sm->assign('error', $_GET['error']);
    }
    
    $user_mbtiles = get_mbtiles_by_user_id($context->db, $context->user['id']);
    
    if ($user_mbtiles)
    {
        $context->sm->assign('user_mbtiles', $user_mbtiles);
    }
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("atlas-search-form.html.tpl");
    
?>