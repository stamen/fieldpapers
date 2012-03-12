<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
    
    /**** ... ****/
    
    $sm = get_smarty_instance();
        
    // Used to use POST variable
    if ($_GET['mbtiles_id'])
    {        
        $mbtiles = get_mbtiles_by_id($dbh, $_GET['mbtiles_id']);
                
        $mbtiles_data = array("provider" =>      $mbtiles['url'],
                              "uploaded_file" => $mbtiles['uploaded_file'],
                              "center_x" =>      $mbtiles['center_x_coord'],
                              "center_y" =>      $mbtiles['center_y_coord'],
                              "zoom" =>          $mbtiles['center_zoom'],
                              'min_zoom' =>      $mbtiles['min_zoom'],
                              'max_zoom' =>      $mbtiles['max_zoom']
                              );
        $sm-> assign('mbtiles_data', $mbtiles_data); 
    } else {
        $center = $_GET['center'];
        $zoom = 10;
        $sm-> assign('center', $center);
        $sm-> assign('zoom', $zoom);
    }
        
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("make-atlas.html.tpl");
    
?>