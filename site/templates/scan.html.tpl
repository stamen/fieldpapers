<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>
        {if $page_number && $scan.print_id}
            Page {$page_number}, Atlas {$scan.print_id}
        {/if}
         - fieldpapers.org
    </title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    {if $scan && !$scan.decoded && !$scan.failed}
        <meta http-equiv="refresh" content="5">
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/reqwest.min.js"></script>
    {/if}
        <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        #map
        {
            background-color: black;
        }
    
        #scan-form,
        #scan-form .marker
        {
            position: absolute;
        }
        
        #scan-form .marker img
        {
            cursor: move;
        }
        
        .hide {
            display: none;
        }
        
        .show {
            display: block;
        }
        
        #notes {
            margin: 0;
        }
        
        #remove, #remove_new, #ok, #ok_new, #cancel {
            float: left;
        }
        
        #saved_note {
            background-color: white;
            margin: 2px;
            padding: 10px;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-weight: normal;
            font-size: .8em;
            width: 100px;
        }
        
    /* {/literal}]]> */
</style>

</head>
<body> 

	{include file="navigation.htmlf.tpl"}
        <div class="container">
        
            {if $scan && $scan.decoded}
            
                <p>
                	<div class="buttonBar">
                        <button type="button" onClick= "addMarkerNote()">Add Note</button>
                    </div>
                    <p>
                        Uploaded by <a href="person.php?id={$scan.user_id}">{$user.name}</a>, 
                        <a href="uploads.php?month={"Y-m"|@date:$scan.created}">{$scan.age|nice_relativetime|escape}</a><br>
                        {if $page_number}
                            <b>Page {$page_number}<b>,
                        {/if}
                        
                        {if $scan.print_id && $print}
                            Atlas <a href="print.php?id={$scan.print_id}{if $scan.print_page_number}%2F{$scan.print_page_number}{/if}">{$scan.print_id}</a>
                        {elseif $scan.print_href}
                            Atlas from <a href="{$scan.print_href|escape}">{$scan.print_href|nice_domainname|escape}</a>
                        {else}
                            Atlas from ???
                        {/if}
                        
                        
                        {if $scan.place_woeid}
                            <a href="{$base_dir}/uploads.php?place={$scan.place_woeid}">{$scan.place_name|nice_placename}</a>,
                        {/if}
                        <a href="{$base_dir}/uploads.php?place={$scan.country_woeid}">{$scan.country_name|nice_placename}</a>
                    </p>
                </p>
            
                {if $form.form_url}

                    <div class="mapFormHolder">
                        <div class="fieldSet">
                            <iframe align="middle" frameborder="0" src="{$form.form_url}"></iframe>
                        </div>
                        <div class="page_map small" id="map"></div>
                    </div>
                    
				{else}

                    <div class="page_map large" id="map"></div>
                                
                {/if}

    
                    
                <form id="scan-form">
                </form>

                <script type="text/javascript">
                // <![CDATA[{literal}    
                    String.prototype.trim = function() {
                        return this.replace(/^\s+|\s+$/g,"");
                    }
                        
                    var markerNumber = -1;
                    
                    var unsignedMarkerNumber = 1;
                    
                    var post_url = '{/literal}{$base_dir}{literal}/save-scan-notes.php?scan_id={/literal}{$scan.id}{literal}';               

                    function MarkerNote(map, post_url)
                    {
                        this.location = map.getCenter();
                        
                        var data = this.data = {
                            'lat': this.location.lat,
                            'lon': this.location.lon,
                            'marker_number': markerNumber,
                            'note': ''
                        };
                        
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
                        //textarea.value = ''; // ?
                        textarea.name = 'marker[' + markerNumber + '][note]';
                        textarea.className = 'show';
                        div.appendChild(textarea);
                        
                        textarea.onchange = function () { 
                            data.note = this.value; 
                        };
                                                       
                        var submitNote = function()
                        {
                            //console.log(document.getElementById('scan-form'));
                            if (textarea.value.trim() == ''){
                                alert('Please fill out your note!');
                                return false;
                            } else {
                                console.log(data);
                                console.log(post_url);
                                
                                reqwest({
                                    url: post_url,
                                    method: 'post',
                                    data: data,
                                    type: 'json',
                                    success: function (resp) {
                                      console.log(resp);
                                    }
                                });
                                
                                return false; 
                            }
                        }
                        
                        var removeMarkerNote = function()
                        {                                                        
                            div.parentNode.removeChild(div);
                        }
                        
                        var ok_button = document.createElement('button');
                        ok_button.id = 'ok_new';
                        ok_button.innerHTML = 'OK';
                        ok_button.className = 'show';
                        ok_button.onclick = submitNote;
                        div.appendChild(ok_button);
                        
                        var remove_button = document.createElement('button');
                        remove_button.id = 'remove_new';
                        remove_button.innerHTML = 'Cancel';
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
                            if (textarea.className == 'hide' && remove_button.className == 'hide' && ok_button.className == 'hide') 
                            {
                                textarea.className = 'show';
                                remove_button.className = 'show';
                                ok_button.className = 'show';
                            } 
                                                       
                            var marker_end = {x: div.offsetLeft, y: div.offsetTop};
                            
                            marker.location = map.pointLocation(marker_end);
                            //input_lat.value = marker.location.lat.toFixed(6);
                            //input_lon.value = marker.location.lon.toFixed(6);
                            
                            data.lat = marker.location.lat.toFixed(6);
                            data.lon = marker.location.lon.toFixed(6);
                        
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
                        var markerDiv = new MarkerNote(map, post_url);
                        document.getElementById('scan-form').appendChild(markerDiv);
                    }
                                        
                    function SavedMarker(map,note,note_num,lat,lon)
                    {
                        this.location = new MM.Location(lat,lon);
                        
                        var data = this.data = {
                            'lat': parseFloat(lat),
                            'lon': parseFloat(lon),
                            'marker_number': unsignedMarkerNumber,
                            'note': note
                        };
                                              
                        var div = document.createElement('div');
                        div.className = 'marker';
                        
                        var img = document.createElement('img');
                        img.src = 'img/icon_x_mark.png';
                        div.appendChild(img);
                        
                        //div.title = note;
                        
                        var br = document.createElement('br');
                        div.appendChild(br);
                        
                        var saved_note = document.createElement('span');
                        saved_note.id = "saved_note";
                        saved_note.innerHTML = note;
                        saved_note.className = 'hide';
                        div.appendChild(saved_note);
                        
                        var textarea = document.createElement('textarea');
                        textarea.id = "notes";
                        textarea.value = note;
                        textarea.name = 'marker[' + unsignedMarkerNumber + '][note]';
                        textarea.className = 'hide';
                        textarea.style.width = '180px';
                        //textarea.style.height = '200px';
                        div.appendChild(textarea);
                        
                        textarea.onchange = function () { 
                            data.note = this.value; 
                        };
                        
                        var removeMarkerNote = function()
                        {                            
                            if (window.confirm("Are you sure you want to delete this saved note?"))
                            {
                                // Remove visual elements
                                /*
                                div.removeChild(img);
                                div.removeChild(textarea);
                                div.removeChild(ok_button);
                                div.removeChild(cancel_button);
                                div.removeChild(remove_button);
                                */
                                
                                div.parentNode.removeChild(div);
                                
                                data.removed = 1; // Removed
                                
                                submitNote();
                            } else {
                                return false;
                            }
                        }
                        
                        var resetNote = function()
                        {
                            var orig_point = map.locationPoint(new MM.Location(lat,lon));
                            marker.location = new MM.Location(lat,lon);
                        
                            div.style.left = orig_point.x + 'px';
                            div.style.top = orig_point.y + 'px';
                            
                            textarea.value = note;
                            
                            if (textarea.className == 'show' && remove_button.className == 'show' && ok_button.className == 'show' && cancel_button.className == 'show') {
                                textarea.className = 'hide';
                                ok_button.className = 'hide';
                                cancel_button.className = 'hide';
                                remove_button.className = 'hide';
                            }
                            
                            return false;
                        }
                        
                        var submitNote = function()
                        {
                            console.log('data', data);
                            reqwest({
                                url: post_url,
                                method: 'post',
                                data: data,
                                type: 'json',
                                success: function (resp) {
                                  console.log('response',resp);
                                  
                                  changeMarkerDisplay(resp);
                                }
                            });
                            
                            
                            
                            return false;
                        }
                        
                        var changeMarkerDisplay = function(resp)
                        {
                            if (textarea.className == 'show' && remove_button.className == 'show' && ok_button.className == 'show' && cancel_button.className == 'show') {
                                textarea.className = 'hide';
                                ok_button.className = 'hide';
                                cancel_button.className = 'hide';
                                remove_button.className = 'hide';
                            }
                        
                            saved_note.innerHTML = resp.note_data.note;
                            textarea.value = resp.note_data.note;
                        }
                                              
                        var ok_button = document.createElement('button');
                        ok_button.id = 'ok';
                        ok_button.innerHTML = 'OK';
                        ok_button.className = 'hide';
                        ok_button.onclick = submitNote;
                        div.appendChild(ok_button);
                        
                        var cancel_button = document.createElement('button');
                        cancel_button.id = 'cancel';
                        cancel_button.innerHTML = 'Cancel';
                        cancel_button.className = 'hide';
                        cancel_button.onclick = resetNote;
                        div.appendChild(cancel_button);
                        
                        var remove_button = document.createElement('button');
                        remove_button.id = 'remove';
                        remove_button.innerHTML = 'Delete';
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
                            
                            if (textarea.className == 'hide' && ok_button.className == 'hide' && remove_button.className == 'hide' && cancel_button.className == 'hide')
                            {
                                saved_note.className = 'show';
                            }
                        }
                        
                        img.onmouseout = function(e)
                        {
                            img.src = 'img/icon_x_mark.png';
                            
                            if (saved_note.className = 'show')
                            {
                                saved_note.className = 'hide';
                            }
                        }
                                                
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
                            
                            if (textarea.className == 'hide' && ok_button.className == 'hide' && remove_button.className == 'hide' && cancel_button.className == 'hide') 
                            {
                                if (saved_note.className = 'show')
                                {
                                    saved_note.className = 'hide';
                                }
                            
                                textarea.className = 'show';
                                ok_button.className = 'show';
                                cancel_button.className = 'show';
                                remove_button.className = 'show';
                            }
                            
                            return false;
                        }
                        
                        var marker = this;
                        
                        img.onmouseup = function(e)
                        {                            
                            var marker_end = {x: div.offsetLeft, y: div.offsetTop};
                            
                            marker.location = map.pointLocation(marker_end);
                            //input_lat.value = marker.location.lat.toFixed(6);
                            //input_lon.value = marker.location.lon.toFixed(6);
                            data.lat = marker.location.lat.toFixed(6);
                            data.lon = marker.location.lon.toFixed(6);
                        
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
                        var saved_marker = new SavedMarker(map, note,note_num,lat,lon);
                        document.getElementById('scan-form').appendChild(saved_marker);
                    }
                    
                    function displaySavedNotes() {
                        {/literal}{foreach from=$notes item="note"}{literal}
                            var note = {/literal}{$note.note|@json_encode}{literal},
                                note_num = {/literal}{$note.note_number}{literal},
                                lat = {/literal}{$note.latitude}{literal},
                                lon = {/literal}{$note.longitude}{literal};
                            
                            console.log(note,note_num,lat,lon);
                            addSavedNote(note,note_num,lat,lon);
                        {/literal}{/foreach}{literal}
                    }
                
                    var MM = com.modestmaps,
                        provider = '{/literal}{$scan.base_url}{literal}/{Z}/{X}/{Y}.jpg',
                        map = new MM.Map("map", new MM.TemplatedMapProvider(provider), null, [new MM.DragHandler(), new MM.DoubleClickHandler()]),
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
                    
                
                </div>
                
            {elseif $scan}
                {include file="en/scan-process-info.htmlf.tpl"}
            {/if}
            {include file="footer.htmlf.tpl"}
        </div>
    
</body>
</html>