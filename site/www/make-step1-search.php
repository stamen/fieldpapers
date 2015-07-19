<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context(True);
    
    /**** ... ****/
    
    $atlas_data = array();
    
    if($_POST['atlas_location'])
        $atlas_data['atlas_location'] = $_POST['atlas_location'];

    if($_POST['atlas_provider'])
        $atlas_data['atlas_provider'] = $_POST['atlas_provider'];

    if($_POST['atlas_title'])
        $atlas_data['atlas_title'] = $_POST['atlas_title'];

    if($_POST['atlas_text'])
        $atlas_data['atlas_text'] = $_POST['atlas_text'];

    $context->sm->assign('atlas_data', $atlas_data);
    if($_GET['error'] == 'no_response')
    {
        $context->sm->assign('error', 'We could not find that place. Please try again.');
    }
    
    // TODO: check whether search is currently working
    // pass $error_nosearch to template

    if (is_logged_in()) {

        $user_mbtiles = get_mbtiles_by_user_id($context->db, $context->user['id']);

        if ($user_mbtiles)
        {
            $context->sm->assign('user_mbtiles', $user_mbtiles);
        }
    }
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("make-step1-search.html.tpl");
    
?>
