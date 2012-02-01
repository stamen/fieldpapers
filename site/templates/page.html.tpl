<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Atlas/Page - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            <script>
                {literal}
                    $(document).ready(function() { 
                        var MM = com.modestmaps;
                        
                        var provider = '{/literal}{$scan.base_url}{literal}/{Z}/{X}/{Y}.jpg';
                        
                        var map = new MM.Map("map", new MM.TemplatedMapProvider(provider));
                        
                        var bounds = '{/literal}{$scan.geojpeg_bounds}{literal}';
                        bounds = bounds.split(',');
                        console.log(bounds);
                        var north = parseFloat(bounds[0]);
                        var west = parseFloat(bounds[1]);
                        var south = parseFloat(bounds[2]);
                        var east = parseFloat(bounds[3]);
                        
                        var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                        
                        map.setExtent(extents);
                        
                        map.setZoom(14);
                    });
                {/literal}
            </script>
            
            <div class="page_map" id="map"></div>
            <div class="fieldSet">
                <form action="{$base_dir}/fieldset.php?id={$scan.id}" method="post">
                    <div><span id="notes_title">Notes</span></div><br />
                    <textarea name="notes" id="notes" cols="45" rows="5"></textarea>
                    <div><input id="notes_submit" type="submit" value="Add Note" /></div>
                </form>
            </div>
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
        
    <!-- end .container --></div>
</body>
</html>