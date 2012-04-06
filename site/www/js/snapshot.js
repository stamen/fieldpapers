var circle,
    follow_mouse = true,
    draw_path = false,
    drawn_path_vertex,
    path_string = '',
    orig_x,
    orig_y,
    new_path = null,
    master_path = '',
    master_path_piece = '';

var start = true,
    start_x,
    start_y;
    
var pre_scroll_y,
    previous_paths = [],
    drawn_path_vertices = [];

var vertices = [],
    temp_vertices = [],
    vertex_display_objects = [],
    control_midpoints = [],
    control_midpoint_display_objects = [];

var new_polygon,
    polygon_location_data = [],
    saved_polygons = [],
    active_polygon = -1,
    saved_polygon_location_data = [],
    saved_control_location_data = [],
    last_saved_polygon_location_data = [],
    polygon_notes = [],
    markerNumber = -1,
    unsignedMarkerNumber = 1;

var initialXs, 
    initialYs,
    initialMidpointXs,
    initialMidpointYs;

var delta = {dx: 0, dy: 0};
                    
loadSavedNotes();

setDisplayContainerHeight();

function setDisplayContainerHeight()
{   
    var map_height = window.innerHeight - document.getElementById('nav').offsetHeight - 30;
    
    document.getElementById('display_container').style.height = map_height + 'px';
    
    // Reset Canvas
    if (canvas)
    {                
        canvas.setSize(window.innerWidth, map_height);
    }
}

function changeNoteButtonStyle(type)
{  
    /*
    if (type === 'polygon')
    {
        document.getElementById('polygon_button').setAttribute("class", "radio_portrait_selected");
        document.getElementById('marker_button').setAttribute("class", "radio_landscape");
    } else if (type === 'marker') {
        document.getElementById('polygon_button').setAttribute("class", "radio_portrait");
        document.getElementById('marker_button').setAttribute("class", "radio_landscape_selected");
    }
    */
}

function loadSavedNotes() 
{ 
    for (var i = 0; i < notes.length; i++)
    {   
        var note_geometry = notes[i]['geometry'];
        
        var note_data = {
            'lat': notes[i]['latitude'],
            'lon': notes[i]['longitude'],
            'note': notes[i]['note'],
            'marker_number': notes[i]['note_number'],
            'user_id': notes[i]['user_id'],
            'username': notes[i]['username'],
            'created': notes[i]['created'],
            'type': 'POINT'
        };
        
        if (note_geometry.substring(0,5) == 'POINT')
        {
            var note = notes[i]['note'],
                note_num = notes[i]['note_number'],
                lat = notes[i]['latitude'],
                lon = notes[i]['longitude'],
                user = notes[i]['username'],
                created = notes[i]['created'];
                
            if (!user) {
                user = 'Anonymous';
            }
            
            addSavedNote(note,user,created,note_num,lat,lon);
            
        } else if (note_geometry.substring(0,7) == 'POLYGON')
        {  
            note_data.type = 'POLYGON';
            
            if (!note_data.username) {
                note_data.username = 'Anonymous';
            }
            
            var polygon_vertices_string = note_geometry.substring(10, note_geometry.length - 2);
            var polygon_loc_vertices = polygon_vertices_string.split(', ');
            
            polygon_loc_vertices = polygon_loc_vertices.map(function(p) { return p.split(' ')});
            
            for (var j = 0; j < polygon_loc_vertices.length; j++)
            {
                for (var k = 0; k < polygon_loc_vertices[j].length; k++)
                {
                    polygon_loc_vertices[j][k] = parseFloat(polygon_loc_vertices[j][k]);
                }
            }
            
            var polygon_vertices = [];
            for (var j = 0; j < polygon_loc_vertices.length; j++)
            {
                var p_loc = new MM.Location(polygon_loc_vertices[j][1], polygon_loc_vertices[j][0]);
                var p_point = map.locationPoint(p_loc);
                
                polygon_vertices[j] = p_point;
            }
            
            loadPolygon(note_data, polygon_vertices);
        }
     }
}

