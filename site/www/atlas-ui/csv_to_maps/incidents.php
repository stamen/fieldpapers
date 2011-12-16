<?php 
    session_start();
    $json_path = $_SESSION['json_file_path'];
?>

<!DOCTYPE html>
<html>
<head>
<title>CSV Points</title>
<script type="text/javascript" src="../modest_maps/modestmaps.min.js"></script>
<script type="text/javascript" src="../modest_maps/markerclip.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
<script type="text/javascript">
$(document).ready(function(){
    var json_path = '<?php echo $json_path ?>';
    $.getJSON(json_path, createDisplay);
});

function createDisplay(data) {
    var center_lat = 37.77;
    var center_lon = -122.41;
    
    var map = new MM.Map('map', 
                      new MM.TemplatedMapProvider('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png')); 

    map.setCenterZoom(new MM.Location(center_lat, center_lon), 12);
        
    var incidents = data.incidents;
    var markers = [];
    var markerClip = new MarkerClip(map);
    
    for (var i = 0; i < data.incidents.length; i++){
        markers[i] = markerClip.createDefaultMarker();
        var location = new MM.Location(parseFloat(data.incidents[i].latitude), parseFloat(data.incidents[i].longitude));
        markers[i].title = data.incidents[i].description;
        markerClip.addMarker(markers[i],location);
    }
    
    //var container = document.getElementById('container');
    var maps = [];
    var markerClip2 = [];
    var markers2 = [];
    
    for (var i = 0; i < 6; i++){
        //var mapSize = new MM.Point(container.offsetWidth/3.1, container.offsetHeight/3.1);
        maps.push(new MM.Map('map'+i,new MM.TemplatedMapProvider('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png')));
        
        maps[i].setCenterZoom(new MM.Location(parseFloat(data.incidents[i].latitude), parseFloat(data.incidents[i].longitude)), 12);
        
        maps[i].maxSimultaneousRequests = 1;
        //maps[i].parent.style.position = 'relative';
        //maps[i].parent.style.left = ((i%3) * mapSize.x) + 'px';
        //maps[i].parent.style.top = Math.floor(i/3) * mapSize.y) + 'px';
        //maps[i].parent.style.height = 250 + 'px';
        //maps[i].parent.style.top = 250 + 'px';
        //maps[i].setCenterZoom(new MM.Location(37.77, -122.41),12);
        
        //handle the individual dots
        markerClip2[i] = new MarkerClip(maps[i]);
        markers2[i] = markerClip2[i].createDefaultMarker();
        var location2 = new MM.Location(parseFloat(data.incidents[i].latitude), parseFloat(data.incidents[i].longitude));
        markers2[i].title = data.incidents[i].description;
        markerClip2[i].addMarker(markers2[i],location);
    }
}

</script>

<style type="text/css">
body {
  background: #fff;
  color: #000;
  font-family: sans-serif;
  margin: 0;
  padding: 20px;
  border: 0;
}

.container {
    margin-left: -10px;
}

#map {
  width: 100%;
  height: 512px;
}

.page {
    width: 25%;
    height: 200px;
    border: 1px solid #000;
    float: center;
    margin: 10px;
    float: left;
}
</style>
</head>
    <body>
        <h1>Check your incidents</h1>
        <p>You have successfully uploaded your CSV. We have placed
        the location of each incident on separate maps.</p>
        <p>The first map displays the aggregate collection of your data. As you scroll down,
        you will see several smaller maps. Each individual incident is placed on its
        own map. Each map represents an individual field paper dedicated to a single
        incident.</p>
        <div id="map"></div>
        <!-- let's try 6  -->
        <div class="container">
            <div id="map0" class="page"></div>
            <div id="map1" class="page"></div>
            <div id="map2" class="page"></div>
        
            <div id="map3" class="page"></div>
            <div id="map4" class="page"></div>
            <div id="map5" class="page"></div>
        </div>
    </body>
</html>