<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $scan = get_scan($context->db, $scan_id);
    
    if(!$scan)
    {
        die_with_code(400, "I don't know that scan");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $context->db->query('START TRANSACTION');
        
        $scan['user_name'] = $_POST['user_name'];
        $scan['uploaded_file'] = $_POST['uploaded_file'];
        $scan['min_row'] = $_POST['min_row'];
        $scan['min_column'] = $_POST['min_column'];
        $scan['min_zoom'] = $_POST['min_zoom'];
        $scan['max_row'] = $_POST['max_row'];
        $scan['max_column'] = $_POST['max_column'];
        $scan['max_zoom'] = $_POST['max_zoom'];
        $scan['description'] = $_POST['description'];
        $scan['is_private'] = $_POST['is_private'];
        $scan['will_edit'] = $_POST['will_edit'];
        $scan['has_geotiff'] = $_POST['has_geotiff'];
        $scan['has_geojpeg'] = $_POST['has_geojpeg'];
        $scan['has_stickers'] = $_POST['has_stickers'];
        
        if($_POST['print_id'] && $_POST['print_page_number']) {
            $scan['print_id'] = $_POST['print_id'];
            $scan['print_page_number'] = $_POST['print_page_number'];
        
        } else {
            $scan['print_href'] = $_POST['print_href'];
        }
        
        if(preg_match('/^-?\d+(\.\d+)?(,-?\d+(\.\d+)?){3}$/', $_POST['geojpeg_bounds']))
        {
            $scan['geojpeg_bounds'] = $_POST['geojpeg_bounds'];
            $zoom = $scan['min_zoom']/2 + $scan['max_zoom']/2;

            list($south, $west, $north, $east) = explode(',', $_POST['geojpeg_bounds']);

            $lat = $south/2 + $north/2;
            $lon = $west/2 + $east/2;
            
            $place = latlon_placeinfo($lat, $lon, $zoom);
            
            $scan['country_name'] = $place[0];
            $scan['region_name'] = $place[2];
            $scan['place_name'] = $place[4];
            $scan['country_woeid'] = $place[1];
            $scan['region_woeid'] = $place[3];
            $scan['place_woeid'] = $place[5];
        }
        
        add_log($context->db, "Posting additional details to scan {$scan['id']}");

        set_scan($context->db, $scan);

        finish_scan($context->db, $scan['id']);

        $context->db->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
