<?php 
    session_start();
    $json_path = $_SESSION['json_file_path'];
?>

<!DOCTYPE html>
<html>
<head>
    <title>CSV Points</title>
    <style type="text/css">
        @import url('css/style.css');
    </style>
    <script type="text/javascript" src="../modest_maps/modestmaps.min.js"></script>
    <script type="text/javascript" src="../modest_maps/markerclip.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript">
        var paper_sizes = {Letter:{width: 7.5,height: 9.5}, A4: {width: 7.268,height:10.1929},A3:{width:10.6929,height:15.0354}},
            factor = 20,
            maps = [];
    
        $(document).ready(function(){
            var json_path = '<?php echo $json_path ?>';
            $.getJSON(json_path, createDisplay);
        });
    
        function changeAspectRatio() {
            var value = $("select#paper_size").val();
            var paper_width,
                paper_height;
        
            if (value == "Letter") {
                paper_width = 7.5;
                paper_height = 9.5;
            } else if (value == "A4") {
                paper_width = 7.268;
                paper_height = 10.1929;      
            } else if (value == "A3") {
                paper_width = 10.6929;
                paper_height = 15.0354;
            }
                        
            for (var i = 0; i < maps.length; i++) {
                maps[i].parent.style.width = factor * paper_width + "px";
                maps[i].parent.style.height = factor * paper_height + "px";
            }
        }
    
        function createDisplay(data) {
            var center_lat = 37.77,
                center_lon = -122.41;
            var provider = new MM.TemplatedMapProvider('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png');
            
            // Set up the main map
            var map = new MM.Map('map', provider); 
            map.setCenterZoom(new MM.Location(center_lat, center_lon), 12);
            
            var markers = [];
            var markerClip = new MarkerClip(map);
            
            for (var i = 0; i < data.incidents.length; i++){
                markers[i] = markerClip.createDefaultMarker();
                var location = new MM.Location(parseFloat(data.incidents[i].latitude), parseFloat(data.incidents[i].longitude));
                markers[i].title = data.incidents[i].description;
                markerClip.addMarker(markers[i],location);
            }
            
            // Set up the individual maps
            var pages_container = document.getElementById('pages_container');
            var markerClip2 = [];
            var markers2 = [];
            
            for (var i = 0; i < data.incidents.length; i++){
        
                var map_page = document.createElement('div');
                var map_id = 'map' + i;
                map_page.setAttribute('id', map_id);
                map_page.setAttribute('class', 'page');
                pages_container.appendChild(map_page);
                
                maps.push(new MM.Map('map'+ i,provider));
                maps[i].setCenterZoom(new MM.Location(parseFloat(data.incidents[i].latitude), parseFloat(data.incidents[i].longitude)), 12);
                maps[i].maxSimultaneousRequests = 1;
                
                // Handle the individual dots
                markerClip2[i] = new MarkerClip(maps[i]);
                markers2[i] = markerClip2[i].createDefaultMarker();
                var location2 = new MM.Location(parseFloat(data.incidents[i].latitude), parseFloat(data.incidents[i].longitude));
                markers2[i].title = data.incidents[i].description;
                markerClip2[i].addMarker(markers2[i],location2);
            }
            
            $("select#paper_size").change(changeAspectRatio);
        }
</script>
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
        <div style="margin-top:20px">
            Aspect ratio:
            <label for="paper-size"><select id="paper_size">
                <option value="Letter">Letter</option>
                <option value="A3">A3</option>
                <option value="A4">A4</option>
            </select></label>
            <div id="pages_container">
                <div id="map_page"></div>
            </div>
        </div>
    </body>
</html>