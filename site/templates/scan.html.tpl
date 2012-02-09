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
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        #scan-form,
        #scan-form .marker
        {
            position: absolute;
        }
        
        #scan-form .marker img
        {
            cursor: pointer;
        }
        
    /* {/literal}]]> */
</style>
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            {if $scan && $scan.decoded}
                <div class="page_map" id="map"></div>

                <form id="scan-form" action="{$base_dir}/save-scan-notes.php" method="POST">
                    <!--<input id="notes_submit" type="submit" value="Submit" />-->
                </form>

                <script type="text/javascript">
                // <![CDATA[{literal}    
                    var markerNumber = -1;
                    
                    var unsignedMarkerNumber = 1;                    

                    function MarkerNote(map)
                    {
                        this.location = map.getCenter();
                                                
                        var div = document.createElement('div');
                        div.className = 'marker';
                        
                        var img = document.createElement('img');
                        img.src = 'img/eye.png';
                        div.appendChild(img);
                        
                        var br = document.createElement('br');
                        div.appendChild(br);
                        
                        var textarea = document.createElement('textarea');
                        textarea.id = "notes";
                        textarea.name = 'marker[' + markerNumber + '][note]';
                        div.appendChild(textarea);
                        
                        var input_lat = document.createElement('input');
                        input_lat.value = this.location.lat.toFixed(6);
                        input_lat.type = 'hidden';
                        input_lat.name = 'marker[' + markerNumber + '][lat]';
                        div.appendChild(input_lat);
                        
                        var input_lon = document.createElement('input');
                        input_lon.value = this.location.lon.toFixed(6);
                        input_lon.type = 'hidden';
                        input_lon.name = 'marker[' + markerNumber + '][lon]';
                        div.appendChild(input_lon);
                        
                        var scan_id = document.createElement('input');
                        scan_id.value = {/literal}'{$scan.id}'{literal}
                        scan_id.name = 'marker[' + markerNumber + '][scan_id]';
                        scan_id.type = 'hidden';
                        div.appendChild(scan_id);
                        
                        markerNumber--;
                        
                        // make it easy to drag
                        
                        img.onmousedown = function(e)
                        {
                            var marker_start = {x: div.offsetLeft, y: div.offsetTop},
                                mouse_start = {x: e.clientX, y: e.clientY};
                            
                            document.onmousemove = function(e)
                            {
                                var mouse_now = {x: e.clientX, y: e.clientY};
                            
                                div.style.left = (marker_start.x + mouse_now.x - mouse_start.x) + 'px';
                                div.style.top = (marker_start.y + mouse_now.y - mouse_start.y) + 'px';
                            }
                            
                            return false;
                        }
                        
                        var marker = this;
                        
                        img.onmouseup = function(e)
                        {
                            var marker_end = {x: div.offsetLeft, y: div.offsetTop};
                            
                            marker.location = map.pointLocation(marker_end);
                            input_lat.value = marker.location.lat.toFixed(6);
                            input_lon.value = marker.location.lon.toFixed(6);
                        
                            document.onmousemove = null;
                            return false;
                        }
                        
                        // add it to the map
                        
                        var updatePosition = function()
                        {
                            var point = map.locationPoint(marker.location);
                            
                            div.style.left = point.x + 'px';
                            div.style.top = point.y + 'px';
                        }
                        
                        map.addCallback('panned', updatePosition);
                        map.addCallback('zoomed', updatePosition);
                        updatePosition();
                        
                        return div;
                    }
                    
                    function addMarkerNote()
                    {
                        // Remember previous note
                        //console.log(document.getElementById('scan-form').elements['notes'][0].value);
                        //notes.push(document.getElementById('scan-form'));
                        
                        var markerDiv = new MarkerNote(map);
                        document.getElementById('scan-form').appendChild(markerDiv);
                    }
                    
                    function SavedMarker(map,note,note_num,lat,lon)
                    {
                        //this.location = map.getCenter();
                        this.location = new MM.Location(lat,lon);
                                              
                        var div = document.createElement('div');
                        div.className = 'marker';
                        
                        var img = document.createElement('img');
                        img.src = 'img/eye.png';
                        div.appendChild(img);
                        
                        div.title = note;
                        
                        var br = document.createElement('br');
                        div.appendChild(br);
                        
                        var textarea = document.createElement('textarea');
                        textarea.id = "notes";
                        textarea.value = note;
                        textarea.name = 'marker[' + unsignedMarkerNumber + '][note]';
                        div.appendChild(textarea);
                        
                        var input_lat = document.createElement('input');
                        input_lat.value = this.location.lat.toFixed(6);
                        input_lat.type = 'hidden';
                        input_lat.name = 'marker[' + unsignedMarkerNumber + '][lat]';
                        div.appendChild(input_lat);
                        
                        var input_lon = document.createElement('input');
                        input_lon.value = this.location.lon.toFixed(6);
                        input_lon.type = 'hidden';
                        input_lon.name = 'marker[' + unsignedMarkerNumber + '][lon]';
                        div.appendChild(input_lon);
                        
                        var note_number = document.createElement('input');
                        note_number.value = note_num;
                        note_number.name = 'marker[' + unsignedMarkerNumber + '][note_number]';
                        note_number.type = 'hidden';
                        div.appendChild(note_number);
                        
                        var scan_id = document.createElement('input');
                        scan_id.value = {/literal}'{$scan.id}'{literal};
                        scan_id.name = 'marker[' + unsignedMarkerNumber + '][scan_id]';
                        scan_id.type = 'hidden';
                        div.appendChild(scan_id);
                        
                        unsignedMarkerNumber++;
                        
                        img.onmousedown = function(e)
                        {
                            var marker_start = {x: div.offsetLeft, y: div.offsetTop},
                                mouse_start = {x: e.clientX, y: e.clientY};
                            
                            /*
                            if (!document.getElementsByName('marker['+ unsignedMarkerNumber + '][note]'))
                            {
                                var textarea = document.createElement('textarea');
                                textarea.id = "notes";
                                textarea.value = note;
                                textarea.name = 'marker[' + unsignedMarkerNumber + '][note]';
                                div.appendChild(textarea);
                            }
                            */
                            
                            document.onmousemove = function(e)
                            {
                                var mouse_now = {x: e.clientX, y: e.clientY};
                            
                                div.style.left = (marker_start.x + mouse_now.x - mouse_start.x) + 'px';
                                div.style.top = (marker_start.y + mouse_now.y - mouse_start.y) + 'px';
                            }
                            
                            return false;
                        }
                        
                        var marker = this;
                        
                        img.onmouseup = function(e)
                        {
                            var marker_end = {x: div.offsetLeft, y: div.offsetTop};
                            
                            marker.location = map.pointLocation(marker_end);
                            input_lat.value = marker.location.lat.toFixed(6);
                            input_lon.value = marker.location.lon.toFixed(6);
                        
                            document.onmousemove = null;
                            return false;
                        }
                                        
                        var initialPosition = function()
                        {
                            var point = map.locationPoint(new MM.Location(lat,lon));
                            marker.location = new MM.Location(lat,lon);
                            
                            div.style.left = point.x + 'px';
                            div.style.top = point.y + 'px';
                        }
                        
                        var updatePosition = function()
                        {
                            var point = map.locationPoint(marker.location);
                            
                            div.style.left = point.x + 'px';
                            div.style.top = point.y + 'px';
                        }
                        
                        map.addCallback('panned', updatePosition);
                        map.addCallback('zoomed', updatePosition);
                        initialPosition();
                        
                        return div;
                    }
                    
                    function addSavedNote(note,note_num,lat,lon)
                    {
                        var saved_marker = new SavedMarker(map,note,note_num,lat,lon);
                        document.getElementById('scan-form').appendChild(saved_marker);
                    }
                    
                    function displaySavedNotes() {
                        {/literal}{foreach from=$notes item="note"}{literal}
                            var note = '{/literal}{$note.note}{literal}',
                                note_num = '{/literal}{$note.note_number}{literal}',
                                lat = {/literal}{$note.latitude}{literal},
                                lon = {/literal}{$note.longitude}{literal};
                            
                            console.log(note,note_num,lat,lon);
                            addSavedNote(note,note_num,lat,lon);
                        {/literal}{/foreach}{literal}
                    }
                
                    var MM = com.modestmaps,
                        provider = '{/literal}{$scan.base_url}{literal}/{Z}/{X}/{Y}.jpg',
                        map = new MM.Map("map", new MM.TemplatedMapProvider(provider)),
                        bounds = '{/literal}{$scan.geojpeg_bounds}{literal}'.split(','),
                        north = parseFloat(bounds[0]),
                        west = parseFloat(bounds[1]),
                        south = parseFloat(bounds[2]),
                        east = parseFloat(bounds[3]),
                        extents = [new MM.Location(north, west), new MM.Location(south, east)];
                    
                    map.setExtent(extents);
                    map.zoomIn();
                    
                    displaySavedNotes();
                        
                // {/literal}]]>
                </script>
                
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
                        Add Note
                        </button>
                    </div>
                    
                    <div>
                        <button style='float: left; margin-left: 20px; 
                                margin-top: 20px;' type="button" 
                                onClick= "document.getElementById('scan-form').submit();">
                        Submit Notes
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