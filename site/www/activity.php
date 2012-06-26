<?php

    require_once '../lib/lib.everything.php';
      
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
    $print_id = $_GET['print'] ? $_GET['print'] : null;
    
    $print = get_print($context->db, $print_id);
    $activity = get_print_activity($context->db, $print_id, false);
    
    if($_GET['type'] == 'shp') {
        header('Content-Type: application/zip');
        header('Content-Disposition: filename="activity-'.$print['id'].'.zip"');
        echo activity_to_shpzip($activity, $print['id']);

    } elseif($context->type == 'text/csv') { 
        header("Content-Type: text/csv; charset=UTF-8");
        header('Content-Disposition: filename="activity-'.$print['id'].'.csv"');
        echo activity_to_csv($activity)."\n";

    } elseif($context->type == 'application/geo+json' || $context->type == 'application/json') { 
        header("Content-Type: application/geo+json; charset=UTF-8");
        header('Content-Disposition: filename="activity-'.$print['id'].'.geojson"');
        echo activity_to_geojson($activity);

    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
