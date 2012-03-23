<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
    
    /**** ... ****/
    
    if($_POST['query'])
    {
        $latlon = placename_latlon($_POST['query']);
        
        $redirect_href = is_array($latlon)
            ? sprintf('http://%s%s/make-step2-geography.php?center=%s', get_domain_name(), get_base_dir(), join(',', $latlon))
            : sprintf('http://%s%s/make-step1-search.php?error=no_response', get_domain_name(), get_base_dir());
        
        header('HTTP/1.1 303');
        header("Location: $redirect_href");
        exit();
    }

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

    } else {
        $center = $_GET['center'];
        $zoom = 10;
        $context->sm-> assign('center', $center);
        $context->sm-> assign('zoom', $zoom);
    }
        
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("make-step2-geography.html.tpl");
    
?>