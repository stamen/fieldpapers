<?php
    require_once '../lib/lib.everything.php';
    
    $dbh =& get_db_connection();
        
    ////
    // Path
    ////
    $mbtiles_filename = basename($_FILES['uploaded_mbtiles']['name']);
    $target_mbtiles_folder = "mbtiles/";
    $target_mbtiles_path = $target_mbtiles_folder . $mbtiles_filename;
    
    ////
    // Content
    ////
    $mbtiles_content_bytes = file_get_contents($_FILES['uploaded_mbtiles']['tmp_name']);
    
    $mime_type = 'application/octet-stream';
    
    // Post the file
    post_file($target_mbtiles_path, $mbtiles_content_bytes, $mime_type);
    
    // Keep a record in the database
    $user_id = $_POST['user_id'];
    
    $filename = explode('.', basename($_FILES['uploaded_mbtiles']['name']));
    $slug = $filename[0];
    
    $mbtiles_url = 'http://'.get_domain_name().get_base_dir().'/mbtiles.php/'.$slug. '/{Z}/{X}/{Y}.png';
    
    $mbtiles = add_mbtiles($dbh, $user_id, $mbtiles_url, $mbtiles_filename,'files/'.$target_mbtiles_path);
    
    $display_mbtiles_url = 'http://'.get_domain_name().get_base_dir().'/display_mbtiles.php?id='.urlencode($mbtiles['id']).'&filename='.urlencode($slug);
    header("Location: $display_mbtiles_url");
    
    exit();
?>