var active_marker = false;

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
    
    //var br = document.createElement('br');
    //div.appendChild(br);
    
    var textarea = document.createElement('textarea');
    textarea.id = "notes";
    //textarea.value = ' '; // ?
    textarea.name = 'marker[' + markerNumber + '][note]';
    textarea.style.width = '150px';
    textarea.className = 'show';
    div.appendChild(textarea);
    
    textarea.onchange = function () { 
        data.note = this.value; 
    };
                                   
    var submitNote = function()
    {
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
                error: function(err) {
                    console.log(err);
                },
                success: function (resp) {
                  console.log(resp);
                  changeMarkerDisplay(resp);
                }
            });
            
            active_marker = false;
            
            return false; 
        }
    }
    
    var changeMarkerDisplay = function(resp)
    {
        div.parentNode.removeChild(div);
    
        var note = resp.note_data;
        
        addSavedNote(note.note,note.marker_number,note.latitude,note.longitude)
    }
    
    var removeMarkerNote = function()
    {                    
        div.parentNode.removeChild(div);
        active_marker = false;
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
    
    
    var marker_height = 30;
    var marker_width = 30;
    var offsetX = 5;
    var offsetY = 10;
    
    textarea.style.position = "absolute";
    textarea.style.left = -.5*(parseFloat(textarea.style.width)) + .5*marker_width + 'px';
    textarea.style.top = -1*marker_height - 20 - offsetY + 'px';
    
    ok_button.style.position = "absolute";
    ok_button.style.left = -.5*(parseFloat(textarea.style.width)) + .5*32 + 'px';
    ok_button.style.top = -1*marker_height + 'px';
    
    remove_button.style.position = "absolute";
    remove_button.style.left = -.5*(parseFloat(textarea.style.width)) + 32 + 25 +'px';
    remove_button.style.top = -1*marker_height + 'px';
    
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
    scan_id.value = scan_id;
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
    if (active_polygon != -1 || active_marker)
    {
        alert('Please finish editing your active marker.');
        return;
    }
    
    if (draw_mode)
    {
        alert('Please finish your creating polygon note before adding a new marker note.');
        return;
    }
    
    if (arguments[0] == 'marker')
    {
        changeNoteButtonStyle('marker'); 
    }
    
    var markerDiv = new MarkerNote(map, post_url);
    document.getElementById('scan-form').appendChild(markerDiv);
    
    active_marker = true;
}
                    
function SavedMarker(map,note,note_num,lat,lon)
{
    this.location = new MM.Location(lat,lon);
    
    var data = this.data = {
        'lat': parseFloat(lat),
        'lon': parseFloat(lon),
        'marker_number': note_num,
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
    
    /*
    var background_div = document.createElement('div');
    background_div.style.position = 'absolute';
    background_div.style.zIndex = '1';
    background_div.style.width = '180px';
    background_div.style.height = '60px';
    background_div.style.background = '#000';
    div.appendChild(background_div);
    */
    
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
        
        active_marker = false;
        
        return false;
    }
    
    var submitNote = function()
    {   
        console.log('data', data);
        console.log('post_url', post_url);
        reqwest({
            url: post_url,
            method: 'post',
            data: data,
            type: 'json',
            error: function (err) {
                console.log('error', err);
            },
            success: function (resp) {
              //console.log('response',resp);
              if (resp.status != 200)
              {
                alert('There was a problem: ' + resp.message);
              }
              
              changeMarkerDisplay(resp);
            }
        });
        
        active_marker = false;
        
        return false;
    }
    
    var changeMarkerDisplay = function(resp)
    {
        //console.log('changemarkerresp', resp);
        if (textarea.className == 'show' && remove_button.className == 'show' && ok_button.className == 'show' && cancel_button.className == 'show') {
            textarea.className = 'hide';
            ok_button.className = 'hide';
            cancel_button.className = 'hide';
            remove_button.className = 'hide';
        }
    
        saved_note.innerHTML = resp.note_data.note;
        textarea.value = resp.note_data.note;
    }
    
    var hidePolygonNote = function()
    {
        console.log('hide polygon note');
        if (active_polygon != -1)
        {
            savePolygon(active_polygon);
            active_polygon = -1;
        }
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
    scan_id.value = scan_id;
    scan_id.name = 'marker[' + unsignedMarkerNumber + '][scan_id]';
    scan_id.type = 'hidden';
    div.appendChild(scan_id);
    
    unsignedMarkerNumber++;
    
    img.onmouseover = function(e)
    {
        if (textarea.className == 'hide' && ok_button.className == 'hide' && remove_button.className == 'hide' && cancel_button.className == 'hide' && active_polygon == -1 && !active_marker && !draw_mode)
        {
            img.src = 'img/icon_x_mark_hover.png';
            
            var marker_height = 30;
            var marker_width = 30;
            var offsetY = 5;
            
            saved_note.className = 'show';
            saved_note.style.position = "absolute";
            saved_note.style.left = -.5*saved_note.offsetWidth + .5 * marker_width + 'px';
            saved_note.style.top = -1*saved_note.offsetHeight - offsetY + 'px';
        } else {
            img.style.cursor = 'default';
        }
    }
    
    img.onmouseout = function(e)
    {
        img.src = 'img/icon_x_mark.png';
        img.style.cursor = 'move';
        
        if (saved_note.className = 'show')
        {
            saved_note.className = 'hide';
        }
    }
                            
    img.onmousedown = function(e)
    {
        if (active_polygon != -1 || active_marker || draw_mode)
        {
            return;
        }
        
        active_marker = true;
                
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
            
            var marker_height = 30;
            var offsetX = 5;
            var offsetY = 10;
            
            textarea.style.position = "absolute";
            textarea.style.left = -.5*textarea.offsetWidth + .5 * marker_height + 'px';
            textarea.style.top = -1*textarea.offsetHeight - ok_button.offsetHeight - .5*offsetY + 'px';
            
            ok_button.style.position = "absolute";
            ok_button.style.left = -.5*textarea.offsetWidth + .5 * marker_height + 'px';
            ok_button.style.top = -1*textarea.offsetHeight + ok_button.offsetHeight - offsetY + 'px';
            
            cancel_button.style.position = "absolute";
            cancel_button.style.left = -.5*textarea.offsetWidth + .5 * marker_height + ok_button.offsetWidth + offsetX + 'px';
            cancel_button.style.top = -1*textarea.offsetHeight + ok_button.offsetHeight - offsetY + 'px';
            
            remove_button.style.position = "absolute";
            remove_button.style.left = -.5*textarea.offsetWidth + .5 * marker_height + ok_button.offsetWidth + cancel_button.offsetWidth + 2*offsetX + 'px';
            remove_button.style.top = -1*textarea.offsetHeight + ok_button.offsetHeight - offsetY + 'px';
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