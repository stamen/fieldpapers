<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    $print = get_print($context->db, $print_id);
    
    if (!$print) {
        header("HTTP/1.1 404");
        die("No such atlas.\n");
    }
    
    // get cloned or refreshed details
    $clone_child = NULL;
    $clone_parent = NULL;
    if(!$print['cloned']){
        $clone_child = get_latest_print_clone($context->db, $print_id);
    }else{
        $clone_parent = get_print($context->db, $print['cloned']);
    }

    $refresh_child = NULL;
    $refresh_parent = NULL;
    if(!$print['refreshed']){
        $refresh_child = get_latest_print_refresh($context->db, $print_id);
    }else{
        $refresh_parent = get_print($context->db, $print['refreshed']);
    }
    
    $pages = get_print_pages($context->db, $print_id);
    $print['page_count'] = count($pages);

    $isOSM = false;
    
    if($pages){
        $i=0;
        while($i < count($pages)){
            $page = $pages[$i];

            // check to see if provider is OSM to control visibility of 'Refresh' button in template
            if(strpos($page['provider'],"openstreetmap") !== false){
                $isOSM = true;
            }

            // get page zoom from first page
            if($page['page_number'] == 'A1'){
                $print['page_zoom'] = $page['zoom'];
            }

            // construct extent string
            $pages[$i]['nwse'] = $page['north'] .",". $page['west'] .",". $page['south'] .",". $page['east'];
            
            $i++;
        }
    }
    
    $context->sm->assign('print', $print);
    $context->sm->assign('isosm', $isOSM);
    $context->sm->assign('clone_child', $clone_child);
    $context->sm->assign('refresh_child', $refresh_child);
    $context->sm->assign('clone_parent', $clone_parent);
    $context->sm->assign('refresh_parent', $refresh_parent);

    if($print['selected_page']) {
        $context->sm->assign('pages', array($print['selected_page']));

    } else {
        $context->sm->assign('pages', $pages);
    }

    $query = array("place" => $print['place_woeid']);
    $nearby_prints = get_prints($context->db, $context->user, $query, 50);
    $context->sm->assign('nearby_prints', $nearby_prints);
    $context->sm->assign('nearby_prints_json', json_encode($nearby_prints));
    $context->sm->assign('zoom', $pages[0]['zoom']); 
    

    $context->sm->assign('activity', get_print_activity($context->db, $print_id, true));
    $context->sm->assign('providers', get_map_providers());
        
    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("atlas.html.tpl");
    
    } elseif($context->type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $context->sm->fetch("atlas.xml.tpl");
    
    } elseif($context->type == 'application/geo+json' || $context->type == 'application/json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        echo print_to_geojson($print, $pages)."\n";

    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
