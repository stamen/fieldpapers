<!DOCTYPE html>
<html>
<head>
    <title>Search - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript">
        {literal}
            var MM = com.modestmaps;
            
            function getPlaces(query)
            {
                var app_id = {/literal}'{$app_id}'{literal}
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'http://where.yahooapis.com/v1/places.q(' + escape(query) + ');count=1?format=json&callback=onPlaces&select=long&appid='+escape(app_id);
                document.body.appendChild(script);
                
                return false;
            }
            
            function onPlaces(result)
            {
                if (result['places'] && result['places']['place'] && result['places']['place'][0])
                {
                    var place = result['places']['place'][0];
                    
                    var bbox = place['boundingBox'];
                    var centroid = place['centroid'];
                    
                    var sw = new MM.Location(bbox['southWest']['latitude'], bbox['southWest']['longitude']);
                    var ne = new MM.Location(bbox['northEast']['latitude'], bbox['northEast']['longitude']);
                    var center = new MM.Location(centroid['latitude'], centroid['longitude']);
                    
                    var ne_point = document.getElementById("ne_point");
                    ne_point.value = [ne.lat,ne.lon];
                    
                    var sw_point = document.getElementById("sw_point");
                    sw_point.value = [sw.lat,sw.lon];
                    
                    var center_point = document.getElementById("center_point");
                    center_point.value = [center.lat,center.lon];
                    
                    console.log(center);
                    
                    document.forms['search-form'].submit();
                } else {
                    alert("We could not find that location.");
                }
            }
        
        {/literal}
    </script>
    <style type="text/css">
        {literal}
        body {
           background: #fff;
           color: #000;
           font-family: Helvetica, sans-serif;
           margin: 0;
           padding: 0px;
           border: 0;
        }
        
        #search-form {
            margin-left: 10px;
        }
        {/literal}
    </style>
</head>
    <body>
        {include file="navigation.htmlf.tpl"}
        <div class="container">
            <h1>Where would you like to center your atlas?</h1>
    
            <p>                                            
                <form id="search-form" onsubmit="return getPlaces(this.elements['query'].value);" action="{$base_dir}/make-atlas.php" method="get">
                    <input type="text" name="query" size="24" />
                    <input type="hidden" id="ne_point" name="ne" />
                    <input type="hidden" id="sw_point" name="sw" />
                    <input type="hidden" id="center_point" name="center" />
                    <input type="submit" name="action" value="Find" />
                </form>
            </p>
            {include file="footer.htmlf.tpl"}
        </div>
    </body>
</html>