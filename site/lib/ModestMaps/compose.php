<?php

    require_once 'ModestMaps.php';
    
    $p = new MMaps_Templated_Spherical_Mercator_Provider('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png,http://osm.stamen.com/gridtile/tilecache.cgi/1.0/mgrs/{Z}/{X}/{Y}.png');
    $m = MMaps_mapByCenterZoom($p, new MMaps_Location(37.804969, -122.257662), 14, new MMaps_Point(500, 500));
    $i = $m->draw();
    
    imagepng($i, '/tmp/out.png');

?>