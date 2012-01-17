<?php
    //Upload mbtiles to the server.
    
    $target_mbtiles_folder = "uploaded_mbtiles/";
    
    $target_mbtiles_path = $target_mbtiles_folder . basename($_FILES['uploaded_mbtiles']['name']);
    
    /*
    if(move_uploaded_file($_FILES['uploaded_mbtiles']['tmp_name'], $target_mbtiles_path)){
        echo "<h3>" . basename($_FILES['uploaded_mbtiles']['name']) . " has been successfully uploaded.</h3>";
    } else {
        // there's a problem with this
        echo "<h3>Upload of " . basename($_FILES['uploaded_mbtiles']['name']) . " was unsuccessful.</h3>";
    }
    */
        
    //File is now sitting on the server at uploaded_tiles/some_name.mbtiles.
    
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    require_once '../../lib/init.php';
    require_once '../../lib/data.php';
    require_once '../../lib/lib.auth.php';

    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);
        
    $sm = get_smarty_instance(); // is this right?
    print $sm->fetch("header.htmlf.tpl");
    print $sm->fetch("navigation.htmlf.tpl");
    
    
    $filename = explode('.', basename($_FILES['uploaded_mbtiles']['name']));
    $slug = $filename[0];
    $_SESSION['file'] = $slug;
?>
<!DOCTYPE html>
<html>
<head>
    <title>Show MBTiles</title>
    <style type="text/css">

    
    #map {
        background: #000000;
        width: 500px;
        height: 400px;
        margin: 0 auto;
    }
    </style>
    <link rel="stylesheet" href="{$base_dir}/../../style.css" type="text/css" />
    <script type="text/javascript" src="../atlas-ui/modest_maps/modestmaps.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript">
        function initMap() {
            var center_lat = 37.77,
                center_lon = -122.41;
            var MM = com.modestmaps;
            var name = <?php echo json_encode($_SESSION['file']);?>;
            var provider = new MM.TemplatedMapProvider('mbtiles.php/'  + name + '/{Z}/{X}/{Y}.png');
            console.log(name);
            
            // Set up the main map
            var map = new MM.Map('map', provider); 
            map.setCenterZoom(new MM.Location(39.23, -101.42), 3);
        }
    </script>
</head>
    <body onload="initMap()">
        <?php
            if(move_uploaded_file($_FILES['uploaded_mbtiles']['tmp_name'], $target_mbtiles_path)){
                echo "<h3>" . basename($_FILES['uploaded_mbtiles']['name']) . " has been successfully uploaded.</h3>";
            } else {
                // there's a problem with this
                echo "<h3>Upload of " . basename($_FILES['uploaded_mbtiles']['name']) . " was unsuccessful.</h3>";
            }
        ?>
        <div id="map"></div>
    </body>
</html>