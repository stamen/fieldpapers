<!DOCTYPE html>
<html>
<head>
    <title>Search</title>
    <script type="text/javascript" src="modestmaps.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    
    <script type="text/javascript">
        {literal}
            var MM = com.modestmaps;
            
            function getPlaces(query)
            {
                var app_id = {/literal}'{$app_id}'{literal}
                //console.log('get places');
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'http://where.yahooapis.com/v1/places.q(' + escape(query) + ');count=1?format=json&callback=onPlaces&select=long&appid='+escape(app_id);
                document.body.appendChild(script);
                
                
                //var form = document.forms['bounds'];
                
                console.log(app_id);
                
                return false;
            }
            
            function onPlaces(result)
            {
                if (result['places'] && result['places']['place'] && result['places']['place'][0])
                {
                    var place = result['places']['place'][0];
                    
                    //console.log(place);
                    var bbox = place['boundingBox'];
                    var centroid = place['centroid'];
                    
                    var sw = new MM.Location(bbox['southWest']['latitude'], bbox['southWest']['longitude']);
                    var ne = new MM.Location(bbox['northEast']['latitude'], bbox['northEast']['longitude']);
                    var center = new MM.Location(centroid['latitude'], centroid['longitude']);
                    
                    //console.log(sw,ne);
                    
                    var ne_point = document.getElementById("ne_point");
                    //console.log(ne);
                    ne_point.value = [ne.lat,ne.lon];
                    
                    var sw_point = document.getElementById("sw_point");
                    sw_point.value = [sw.lat,sw.lon];
                    
                    var center_point = document.getElementById("center_point");
                    center_point.value = [center.lat,center.lon];
                    
                    console.log(center);
                    
                    document.forms['search-form'].submit();
                } else {
                    alert("Could not find.");
                }
            }
        
        {/literal}
    </script>
    <style type="text/css">
        {literal}
        h1 {
           margin-left: 20px;
        }
        
        body {
           background: #fff;
           color: #000;
           font-family: Helvetica, sans-serif;
           margin: 0;
           padding: 0px;
           border: 0;
        }
        
        #search-form {
            margin-left: 20px;
        }
        
        {/literal}
    </style>
</head>
    <body>
        <h1>Where would you like to center your atlas?</h1>

        <p>                                            
            <form id="search-form" onsubmit="return getPlaces(this.elements['query'].value);" action="http://fieldpapers.org/~mevans/fieldpapers/site/www/atlas-box-ui/new-box-ui.php" method="get">
                <!-- Place into init.php -->
                <input type="text" name="query" size="24" />
                <input type="hidden" id="ne_point" name="ne" />
                <input type="hidden" id="sw_point" name="sw" />
                <input type="hidden" id="center_point" name="center" />
                <input type="submit" name="action" value="Find" />
            </form>
        </p>
        <p>
            <a href="#" id="permalink"></a>
        </p>
    </body>
</html>