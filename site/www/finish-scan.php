<?php
   /**
    * Display page for a single print with a given ID.
    *
    * When this page receives a POST request, it's probably from compose.py
    * (check the API_PASSWORD) with new information on print components for
    * building into a new PDF.
    */

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    enforce_api_password($_POST['password']);
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    /**** ... ****/
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    $scan = get_scan($dbh, $scan_id);
    
    if(!$scan)
    {
        die_with_code(400, "I don't know that scan");
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $dbh->query('START TRANSACTION');
        
        $scan['print_id'] = $_POST['print_id'];
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
        $scan['geojpeg_bounds'] = $_POST['geojpeg_bounds'];
        $scan['has_stickers'] = $_POST['has_stickers'];
        
        add_log($dbh, "Posting additional details to scan {$scan['id']}");

        set_scan($dbh, $scan);

        finish_scan($dbh, $scan['id']);

        $dbh->query('COMMIT');
    }
    
    header('HTTP/1.1 200');
    echo "OK\n";

?>
