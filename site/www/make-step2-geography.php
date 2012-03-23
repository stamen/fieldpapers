<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
    
    /**** ... ****/
    
    $atlas_data = array();
    
    if($_POST['atlas_title'])
        $atlas_data['atlas_title'] = $_POST['atlas_title'];

    if($_POST['atlas_text'])
        $atlas_data['atlas_text'] = $_POST['atlas_text'];

    $context->sm->assign('atlas_data', $atlas_data);

    if($_POST['query'])
    {
        $latlon = placename_latlon($_POST['query']);
        
        if(!is_array($latlon))
        {
            $redirect_href = sprintf('http://%s%s/make-step1-search.php?error=no_response', get_domain_name(), get_base_dir());
            
            header('HTTP/1.1 303');
            header("Location: $redirect_href");
            exit();
        }
        
        $context->sm->assign('center', join(',', $latlon));
        $context->sm->assign('zoom', 10);
    }

    /*
    
    // breaking this for the moment
    
    if($_GET['mbtiles_id'])
    {        
        $mbtiles = get_mbtiles_by_id($context->db, $_GET['mbtiles_id']);
                
        $mbtiles_data = array("provider" =>      $mbtiles['url'],
                              "uploaded_file" => $mbtiles['uploaded_file'],
                              "center_x" =>      $mbtiles['center_x_coord'],
                              "center_y" =>      $mbtiles['center_y_coord'],
                              "zoom" =>          $mbtiles['center_zoom'],
                              'min_zoom' =>      $mbtiles['min_zoom'],
                              'max_zoom' =>      $mbtiles['max_zoom']
                              );
        $context->sm-> assign('mbtiles_data', $mbtiles_data); 
    }
    */
        
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("make-step2-geography.html.tpl");
    
?>