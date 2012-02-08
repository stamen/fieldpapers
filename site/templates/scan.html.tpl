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
                        var map;
                        
                        var bounds = '{/literal}{$scan.geojpeg_bounds}{literal}';
                        bounds = bounds.split(',');
                        console.log(bounds);
                        var north = parseFloat(bounds[0]);
                        var west = parseFloat(bounds[1]);
                        var south = parseFloat(bounds[2]);
                        var east = parseFloat(bounds[3]);
                        
                        var lat = .5*(north+south);
                        var lon = .5*(west+east);
                        
                        var originalPoint;
                        var newPoint;
                        
                        var markerNumber = 0;
                        
                        function addMarkerNote() {
                            var markerClip = new MarkerClip(map);
                            marker = markerClip.createDefaultMarker();
                            
                            var location = new MM.Location(lat,lon);
                            markerClip.addMarker(marker,location);
                            
                            $('#map-marker-0')
                            .append('<form action="{/literal}{$base_dir}{literal}/add-note.php?id={/literal}{$scan.id}{literal}" method="post">\
                                    <div style="float: left; width: 200px";><textarea name="note" id="notes" cols="30" rows="5"></textarea>\
                                    <input type="hidden" name="scan_id" value="{/literal}{$scan.id}{literal}"/>\
                                    <input type="hidden" id="input_lat" name="lat"/>\
                                    <input type="hidden" id ="input_lon" name="lon"/>\
                                    <input id="notes_submit" type="submit" value="Add Note" /></div>\
                                    </form>');
                            
                            var map_offset_width = .5*$('#map').width();
                            var map_offset_height = .5*$('#map').height();
                            
                            $("#map-marker-0").mousedown(function(event) {
                                event.stopPropagation();
                                
                                // get markerclip offset
                                var left_mc_offset = $('#map-markerClip').offset().left;
                                var top_mc_offset = $('#map-markerClip').offset().top;
                                
                                var map_left_offset = $('#map').offset().left;
                                var map_top_offset = $('#map').offset().top;
                                
                                var map_pan_x = originalPoint.x - newPoint.x;
                                var map_pan_y = originalPoint.y - newPoint.y;
                                
                                // 7 is the radius of the marker
                                $('#map-markerClip').mousemove(function(e){
                                     $('#map-marker-0').css({'left': e.pageX - left_mc_offset - map_offset_width + map_pan_x - 7 + "px", 
                                                            'top': e.pageY - top_mc_offset - map_offset_height + map_pan_y - 7 + "px"});
                                
                                }).mouseup(function(e){                                    
                                    var point = new MM.Point(e.pageX-left_mc_offset,e.pageY-top_mc_offset);
                                    var location = map.pointLocation(point);
                                    
                                    $('#input_lat').val(location.lat);
                                    $('#input_lon').val(location.lon);
                                    $(this).unbind('mousemove');
                                });
                            });
                                                        
                            markerNumber = markerNumber + 1;
                        }
                    
                        $(document).ready(function() { 
                            var MM = com.modestmaps;
                            
                            var provider = '{/literal}{$scan.base_url}{literal}/{Z}/{X}/{Y}.jpg';
                            
                            map = new MM.Map("map", new MM.TemplatedMapProvider(provider));
                            
                            var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                            
                            map.setExtent(extents);
                            map.setZoom(14);
                            
                            
                            originalPoint = map.locationPoint(new MM.Location(lat, lon));
                            
                            map.addCallback('drawn', function(m) {
                                // respond to new center:
                                //document.getElementById('info').innerHTML = m.getCenter().toString();
                                //console.log(m.getCenter().toString());
                                newPoint = map.locationPoint(new MM.Location(lat, lon));
                            });
                        });
                    {/literal}
                </script>
                
                <div class="page_map" id="map"></div>
                <!--
                <p style="background-color: #000; text-align: center; color: #fff">
                    <b>Notes about this scan</b>
                    <br/><br/>
                    <pre>{$notes|@print_r:1|escape}</pre>
                </p>
                -->
                <div class="fieldSet">
                    {if $form.form_url}
                        <iframe style="margin-left: 20px;" width="500px" 
                        height="450px" align="middle" frameborder="0"
                        src="{$form.form_url}">
                        </iframe>
                    {else}
                        <p>We could not find your form!</p>
                    {/if}
                    
                    <div>
                        <button style='float: left; margin-left: 20px; 
                                margin-top: 20px;' type="button" 
                                onClick= "addMarkerNote()">
                        Add Incident
                        </button>
                    </div>
                    
                    <!--
                    <form action="{$base_dir}/add-note.php?id={$scan.id}" method="post">
                        <div><span id="notes_title">Notes</span></div>
                        <div style='float: left; width: 200px';><textarea name="note" id="notes" cols="45" rows="5"></textarea>
                        
                        <input type='hidden' name='scan_id' value='{$scan.id}'/>
                        <input type='hidden' id='input_lat' name='lat'/>
                        <input type='hidden' id ='input_lon' name='lon'/>
                        
                        <input id="notes_submit" type="submit" value="Add Note" /></div>
                    </form>
                    -->
                </div>
                
                {include file="footer.htmlf.tpl"}
            <!-- end .content --></div>
            
        <!-- end .container --></div>
    {elseif $scan}
        {include file="en/scan-process-info.htmlf.tpl"}
    {/if}
</body>
</html>