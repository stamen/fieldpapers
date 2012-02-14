<!DOCTYPE html>
<html>
<head>
    <title>Show MBTiles</title>
    <style type="text/css">

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
            //var provider = new MM.TemplatedMapProvider('{$base_dir}/mbtiles.php/'  + name + '/{Z}/{X}/{Y}.png');
            //console.log(name);
            
            // Set up the main map
            var map = new MM.Map('map', provider); 
            map.setCenterZoom(new MM.Location(39.23, -101.42), 3);
        }
    </script>
</head>
    <body onload="initMap()">
        {include file="header.htmlf.tpl"}
        {include file="navigation.htmlf.tpl"}
        
        <?php
            if(move_uploaded_file($_FILES['uploaded_mbtiles']['tmp_name'], $target_mbtiles_path)){
                echo "<h3>" . basename($_FILES['uploaded_mbtiles']['name']) . " has been successfully uploaded.</h3>";
            } else {
                echo "<h3>Upload of " . basename($_FILES['uploaded_mbtiles']['name']) . " was unsuccessful.</h3>";
            }
        ?>
        <div id="map"></div>
    </body>
</html>