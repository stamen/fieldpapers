<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context();
    
    /**** ... ****/
    
    // Used to use POST variable
    if ($_GET['mbtiles_id'])
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