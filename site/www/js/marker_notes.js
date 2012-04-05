var active_marker = false;

function MarkerNote(map, post_url)
{
    var note_displayed = true;
    
    this.location = map.getCenter();
    
    var data = this.data = {
        'lat': this.location.lat,
        'lon': this.location.lon,
        'marker_number': markerNumber,
        'user_id': current_user_id,
        'note': ''
    };
    
    this.location = map.getCenter();
                            
    var div = document.createElement('div');
    div.className = 'marker';
        
    var img = document.createElement('img');
    img.src = 'img/icon_x_mark_new.png';
    div.appendChild(img);
        
    var new_marker_text_area = document.getElementById('new_marker_textarea');
                                   
    var submitNote = function()
    {
        if (new_marker_text_area.value.trim() == ''){
            alert('Please fill out your note!');
            return false;
        } else {
            reqwest({
                url: post_url,
                method: 'post',
                data: data,
                type: 'json',
                error: function(err) {
                    console.log('error', err);
                },
                success: function (resp) {
                  //console.log('resp', resp);
                  changeMarkerDisplay(resp);
                }
            });
            
            active_marker = false;
            note_displayed = false;
            
            return false; 
        }
    }
    
    var changeMarkerDisplay = function(resp)
    {
        new_marker_text_area.value = '';
        
        div.parentNode.removeChild(div);
        
        var new_marker_note = document.getElementById('new_marker_note');
        new_marker_note.className = 'hide';
    
        var note = resp.note_data;
        
        if (!note.username)
        {
            note.username = 'Anonymous';
        }
        
        addSavedNote(note.note,note.username,note.created,note.marker_number,note.latitude,note.longitude);
    }
    
    var removeMarkerNote = function()
    {                    
        div.parentNode.removeChild(div);
        
        var editable_new_note = document.getElementById('new_marker_note');
        editable_new_note.className = 'hide'; 
        
        active_marker = false;
        note_displayed = false;
    }
        
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
    
    var user_id = document.createElement('input');
    user_id.value = current_user_id;
    user_id.name = 'marker[' + markerNumber + '][scan_id]';
    user_id.type = 'hidden';
    div.appendChild(user_id);
    
    markerNumber--;
    
    // make it easy to drag
    
    img.onmousedown = function(e)
    {
        if (active_polygon != -1 || (active_marker && !note_displayed) || draw_mode)
        {
            return;
        }
        
        active_marker = true;
        
        note_displayed = true;
        
        var ok_button = document.getElementById('new_marker_ok_button');
        ok_button.onclick = submitNote;
        
        var remove_button = document.getElementById('new_marker_delete_button');
        remove_button.onclick = removeMarkerNote;
        
        var editable_new_note = document.getElementById('new_marker_note');
        editable_new_note.className = 'show';
        
        var editable_new_note_textarea = document.getElementById('new_marker_textarea');
        
        editable_new_note_textarea.onchange = function () {
            data.note = this.value;
        };
        
        var marker_width = 30;
        var offsetY = 5;
        
        editable_new_note.style.position = "absolute";
        editable_new_note.style.left = div.offsetLeft - .5*editable_new_note.offsetWidth + .5*marker_width + 'px';
        editable_new_note.style.top = div.offsetTop - editable_new_note.offsetHeight - offsetY + 'px';
        
        var marker_start = {x: div.offsetLeft, y: div.offsetTop},
            mouse_start = {x: e.clientX, y: e.clientY};
        
        var note_start = {x: editable_new_note.offsetLeft, y: editable_new_note.offsetTop};
        
        document.onmousemove = function(e)
        {   
            var mouse_now = {x: e.clientX, y: e.clientY};
        
            div.style.left = (marker_start.x + mouse_now.x - mouse_start.x) + 'px';
            div.style.top = (marker_start.y + mouse_now.y - mouse_start.y) + 'px';
            
            editable_new_note.style.left = (note_start.x + mouse_now.x - mouse_start.x) + 'px';
            editable_new_note.style.top = (note_start.y + mouse_now.y - mouse_start.y) + 'px';
        }
        
        return false;
    }
    
    var marker = this;
    
    img.onmouseup = function(e)
    {                                   
        var marker_end = {x: div.offsetLeft, y: div.offsetTop};
        
        marker.location = map.pointLocation(marker_end);
        
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
        
        if (note_displayed)
        {
            var marker_width = 30;
            var offsetY = 5;
            
            var editable_new_note = document.getElementById('new_marker_note');
            editable_new_note.style.left = div.offsetLeft - .5*editable_new_note.offsetWidth + .5*marker_width + 'px';
            editable_new_note.style.top = div.offsetTop - editable_new_note.offsetHeight - offsetY + 'px';
        }
    }
                            
    map.addCallback('panned', updatePosition);
    map.addCallback('zoomed', updatePosition);
    updatePosition();
    
    var ok_button = document.getElementById('new_marker_ok_button');
    ok_button.onclick = submitNote;
        
    var remove_button = document.getElementById('new_marker_delete_button');
    remove_button.onclick = removeMarkerNote;
    
    var editable_new_note_textarea = document.getElementById('new_marker_textarea');
    editable_new_note_textarea.onchange = function () {
        data.note = this.value;
    };
        
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
    //var markerDiv = marker.div;
    document.getElementById('marker-container').appendChild(markerDiv);
    
    var editable_new_note = document.getElementById('new_marker_note');
    editable_new_note.className = 'show';
    
    var marker_width = 30;
    var offsetY = 5;
        
    editable_new_note.style.position = "absolute";
    editable_new_note.style.left = markerDiv.offsetLeft - .5*editable_new_note.offsetWidth + .5*marker_width + 'px';
    editable_new_note.style.top = markerDiv.offsetTop - editable_new_note.offsetHeight - offsetY + 'px';
            
    active_marker = true;
    note_displayed = true;
}

