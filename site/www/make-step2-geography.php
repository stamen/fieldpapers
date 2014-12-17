<?php

    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $context = default_context(True);
    
    /**** ... ****/
    
    $atlas_data = array();
    
    if($_POST['atlas_provider'])
        $atlas_data['atlas_provider'] = $_POST['atlas_provider'];

    if($_POST['atlas_title'])
        $atlas_data['atlas_title'] = $_POST['atlas_title'];

    if($_POST['atlas_text'])
        $atlas_data['atlas_text'] = $_POST['atlas_text'];

    $context->sm->assign('atlas_data', $atlas_data);
    
    if(isset($_POST['query']))
    {
        if(preg_match('/^(-?\d+(?:\.\d+)?)[,\s]+(-?\d+(?:\.\d+)?)(?:[,\s]+(\d+))?$/', trim($_POST['query']), $m))
        {
            $latlon = array($m[1], $m[2]);
            $zoom = $m[3] ? $m[3] : 10;
        
        } else {
            $latlonzoom = placefinder_placename_latlonzoom($_POST['query']);
            //header('Content-type: text/javascript');
            
            if(!is_array($latlonzoom))
            {
                $redirect_href = sprintf('http://%s%s/make-step1-search.php?error=no_response', get_domain_name(), get_base_dir());
                
                header('HTTP/1.1 303');
                header("Location: $redirect_href");
                exit();
            }
            
            $latlon = array($latlonzoom[0], $latlonzoom[1]);
            $zoom = $latlonzoom[2];
        }
        
        $context->sm->assign('center', join(',', $latlon));
        $context->sm->assign('zoom', $zoom);
        
        $redirect_href = sprintf('http://%s%s/make-step2-geography.php?zoom=%s&lat=%s&lon=%s', get_domain_name(), get_base_dir(), $zoom, $latlon[0], $latlon[1]);

        header('HTTP/1.1 303');
        header("Location: $redirect_href");
    }
    if(isset($_GET) && !empty($_GET)){ 
        if($_GET['mbtiles_id']){        
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
        }elseif($_GET['lat'] && $_GET['lon'] && $_GET['zoom']){
            $center = array($_GET['lat'], $_GET['lon']);
            $zoom = $_GET['zoom'];
            
            $context->sm->assign('center', join(',', $center));
            $context->sm->assign('zoom', $zoom);
        }else{
            $redirect_href = sprintf('http://%s%s/make-step1-search.php?error=no_response', get_domain_name(), get_base_dir());
            header('HTTP/1.1 303');
            header("Location: $redirect_href"); 
            exit();
        }
    }

    if (is_logged_in()) {
        $user_mbtiles = get_mbtiles_by_user_id($context->db, $context->user['id']);

        if ($user_mbtiles)
        {
            $context->sm->assign('user_mbtiles', $user_mbtiles);
        }
    }
    
    $context->sm->assign('providers', get_map_providers());
            
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("make-step2-geography.html.tpl");
    
?>
