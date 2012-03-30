var circle;
var follow_mouse = true;
var draw_path = false;
var drawn_path_vertex;
var path_string = '';
var orig_x;
var orig_y;
var new_path = null;

var master_path = '';
var master_path_piece = '';

var start = true;
var start_x,
    start_y;
    
var pre_scroll_y;

var previous_paths = [];
var drawn_path_vertices = [];

var vertices = [];
var temp_vertices = [];
var vertex_display_objects = [];
var control_midpoints = [];
var control_midpoint_display_objects = [];

var new_polygon;

var polygon_location_data = [];

var saved_polygons = [];

var active_polygon = -1;

var saved_polygon_location_data = [],
    saved_control_location_data = [],
    last_saved_polygon_location_data = [];

var polygon_notes = [];

var initialXs, 
    initialYs,
    initialMidpointXs,
    initialMidpointYs;

var delta = {dx: 0, dy: 0};

///
// Dealing with Marker Notes and Polygon Notes
///
var markerNumber = -1;
var unsignedMarkerNumber = 1;
                    
//setMapHeight();
// Window Callbacks
//window.onresize = setMapHeight;

loadSavedNotes();

function setMapHeight()
{   
    var map_height = window.innerHeight - document.getElementById('nav').offsetHeight;
    
    document.getElementById('map').style.height = map_height + 'px';
    
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
            'created': notes[i]['created'],
            'type': 'POINT'
        };
        
        if (note_geometry.substring(0,5) == 'POINT')
        {
            var note = notes[i]['note'],
                note_num = notes[i]['note_number'],
                lat = notes[i]['latitude'],
                lon = notes[i]['longitude'],
                user = notes[i]['user_id'],
                created = notes[i]['created'];
            
            addSavedNote(note,user,created,note_num,lat,lon);
            
        } else if (note_geometry.substring(0,7) == 'POLYGON')
        {  
            note_data.type = 'POLYGON';
            
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