function SavedMarker(map,note,user,created,note_num,lat,lon)
{
    var note_displayed = false;
    
    this.location = new MM.Location(lat,lon);
    
    var data = this.data = {
        'lat': parseFloat(lat),
        'lon': parseFloat(lon),
        'marker_number': note_num,
        'user_id': current_user_id,
        'user': user,
        'created': created,
        'note': note
    };
                          
    var div = document.createElement('div');
    div.className = 'marker';
    
    var img = document.createElement('img');
    img.src = 'img/icon_x_mark.png';
    div.appendChild(img);
    
    var removeMarkerNote = function()
    {                            
        if (window.confirm("Are you sure you want to delete this saved note?"))
        {            
            div.parentNode.removeChild(div);
            
            var editable_saved_note = document.getElementById('marker_note');
            editable_saved_note.className = 'hide';
            
            data.removed = 1; // Removed
            
            submitNote();
            
            active_marker = false;
            note_displayed = false;
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
        
        var editable_saved_note_textarea = document.getElementById('marker_textarea');
        editable_saved_note_textarea.innerHTML = note;
        
        /*
        if (textarea.className == 'show' && remove_button.className == 'show' && ok_button.className == 'show' && cancel_button.className == 'show') {
            textarea.className = 'hide';
            ok_button.className = 'hide';
            cancel_button.className = 'hide';
            remove_button.className = 'hide';
        }
        */
        
        var editable_saved_note = document.getElementById('marker_note');
        editable_saved_note.className = 'hide';
        
        active_marker = false;
        note_displayed = false;
        
        return false;
    }
    
    var submitNote = function()
    {   
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
        
        note_displayed = false;
        
        return false;
    }
    
    var changeMarkerDisplay = function(resp)
    {        
        var editable_saved_note = document.getElementById('marker_note');
        editable_saved_note.className = 'hide';
            
        var editable_saved_note_textarea = document.getElementById('marker_textarea');
        editable_saved_note_textarea.innerHTML = resp.note_data.note;
    }
    
    var hidePolygonNote = function()
    {
        if (active_polygon != -1)
        {
            savePolygon(active_polygon);
            active_polygon = -1;
        }
    }
        
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
    
    var user_id = document.createElement('input');
    user_id.value = current_user_id;
    user_id.name = 'marker[' + unsignedMarkerNumber + '][scan_id]';
    user_id.type = 'hidden';
    div.appendChild(user_id);
    
    unsignedMarkerNumber++;
    
    var saved_note = document.getElementById('marker_tip');
    
    img.onmouseover = function(e)
    {
        if (active_polygon == -1 && !active_marker && !draw_mode)
        {
            img.src = 'img/icon_x_mark_hover.png';
            
            if (data.created)
            {
                var date = new Date(data.created*1000);
                var day = date.getDate();
                var month = date.getMonth();
                var year = date.getFullYear();
                
                var formatted_date = (parseInt(month) + 1) + '/' + day + '/' + year;
        
                saved_note.innerHTML = data.note + '<br><br>' + user + ', ' + formatted_date;
            } else {
                saved_note.innerHTML = data.note;
            }
                        
            var marker_width = 30;
            var offsetY = 5;
            
            saved_note.className = 'show';
            saved_note.style.position = "absolute";
            saved_note.style.left = div.offsetLeft - .5*saved_note.offsetWidth + .5*marker_width + 'px';
            saved_note.style.top = div.offsetTop - saved_note.offsetHeight - offsetY + 'px';
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
        if (active_polygon != -1 || (active_marker && !note_displayed) || draw_mode)
        {
            return;
        }
        
        active_marker = true;
        
        note_displayed = true;
        
        var ok_button = document.getElementById('marker_ok_button');
        ok_button.onclick = submitNote;
        
        var cancel_button = document.getElementById('marker_cancel_button');
        cancel_button.onclick = resetNote;
        
        var remove_button = document.getElementById('marker_delete_button');
        remove_button.onclick = removeMarkerNote;
        
        saved_note.className = 'hide';
        
        var editable_saved_note = document.getElementById('marker_note');
        editable_saved_note.className = 'show';
        
        var editable_saved_note_textarea = document.getElementById('marker_textarea');
        editable_saved_note_textarea.innerHTML = note;
    
        editable_saved_note_textarea.onchange = function () { 
            data.note = this.value;
        };
        
        var marker_width = 30;
        var offsetY = 5;
        
        editable_saved_note.style.position = "absolute";
        editable_saved_note.style.left = div.offsetLeft - .5*editable_saved_note.offsetWidth + .5*marker_width + 'px';
        editable_saved_note.style.top = div.offsetTop - editable_saved_note.offsetHeight - offsetY + 'px';
                
        var marker_start = {x: div.offsetLeft, y: div.offsetTop},
            mouse_start = {x: e.clientX, y: e.clientY};
        
        var note_start = {x: editable_saved_note.offsetLeft, y: editable_saved_note.offsetTop};
                
        document.onmousemove = function(e)
        {                                
            var mouse_now = {x: e.clientX, y: e.clientY};
        
            div.style.left = (marker_start.x + mouse_now.x - mouse_start.x) + 'px';
            div.style.top = (marker_start.y + mouse_now.y - mouse_start.y) + 'px';
            
            editable_saved_note.style.left = (note_start.x + mouse_now.x - mouse_start.x) + 'px';
            editable_saved_note.style.top = (note_start.y + mouse_now.y - mouse_start.y) + 'px';
        }
        
        return false;
    }
    
    var marker = this;
    
    img.onmouseup = function(e)
    {                            
        var marker_end = {x: div.offsetLeft, y: div.offsetTop};
        
        marker.location = map.pointLocation(marker_end);
        data.lat = marker.location.lat.toFixed(6);
        data.lon = marker.location.lon.toFixed(6);
        
        updatePosition();
    
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
        
        if (note_displayed)
        {
            var marker_width = 30;
            var offsetY = 5;
            
            var editable_saved_note = document.getElementById('marker_note');
            editable_saved_note.style.left = div.offsetLeft - .5*editable_saved_note.offsetWidth + .5*marker_width + 'px';
            editable_saved_note.style.top = div.offsetTop - editable_saved_note.offsetHeight - offsetY + 'px';
            

    
            // Check overflow
            checkMapOverflow({x: editable_saved_note.offsetLeft, y: editable_saved_note.offsetTop}, 
                             {x: editable_saved_note.offsetLeft + editable_saved_note.offsetWidth, y: editable_saved_note.offsetTop + editable_saved_note.offsetHeight}
                            );
        }
    }
    
    map.addCallback('panned', updatePosition);
    map.addCallback('zoomed', updatePosition);
    map.addCallback('resized', updatePosition);
    initialPosition();
    
    return div;
}

function addSavedNote(note,user,created,note_num,lat,lon)
{
    var saved_marker = new SavedMarker(map,note,user,created,note_num,lat,lon);
    document.getElementById('marker-container').appendChild(saved_marker);
}