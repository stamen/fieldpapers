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
        var map;
        function initMap() {
            var MM = com.modestmaps;

            var provider = new MM.TemplatedMapProvider('{/literal}{$base_dir}{literal}/mbtiles.php/'  + {/literal}'{$filename}'{literal} + '/{Z}/{X}/{Y}.png');
            
            // Set up the main map
            var map = new MM.Map('map', provider,null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
                        
            var center = map.coordinateLocation(new MM.Coordinate({/literal}{$mbtiles_data.center_y_coord}{literal},
                                                                  {/literal}{$mbtiles_data.center_x_coord}{literal},
                                                                  {/literal}{$mbtiles_data.center_zoom}{literal}
                                                                  )
                                                );
            var center_zoom = {/literal}{$mbtiles_data.center_zoom}{literal};
            
            map.setCenterZoom(center, center_zoom+1);
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
