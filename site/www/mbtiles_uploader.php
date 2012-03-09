<?php
    require_once '../lib/lib.everything.php';
    
    $dbh =& get_db_connection();
        
    ////
    // Path
    ////
    $target_mbtiles_folder = "files/mbtiles/";
    $target_mbtiles_path = $target_mbtiles_folder . basename($_FILES['uploaded_mbtiles']['name']);
    
    ////
    // Content
    ////
    $mbtiles_content_bytes = file_get_contents($_FILES['uploaded_mbtiles']['tmp_name']);
    
    $mime_type = 'application/octet-stream';
    
    // Post the file
    post_file($target_mbtiles_path, $mbtiles_content_bytes, $mime_type);
    
    // Keep a record in the database
    $user_id = $_POST['user_id'];
    $mbtiles_url = 'http://'.get_domain_name().get_base_dir().$target_mbtiles_path;
    
    add_mbtiles($dbh, $user_id, $mbtiles_url, $target_mbtiles_path);
    
    $filename = explode('.', basename($_FILES['uploaded_mbtiles']['name']));
    $slug = $filename[0];
    
    $mbtiles_url = 'http://'.get_domain_name().get_base_dir().'/display_mbtiles.php?filename='.urlencode($slug);
    header("Location: $mbtiles_url");
    
    exit();
?>