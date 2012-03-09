<!DOCTYPE html>
<html>
<head>
    <title>Show MBTiles</title>
    {literal}
    <style type="text/css">
    html,body {
        padding: 0;
        margin: 0;
    }
    
    #map {
        width: 100%;
        height: 512px;
        background-color: #000;
    }
    </style>
    {/literal}
    <script type="text/javascript" src="{$base_dir}/js/modestmaps.min.js"></script>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript">
        {literal}
        function initMap() {
            var center_lat = 37.77,
                center_lon = -122.41;
            
            var MM = com.modestmaps;

            var provider = new MM.TemplatedMapProvider('{/literal}{$base_dir}{literal}/mbtiles.php/'  + {/literal}'{$filename}'{literal} + '/{Z}/{X}/{Y}.png');
            console.log(name);
            
            // Set up the main map
            var map = new MM.Map('map', provider,null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
            
            var north = '{/literal}{$mbtiles_data.north}{literal}';
            var south = '{/literal}{$mbtiles_data.south}{literal}';
            var east = '{/literal}{$mbtiles_data.east}{literal}';
            var west = '{/literal}{$mbtiles_data.west}{literal}';
            
            var locations = [
                new MM.Location(north, west),
                new MM.Location(north, east),
                new MM.Location(south, east),
                new MM.Location(south, west)
            ];
            
            map.setExtent(locations);
        }
        {/literal}
    </script>
</head>
    <body onload="initMap()">
        {include file="navigation.htmlf.tpl"}
        <div id="container">
            <h1>Your MBTiles</h1>
            <div id="map"></div>
            {include file="footer.htmlf.tpl"}
        </div>
    </body>
</html>
