<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $print_id = $_GET['print'] ? $_GET['print'] : null;
    
    $print = get_print($context->db, $print_id);
    
    $context->sm->assign('print', $print);
    
    if($print['selected_page']) {
        $pages = array($print['selected_page']);

    } else {
        $pages = get_print_pages($context->db, $print_id);
    }
        
    $context->sm->assign('pages', $pages);
    
    if($user = get_user($context->db, $print['user_id']))
    {
        $context->sm->assign('user', $user);
    }
    
    $users = array();
    $user_id = $print['user_id'];
    
    if(is_null($users[$user_id]))
        $users[$user_id] = get_user($context->db, $user_id);
    
    $print['user_name'] = $users[$user_id]['name'];
    
    if($scans = get_scans($context->db, array('print' => $print['id'])))
    {
        $note_args = array('scans' => array());
        
        foreach($scans as $scan)
        {
            $note_args['scans'][] = $scan['id'];
            $user_id = $scan['user_id'];
            
            if(is_null($users[$user_id]))
                $users[$user_id] = get_user($context->db, $user_id);
            
            $scan['user_name'] = $users[$user_id]['name'];
        }
        
        $notes = get_scan_notes($context->db, $note_args);
        
        foreach($notes as $i => $note)
        {
            $notes[$i]['scan'] = $scan;
            $user_id = $note['user_id'];
            
            if(is_null($users[$user_id]))
                $users[$user_id] = get_user($context->db, $user_id);
            
            $note['user_name'] = $users[$user_id]['name'];
        }

        $context->sm->assign('scans', $scans);
        $context->sm->assign('notes', $notes);

    } else {
        $notes = array();
    }
    
    $activity = array(array('type' => 'print', 'print' => $print));
    $times = array($print['created']);

    foreach($scans as $scan)
    {
        $activity[] = array('type' => 'scan', 'scan' => $scan);
        $times[] = $scan['created'];
    }
        
    foreach($notes as $note)
    {
        $activity[] = array('type' => 'note', 'note' => $note);
        $times[] = $note['created'];
    }
    
    array_multisort($times, SORT_ASC, $activity);
    $context->sm->assign('activity', $activity);
    
    function activity_to_geojson($activity)
    {
        $geojson = array(
            'type' => 'FeatureCollection',
            /*
            'properties' => array(
                'paper_size' => $print['paper_size'],
                'orientation' => $print['orientation'],
                'layout' => $print['layout']
            ),
            */
            'features' => array()
        );
        
        foreach($activity as $action)
        {
            if($action['type'] == 'print') {
                $geojson['features'][] = 'print';

            } elseif($action['type'] == 'scan') {
                $geojson['features'][] = 'scan';

            } elseif($action['type'] == 'note') {
                $geojson['features'][] = scan_note_to_geojson_feature($action['note']);
            }
        }
        
        return json_encode($geojson);
        
        foreach($pages as $page)
        {
            $north = floatval($page['north']);
            $south = floatval($page['south']);
            $west = floatval($page['west']);
            $east = floatval($page['east']);
        
            $feature = array(
                'type' => 'Feature',
                'properties' => array('provider' => $page['provider'], 'zoom' => intval($page['zoom'])),
                'geometry' => array(
                    'type' => 'Polygon',
                    'coordinates' => array(array(
                        array($west, $north), array($east, $north),
                        array($east, $south), array($west, $south),
                        array($west, $north)
                    ))
                )
            );
            
            $geojson['features'][] = $feature;
        }
        
        return json_encode($geojson);
    }
        
    if($context->type == 'application/geo+json' || $context->type == 'application/json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        echo activity_to_geojson($activity)."\n";

    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
