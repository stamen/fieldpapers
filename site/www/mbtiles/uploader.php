<?php
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once '../../lib/init.php';
    require_once '../../lib/data.php';
    require_once '../../lib/lib.auth.php';
    
    //Upload mbtiles to the server.
    
    $target_mbtiles_folder = "uploaded_mbtiles/";
    
    $target_mbtiles_path = $target_mbtiles_folder . basename($_FILES['uploaded_mbtiles']['name']);
    
    if(move_uploaded_file($_FILES['uploaded_mbtiles']['tmp_name'], $target_mbtiles_path)){
        echo "<h3>" . basename($_FILES['uploaded_mbtiles']['name']) . " has been successfully uploaded.</h3>";
    } else {
        die("Upload of " . basename($_FILES['uploaded_mbtiles']['name']) . " was unsuccessful.");
    }
        
    //File is now sitting on the server at uploaded_tiles/some_name.mbtiles.
    
    $filename = explode('.', basename($_FILES['uploaded_mbtiles']['name']));
    $slug = $filename[0];
    
    $mbtiles_url = 'http://'.get_domain_name().get_base_dir().'/display_mbtiles.php?filename='.urlencode($slug);
    header("Location: $mbtiles_url");
    
    exit();
?>