function finishedRedirect()
{   
    window.location = redirect_url;
}

function checkMapOverflow(topLeftPoint, bottomRightPoint, padding)
{
    var map_extent = map.getExtent();
    var map_top_left_point = map.locationPoint(map_extent[0]);
    map_top_left_point.y = map_top_left_point.y + padding;
    var map_bottom_right_point = map.locationPoint(map_extent[1]);
    
    // Create 4 Boolean values for overflow tests
    var left_overflow = topLeftPoint.x < map_top_left_point.x;
    var top_overflow = topLeftPoint.y < map_top_left_point.y;
    var right_overflow = bottomRightPoint.x > map_bottom_right_point.x;
    var bottom_overflow = bottomRightPoint.y > map_bottom_right_point.y;
    
    if (left_overflow || top_overflow || right_overflow || bottom_overflow)
    {
        var pan_delta_x = 0;
        var pan_delta_y = 0;
        
        if (right_overflow && bottom_overflow)
        {
            pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x;
            pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y;
        } else if (right_overflow && top_overflow) {
            pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x;
            pan_delta_y = map_top_left_point.y - topLeftPoint.y;
        } else if (left_overflow && top_overflow) {
            pan_delta_x = map_top_left_point.x - topLeftPoint.x;
            pan_delta_y = map_top_left_point.y - topLeftPoint.y;
        } else if (left_overflow && bottom_overflow) {
            pan_delta_x = map_top_left_point.x - topLeftPoint.x;
            pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y;
        } else if (left_overflow) {
            pan_delta_x = map_top_left_point.x - topLeftPoint.x;
        } else if (top_overflow) {
            pan_delta_y = map_top_left_point.y - topLeftPoint.y;
        } else if (right_overflow) {
            pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x;
        } else if (bottom_overflow) {
            pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y;
        }
        
        var map_center = map.getCenter();
        var map_center_point = map.locationPoint(map_center);
        
        // Calculate new center point
        map_center_point.x = map_center_point.x - pan_delta_x;
        map_center_point.y = map_center_point.y - pan_delta_y;
        
        var new_map_center_loc = map.pointLocation(map_center_point);
        
        //easey.slow(map, {location: new_map_center_loc});
        //map.setCenter(new_map_center_loc);
        map.panBy(pan_delta_x, pan_delta_y);
    } else {
        return;
    }
}

// Window Callbacks
window.onresize = setDisplayContainerHeight;

// Handle mouse interaction for zoom controls
     
var zoom_in = document.getElementById("zoom-in");
var zoom_out = document.getElementById("zoom-out");
    
var zoom_in_button = document.getElementById('zoom-in-button');
zoom_in.onmouseover = function() { zoom_in_button.src = zoom_in_active; };
zoom_in.onmouseout = function() { zoom_in_button.src = zoom_in_inactive; };

zoom_in.onclick = function() { map.zoomIn(); return false; };

var zoom_out_button = document.getElementById('zoom-out-button');
zoom_out.onmouseover = function() { zoom_out_button.src = zoom_out_active; };
zoom_out.onmouseout = function() { zoom_out_button.src = zoom_out_inactive; };

zoom_out.onclick = function() { map.zoomOut(); return false; };

// Handle mouse interaction for toolbar controls

var marker_button = document.getElementById("marker_button");
marker_button.onmouseover = function() { marker_button.setAttribute("class", "radio_pin_selected"); };
marker_button.onmouseout = function() { marker_button.setAttribute("class", "radio_pin"); };

var polygon_button = document.getElementById("polygon_button");
polygon_button.onmouseover = function() { polygon_button.setAttribute("class", "radio_shape_selected"); };
polygon_button.onmouseout = function() { polygon_button.setAttribute("class", "radio_shape"); };