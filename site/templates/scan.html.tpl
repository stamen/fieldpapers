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

	{include file="navigation.htmlf.tpl"}
        <div class="container">
        
            {if $scan && $scan.decoded}
            
                <p>
                	<div class="buttonBar">
                        <button type="button" onClick= "addMarkerNote()">Add Note</button>
                    </div>
                    <h4>
                        Uploaded by <a href="person.php">[user_name]</a>, <a href="time.php">[nice_relativetime|escape]</a><br />
                        <b>Page 1</b>, Atlas <a href="atlas.php">235grth</a>, Adelaide, Australia
                    </h4>
                </p>
            
                <div class="mapFormHolder">
    
                    {if $form.form_url}
                        <div class="fieldSet">
                            <iframe align="middle" frameborder="0" src="{$form.form_url}"></iframe>
                        </div>
                    {/if}
    
                    <div class="page_map" id="map"></div>
                    
                <form id="scan-form" action="{$base_dir}/save-scan-notes.php?scan_id={$scan.id}" method="POST">
                    <input id="notes_submit" type="submit" value="Submit" />
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
                        img.src = 'img/icon_x_mark_new.png';
                        div.appendChild(img);
                        
                        var br = document.createElement('br');
                        div.appendChild(br);
                        
                        var textarea = document.createElement('textarea');
                        textarea.id = "notes";
                        textarea.name = 'marker[' + markerNumber + '][note]';
                        textarea.className = 'show';
                        div.appendChild(textarea);
                        
                        var removeMarkerNote = function()
                        {                                                        
                            div.parentNode.removeChild(div);
                        }
                        
                        var remove_button = document.createElement('button');
                        remove_button.id = 'remove_new';
                        remove_button.innerHTML = 'Remove New Note';
                        remove_button.className = 'show';
                        remove_button.onclick = removeMarkerNote;
                        div.appendChild(remove_button);
                        
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
                        
                        var mousemove = false;
                        
                        img.onmousedown = function(e)
                        {
                            var marker_start = {x: div.offsetLeft, y: div.offsetTop},
                                mouse_start = {x: e.clientX, y: e.clientY};
                            
                            mousemove = false;
                            
                            document.onmousemove = function(e)
                            {
                                if (e.type =='mousemove')
                                {
                                    mousemove = true;
                                }
                                
                                var mouse_now = {x: e.clientX, y: e.clientY};
                            
                                div.style.left = (marker_start.x + mouse_now.x - mouse_start.x) + 'px';
                                div.style.top = (marker_start.y + mouse_now.y - mouse_start.y) + 'px';
                            }
                            
                            return false;
                        }
                        
                        var marker = this;
                        
                        img.onmouseup = function(e)
                        {
                            if (!mousemove)
                            {
                                if (textarea.className == 'hide' && remove_button.className == 'hide') 
                                {
                                    textarea.className = 'show';
                                    remove_button.className = 'show';
                                } else if (textarea.className == 'show' && remove_button.className == 'show') {
                                    textarea.className = 'hide';
                                    remove_button.className = 'hide';
                                }
                            }
                            
                            mousemove = false;
                        
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
                        var markerDiv = new MarkerNote(map);
                        document.getElementById('scan-form').appendChild(markerDiv);
                    }
                    
                    function SavedMarker(map,note,note_num,lat,lon)
                    {
                        this.location = new MM.Location(lat,lon);
                                              
                        var div = document.createElement('div');
                        div.className = 'marker';
                        
                        var img = document.createElement('img');
                        img.src = 'img/icon_x_mark.png';
                        div.appendChild(img);
                        
                        div.title = note;
                        
                        var br = document.createElement('br');
                        div.appendChild(br);
                        
                        var textarea = document.createElement('textarea');
                        textarea.id = "notes";
                        textarea.value = note;
                        textarea.name = 'marker[' + unsignedMarkerNumber + '][note]';
                        textarea.className = 'hide';
                        div.appendChild(textarea);
                        
                        var removeMarkerNote = function()
                        {                            
                            // Remove visual elements
                            div.removeChild(img);
                            div.removeChild(textarea);
                            div.removeChild(remove_button);
                            
                            removed.value = 1; // Removed
                        }
                        
                        var remove_button = document.createElement('button');
                        remove_button.id = 'remove';
                        remove_button.innerHTML = 'Remove Saved Note';
                        remove_button.className = 'hide';
                        remove_button.onclick = removeMarkerNote;
                        div.appendChild(remove_button);
                        
                        // Add a flag that the note was removed
                        var removed = document.createElement('input');
                        removed.value = 0; // Not removed
                        removed.type = 'hidden';
                        removed.name = 'marker[' + unsignedMarkerNumber + '][removed]';
                        div.appendChild(removed);
                        
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
                        
                        img.onmouseover = function(e)
                        {
                            img.src = 'img/icon_x_mark_hover.png';
                        }
                        
                        img.onmouseout = function(e)
                        {
                            img.src = 'img/icon_x_mark.png';
                        }
                        
                        var mousemove = false;
                        
                        img.onmousedown = function(e)
                        {
                            var marker_start = {x: div.offsetLeft, y: div.offsetTop},
                                mouse_start = {x: e.clientX, y: e.clientY};
                                                        
                            mousemove = false;                    
                                    
                            document.onmousemove = function(e)
                            {
                                if (e.type =='mousemove')
                                {
                                    mousemove = true;
                                }
                                
                                var mouse_now = {x: e.clientX, y: e.clientY};
                            
                                div.style.left = (marker_start.x + mouse_now.x - mouse_start.x) + 'px';
                                div.style.top = (marker_start.y + mouse_now.y - mouse_start.y) + 'px';
                            }
                            
                            return false;
                        }
                        
                        var marker = this;
                        
                        img.onmouseup = function(e)
                        {
                            if (!mousemove)
                            {
                                if (textarea.className == 'hide' && remove_button.className == 'hide') 
                                {
                                    textarea.className = 'show';
                                    remove_button.className = 'show';
                                } else if (textarea.className == 'show' && remove_button.className == 'show') {
                                    textarea.className = 'hide';
                                    remove_button.className = 'hide';
                                }
                            }
                            
                            mousemove = false;
                            
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
                            var note = '{/literal}{$note.note|escape}{literal}',
                            //var note = {/literal}{$note.note|@json_encode}{literal},
                                note_num = {/literal}{$note.note_number}{literal},
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
                    map.setZoom(14);
                    
                    displaySavedNotes();
                        
                // {/literal}]]>
                </script>                    
                    
                
                </div>
                
            {elseif $scan}
                {include file="en/scan-process-info.htmlf.tpl"}
            {/if}
            {include file="footer.htmlf.tpl"}
        </div>




<!-- Hide for a secondo                    
        
            {if $scan && $scan.decoded}
                <p>
                	<div class="buttonBar">
                        <div>
                            <button type="button" onClick= "addMarkerNote()">Add Note</button>
                        </div>                    
                    </div>
                
                    <small>
                        Uploaded by <a href="person.php">[user_name]</a>, <a href="time.php">[nice_relativetime|escape]</a><br />
                        <b>Page 1</b>, Atlas <a href="atlas.php">235grth</a>, Adelaide, Australia
                    </small>
                </p>
                <div class="fieldSet">
                    {if $form.form_url}
                        <iframe align="middle" frameborder="0" src="{$form.form_url}"></iframe>
                    {else}
                        <div style="float: left; margin-left: 20px">There are no forms associated with this scan.</div>
                    {/if}
                </div>            
            
                <div class="page_map" id="map"></div>
                
    {elseif $scan}
        {include file="en/scan-process-info.htmlf.tpl"}
    {/if}
        {include file="footer.htmlf.tpl"}
    </div>
-->
    
</body>
</html>