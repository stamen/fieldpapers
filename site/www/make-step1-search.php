<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
    
    /**** ... ****/
    
    if($_GET['error'] == 'no_response')
    {
        $context->sm->assign('error', $_GET['error']);
    }
    
    if($_POST['query'])
    {
        $latlon = placename_latlon($_POST['query']);
        
        $redirect_href = is_array($latlon)
            ? sprintf('http://%s%s/make-atlas.php?center=%s', get_domain_name(), get_base_dir(), join(',', $latlon))
            : sprintf('http://%s%s/make-step1-search.php?error=no_response', get_domain_name(), get_base_dir());
        
        header('HTTP/1.1 303');
        header("Location: $redirect_href");
        exit();
    }

    $user_mbtiles = get_mbtiles_by_user_id($context->db, $context->user['id']);
    
    if ($user_mbtiles)
    {
        $context->sm->assign('user_mbtiles', $user_mbtiles);
    }
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("make-step1-search.html.tpl");
    
?>