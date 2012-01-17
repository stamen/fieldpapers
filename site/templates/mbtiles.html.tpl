<!DOCTYPE html>
<html>
<head>
    <title>Show MBTiles</title>
    <style type="text/css">
    html,body {
        width: 700px;
        height: 700px;
        padding: 0;
        margin: 0;
    }
    
    #map {
        width: 100%;
        height: 512px;
    }
    </style>
    <script type="text/javascript" src="../atlas-ui/modest_maps/modestmaps.min.js"></script>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript">
        function initMap() {
            var center_lat = 37.77,
                center_lon = -122.41;
            var MM = com.modestmaps;
            //var provider = new MM.TemplatedMapProvider('http://tiles.teczno.com/bing-lite/{Z}/{X}/{Y}.jpg');
            //var provider = new MM.TemplatedMapProvider('http://fieldpapers.org/~mevans/fieldpapers/site/www/mbtiles/mbtiles.php/control-room_d65138/{Z}/{X}/{Y}.png');
            var name = <?php echo json_encode($_SESSION['file']);?>;
            var provider = new MM.TemplatedMapProvider('{$base_dir}/mbtiles/mbtiles.php/'  + name + '/{Z}/{X}/{Y}.png');
            console.log(name);
            
            // Set up the main map
            var map = new MM.Map('map', provider); 
            
            map.setCenterZoom(new MM.Location(39.23, -101.42), 3);
        }
    </script>
</head>
    <body onload="initMap()">
        {include file="header.htmlf.tpl"}
        {include file="navigation.htmlf.tpl"}
        
        <h1>Your MBTiles</h1>
        <div id="map"></div>
    </body>
</html>
