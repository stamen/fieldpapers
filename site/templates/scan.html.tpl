<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Atlas/Page - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/markerclip.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    {if $scan && !$scan.decoded && !$scan.failed}
        <meta http-equiv="refresh" content="5" />
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    {/if}
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            {if $scan && $scan.decoded}
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
                            
                            // marker
                            var markerClip = new MarkerClip(map);
                            
                            marker = markerClip.createDefaultMarker();
                            var location = new MM.Location(.5*(north+south),.5*(west+east));
                            markerClip.addMarker(marker,location);
                            
                            var mc_offset_width = .5*$('#map-markerClip').width();
                            var mc_offset_height = .5*$('#map-markerClip').height();
                            
                            $("#map-marker-0").mousedown(function(event) {
                                event.stopPropagation();
                                
                                $('#map-markerClip').mousemove(function(e){
                                    //e.stopPropagation();
                                    //console.log($(this).width());
                                    $('#map-marker-0').css({'left': (e.offsetX || e.layerX) - mc_offset_width + "px", 
                                            'top': (e.offsetY || e.layerY) - mc_offset_height + "px"});
                                }).mouseup(function(){
                                    //console.log(left,top);
                                    $(this).unbind('mousemove');
                                });
                            });
                            
                            
                            /*
                            document.getElementById("map-markerClip").onmousemove = function(e) {
                                console.log('hi');
                                document.getElementById("map-marker-0").style.top = e.layerY*1 + 5 + "px";
                                document.getElementById("map-marker-0").style.left = e.layerX*1 + 5 + "px";
                            }
                            */
                        });
                    {/literal}
                </script>
                
                <div class="page_map" id="map"></div>
                <p style="background-color: #000; text-align: center; color: #fff">
                    <b>Notes about this scan</b>
                    <br/><br/>
                    <pre>{$notes|@print_r:1|escape}</pre>
                </p>
                <div class="fieldSet">
                    {if $form.form_url}
                        <iframe style="margin-left: 20px; margin-top: 20px;" width="500px" 
                        height="450px" align="middle" frameborder="0"
                        src="{$form.form_url}">
                        </iframe>
                    {else}
                        <p>We could not find your form!</p>
                    {/if} 
                    <form action="{$base_dir}/fieldset.php?id={$scan.id}" method="post">
                        <div><span id="notes_title">Notes</span></div><br />
                        <textarea name="notes" id="notes" cols="45" rows="5"></textarea>
                        <div><input id="notes_submit" type="submit" value="Add Note" /></div>
                    </form>
                </div>
                
                {include file="footer.htmlf.tpl"}
            <!-- end .content --></div>
            
        <!-- end .container --></div>
    {elseif $scan}
        {include file="en/scan-process-info.htmlf.tpl"}
    {/if}
</body>
</html>