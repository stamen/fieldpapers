var draw_mode = false;

canvas = Raphael("canvas");

function loadPolygon(note_data, polygon_vertices)
{
    if (active_polygon != -1)
    {
        savePolygon(active_polygon, true);
    }
    
    active_polygon = -1;
    
    vertices = [];
    vertex_display_objects = [];
    control_midpoints = [];
    control_midpoint_display_objects = [];
    
    new_polygon = canvas.path('');
    new_polygon.attr({fill: "#f3e50c", 
                      "fill-opacity": .25,
                      "stroke-opacity": 1,
                      "stroke-width": 3,
                      cursor: "pointer"
                     }); // Working?
    
    readVertices(polygon_vertices);
    
    createPolygon(note_data, false);
    
    savePolygonLocationData(vertices, control_midpoints);
    
    // Adding ability to cancel an edit
    
    var last_saved_vertex_locations = [];
    var last_saved_control_locations = [];
    
    for (var i = 0; i < vertices.length; i++)
    {                            
        last_saved_vertex_locations[i] = saved_polygon_location_data[active_polygon][i];
        last_saved_control_locations[i] = saved_control_location_data[active_polygon][i];
    }
    
    last_saved_polygon_location_data[active_polygon] = last_saved_vertex_locations;
    
    new_polygon.mouseover(function(index) {
                        return function() { if (active_polygon == -1 && !active_marker && !draw_mode) {polygonMouseOver(index);} }
                      }(saved_polygons.length -1));
                      
    new_polygon.mouseout(function(index) {
                    return function() { if (active_polygon == -1 && !active_marker && !draw_mode) { polygonMouseOut(index);} }
                  }(saved_polygons.length -1));
    
    new_polygon.click(function(index) {
                        return function() { if (active_polygon == -1 && !active_marker && !draw_mode) {changePolygon(index);} }
                    }(saved_polygons.length - 1));
    
    // Inactivate the loaded polygons
    savePolygon(active_polygon, true);
    active_polygon = -1;
    document.getElementById('polygon_textarea').value = '';
}


function readVertices(polygon_vertices)
{   
    vertices = polygon_vertices;
    
    redrawPathOnVertexDrag(vertices);
    
    createControlMidpoints();
    
    ////
    // Draw the vertices
    ////
    
    initialXs = new Array(vertices.length), 
    initialYs = new Array(vertices.length);
    
    for (var i = 0; i < vertices.length; i++)
    {   
        var vertex_display_object = canvas.circle(vertices[i].x,
                                                  vertices[i].y,
                                                  8);
        
        vertex_display_object.attr({fill: '#FFF',
                                    "stroke-width": 3
                                   });
                                                                
        vertex_display_objects.push(vertex_display_object);
    }
    
    // This is unnecessary duplication.
    for (var i = 0; i < vertex_display_objects.length; i++)
    {
        vertex_display_objects[i].drag(
            
            function (index) {
                ////
                // Need to use a closure
                ////
                return function(dx, dy, cx, cy, e){
                    e.stopPropagation();
                
                    this.attr({
                        cx: initialXs[index] + dx,
                        cy: initialYs[index] + dy
                    });
                    
                    setVertices(e,index,this.attr('cx'), this.attr('cy'));
                    updateMidpoints(index);
                    
                    changePolygonNotePosition()
                };
            }(i),
            
            function (index) {
            
                return function (cx, cy, e) {
                    e.stopPropagation();
                    
                    initialXs[index] = this.attr("cx");
                    initialYs[index] = this.attr("cy");
                }
                
            }(i),
            
            function (index) {
                return function() {
                    savePolygonLocationData(vertices, control_midpoints);
                }
            }(i)
        );
    }
    
    
    ////
    // Draw the control midpoints
    ////
    
    initialMidpointXs = new Array(control_midpoints.length), 
    initialMidpointYs = new Array(control_midpoints.length);
    
    for (var i = 0; i < control_midpoints.length; i++)
    {   
        var control_midpoint_display_object = canvas.circle(control_midpoints[i].x,
                                                            control_midpoints[i].y,
                                                            5);
        
        control_midpoint_display_object.attr({fill: '#FFF',
                                              "stroke-width": 1
                                            });
                                                                
        control_midpoint_display_objects.push(control_midpoint_display_object);
    }
    
    for (var i = 0; i < control_midpoint_display_objects.length; i++)
    {
        control_midpoint_display_objects[i].drag(
            
            function (index) {
                ////
                // Need to use a closure
                ////
                return function(dx, dy, cx, cy, e){
                    e.stopPropagation();
                
                    this.attr({
                        cx: initialMidpointXs[index] + dx,
                        cy: initialMidpointYs[index] + dy
                    });
                    
                    setControlMidpoints(e,index,this.attr('cx'), this.attr('cy'));
                    
                    changePolygonNotePosition()
                };
            }(i),
            
            function (index) {
            
                return function (cx, cy, e) {
                    e.stopPropagation();
                    
                    initialMidpointXs[index] = this.attr("cx");
                    initialMidpointYs[index] = this.attr("cy");
                    
                    setTempVertices(index, this.attr("cx"), this.attr("cy"));
                }
                
            }(i),
            
            function (index) {
                return function() {
                    replaceVertices(temp_vertices);
                    savePolygonLocationData(vertices, control_midpoints);
                }
            }(i)
        );
    }
}


function createPolygon(note_data, new_note)
{
    // Adding active polygon
    var polygon_to_add = {'vertices': vertices,
                          'vertex_display_objects': vertex_display_objects,
                          'polygon': new_polygon,
                          'control_midpoints': control_midpoints,
                          'control_midpoint_display_objects': control_midpoint_display_objects,
                          'removed': 0,
                          'new_note': new_note,
                          'note_data': note_data
                          };
    
    saved_polygons.push(polygon_to_add);
    
    active_polygon = saved_polygons.length - 1;
    updateTextArea(note_data.note);
    
    new_polygon.attr({fill: '#F3e50c',
                      "stroke-width": 2,
                      "fill-opacity": .25,
                      cursor: "pointer"
                     });
    showPolygonNote(new_note);
}

function savePolygon(index, reset_cursor)
{
    new_polygon.attr({fill: '#F3e50c',
                      "stroke-width": 3,
                      "fill-opacity": .25
                     });
    
    saved_polygons[index].vertices = vertices;
    saved_polygons[index].vertex_display_objects = vertex_display_objects;
    saved_polygons[index].polygon = new_polygon;
    saved_polygons[index].control_midpoints = control_midpoints;
    saved_polygons[index].control_midpoint_display_objects = control_midpoint_display_objects;
    
    if (saved_polygons[index].new_note)
    {
        saved_polygons[index].note_data.note = document.getElementById('new_polygon_textarea').value;
    } else {
        saved_polygons[index].note_data.note = document.getElementById('polygon_textarea').value;
    }
    
    var last_saved_vertex_locations = [];
    var last_saved_control_locations = [];
    
    for (var i = 0; i < vertices.length; i++)
    {
        vertex_display_objects[i].hide();
        control_midpoint_display_objects[i].hide();
        
        last_saved_vertex_locations[i] = saved_polygon_location_data[index][i];
        last_saved_control_locations[i] = saved_control_location_data[index][i];
    }
    
    last_saved_polygon_location_data[index] = last_saved_vertex_locations;
    
    hidePolygonNote(saved_polygons[index].new_note);
    
    if (reset_cursor)
    {
        for (var i = 0; i < saved_polygons.length; i++)
        {
            if (saved_polygons[i] != null)
            {
                saved_polygons[i].polygon.attr('cursor', 'pointer');
            }
        }
    }
}

function polygonMouseOver(index)
{
    updateTipTextArea(saved_polygons[index].note_data.note, saved_polygons[index].note_data.user_id, saved_polygons[index].note_data.created);

    var highlighted_polygon = saved_polygons[index].polygon;
    
    highlighted_polygon.attr({fill: '#0099FF',
                            "fill-opacity": .5
                            });
    
    showPolygonTip(highlighted_polygon);
}

function polygonMouseOut(index)
{
    var highlighted_polygon = saved_polygons[index].polygon;
    
    // remove note
    highlighted_polygon.attr({fill: '#F3e50c',
      "stroke-width": 3,
      "fill-opacity": .25
     });
     
     hidePolygonTip();
}

function changePolygon(index)
{
    hidePolygonTip();
    
    if (active_polygon != -1)
    {
        savePolygon(active_polygon, false);
        
        new_polygon.attr({fill: '#F3e50c',
          "stroke-width": 3,
          "fill-opacity": .25
         });
    }
    
    if (saved_polygons[index]['note_data']['removed'] == 1)
    {
        console.log('You are trying to select a deleted polygon.');
        return;
    }
    
    active_polygon = index;
    updateTextArea(saved_polygons[active_polygon].note_data.note);
    
    vertices = saved_polygons[active_polygon].vertices;
    vertex_display_objects = saved_polygons[active_polygon].vertex_display_objects;
    new_polygon = saved_polygons[active_polygon].polygon;
    control_midpoints = saved_polygons[active_polygon].control_midpoints;
    control_midpoint_display_objects = saved_polygons[active_polygon].control_midpoint_display_objects;
                            
    for (var i = 0; i < vertices.length; i++)
    {
        vertex_display_objects[i].show();
        control_midpoint_display_objects[i].show();
    }
    
    for (var i = 0; i < saved_polygons.length; i++)
    {
        if (i != active_polygon && saved_polygons[i] != null)
        {
            saved_polygons[i].polygon.attr('cursor', 'default');
        }
    }
    
    new_polygon.attr({fill: '#F3e50c',
      "stroke-width": 2,
      "fill-opacity": .25
     });
                     
    showPolygonNote(false);
}

function showPolygonTip(highlighted_polygon)
{
    var polygon_tip = document.getElementById('polygon_tip');
    polygon_tip.className = 'show';
    
    changePolygonTipPosition(highlighted_polygon);
}

function showPolygonNote(new_note)
{   
    if (new_note)
    {
        var new_polygon_note = document.getElementById('new_polygon_note');
        new_polygon_note.className = 'show';
    } else {
        var polygon_note = document.getElementById('polygon_note');
        polygon_note.className = 'show';
    }
    
    changePolygonNotePosition(new_note);
}

function hidePolygonNote(new_note)
{
    if (new_note)
    {
        var new_polygon_note = document.getElementById('new_polygon_note');
        new_polygon_note.className = 'hide';
    } else {
        var polygon_note = document.getElementById('polygon_note');
        polygon_note.className = 'hide';
    }
}

function hidePolygonTip()
{
    var polygon_tip = document.getElementById('polygon_tip');
    polygon_tip.className = 'hide';
}

function changePolygonNotePosition(new_note)
{
    if (new_note)
    {
        var polygon_note = document.getElementById('new_polygon_note');
    } else {
        var polygon_note = document.getElementById('polygon_note');
    }
    
    var offsetY = 20;
    var current_polygon_bbox = new_polygon.getBBox();
    var note_height = polygon_note.offsetHeight;
    var note_width = polygon_note.offsetWidth;
    
    polygon_note.style.left = current_polygon_bbox.x + .5 * current_polygon_bbox.width - .5 * note_width + 'px';
    polygon_note.style.top = current_polygon_bbox.y - note_height - offsetY + 'px';
}

function changePolygonTipPosition(highlighted_polygon)
{
    var polygon_tip = document.getElementById('polygon_tip');
    
    var offsetY = 5;
    var current_polygon_bbox = highlighted_polygon.getBBox();
    var tip_height = polygon_tip.offsetHeight;
    var tip_width = polygon_tip.offsetWidth;
    
    polygon_tip.style.left = current_polygon_bbox.x + .5 * current_polygon_bbox.width - .5 * tip_width + 'px';
    polygon_tip.style.top = current_polygon_bbox.y - tip_height - offsetY + 'px';
}

function redrawPolygon(vertices, control_midpoints, vertex_display_objects, control_midpoint_display_objects, polygon, polygon_location_data, control_point_location_data)
{  
    // Update Vertices
    for (var i = 0; i < vertices.length; i++)
    {
        var polygon_point_data = map.locationPoint(polygon_location_data[i]);
        vertices[i].x = polygon_point_data.x;
        vertices[i].y = polygon_point_data.y;
    }
    
    for (var i = 0; i < control_midpoints.length; i++)
    {
        var control_point_data = map.locationPoint(control_point_location_data[i]);
        control_midpoints[i].x = control_point_data.x;
        control_midpoints[i].y = control_point_data.y;
    }
    
    // Move the vertices
                                                                          
    for (var i = 0; i < vertex_display_objects.length; i++)
    {
        vertex_display_objects[i].attr({
            cx: vertices[i].x,
            cy: vertices[i].y
        });
    
    }
    
    // Move the control points
    
    for (var i = 0; i < control_midpoint_display_objects.length; i++)
    {
        control_midpoint_display_objects[i].attr({
            cx: control_midpoints[i].x,
            cy: control_midpoints[i].y
        });
    
    }
    
    // Move the path
    
    var new_path = 'M' + vertices[0].x + ',' + vertices[0].y;
    
    for (var i = 1; i < vertices.length; i++)
    {
        new_path = new_path + 'L' + vertices[i].x + ',' + vertices[i].y;
    }
    
    new_path = new_path + 'Z';
    
    polygon.attr({
        path: new_path
    });
}
                    
function redrawPolygonsAndVertices()
{   
    if (active_polygon != -1)
    {
        redrawPolygon(vertices, control_midpoints, vertex_display_objects, control_midpoint_display_objects, new_polygon, saved_polygon_location_data[active_polygon], saved_control_location_data[active_polygon])
        changePolygonNotePosition();
    }
    
    for (var i = 0; i < saved_polygons.length; i++)
    {
        if (i != active_polygon && saved_polygons[i] != null)
        {
            redrawPolygon(saved_polygons[i].vertices, saved_polygons[i].control_midpoints,
                          saved_polygons[i].vertex_display_objects, saved_polygons[i].control_midpoint_display_objects,
                          saved_polygons[i].polygon, saved_polygon_location_data[i],
                          saved_control_location_data[i]);
        }
    }
}

function redrawPathOnVertexDrag(vertex_points)
{   
    var new_path = 'M' + vertex_points[0].x + ',' + vertex_points[0].y;
    
    for (var i = 1; i < vertex_points.length; i++)
    {
        new_path = new_path + 'L' + vertex_points[i].x + ',' + vertex_points[i].y;
    }
    
    new_path = new_path + 'Z';
    
    new_polygon.attr({
        path: new_path
    });
}

function handlePath(e)
{
    // Possibly not necessary
    if (active_polygon != -1)
    {
        savePolygon(active_polygon, true);
        active_polygon = -1;
    }
    
    if (start)
    {
        var map_element = document.getElementById('map');
    
        start_x = e.pageX - 10;
        start_y = e.pageY - document.getElementById('nav').offsetHeight;
        
        drawn_path_vertex = canvas.circle(start_x, 
                                          start_y, 
                                          8);
        
        drawn_path_vertex.attr({fill: '#FFF',
                                "stroke-width": 3
                              });
        
        drawn_path_vertices.push(drawn_path_vertex);
        
        master_path = "M" + start_x + ',' + start_y;
        
        start = false;
    }
    // Remember previous path
    if (new_path && path_string)
    {
        prev_path = canvas.path(path_string);
        prev_path.attr("stroke-width", 2);

        prev_path.toBack();
        
        drawn_path_vertex = canvas.circle(e.pageX - 10, 
                                          e.pageY - document.getElementById('nav').offsetHeight, 
                                          8);
        
        drawn_path_vertex.attr({fill: '#FFF',
                                "stroke-width": 3
        });
        
        previous_paths.push(prev_path);
        drawn_path_vertices.push(drawn_path_vertex);
        
        master_path = master_path + master_path_piece;
    }
    
    turnOnPath(e);
}

function turnOnPath(e)
{
    draw_path = true;
    
    var map_element = document.getElementById('map');
    
    //orig_x = e.pageX - map_element.offsetLeft;
    //orig_y = e.pageY - map_element.offsetTop;
    
    orig_x = e.pageX - 10;
    orig_y = e.pageY - document.getElementById('nav').offsetHeight;
}

function drawNewPath(e)
{
    if (new_path)
    {
        new_path.remove();
    }
    
    var map_element = document.getElementById('map');
    
    //var center_x = e.pageX - map_element.offsetLeft;
    //var center_y = e.pageY - map_element.offsetTop;
    
    var center_x = e.pageX - 10;
    var center_y = e.pageY - document.getElementById('nav').offsetHeight;
    
    path_string = "M" + orig_x + ',' + orig_y + "L" + center_x + ',' + center_y;
    master_path_piece = "L" + center_x + ',' + center_y;
    
    new_path = canvas.path(path_string);
    new_path.attr({"stroke-width": 3, 
                    "stroke-opacity": 1
                 });
    
    new_path.toBack();
}

/*
function exitPolygonModeWithoutSave()
{
    active_polygon = -1;
    
    circle.remove();
    master_path = '';
    undoDrawEvents();
}
*/

function setPolygon(e)
{
    e.stopPropagation();
    
    draw_mode = false;

    if (active_polygon != -1)
    {
        savePolygon(active_polygon, true);
    }
    
    active_polygon = -1;
    
    vertices = [];
    vertex_display_objects = [];
    control_midpoints = [];
    control_midpoint_display_objects = [];
                            
    master_path = master_path + 'L' + start_x + ',' + start_y + 'Z';
    
    var master_path_array = Raphael.parsePathString(master_path);
    
    var new_master_path = '';
    
    for (i = 0; i < master_path_array.length - 3; i++)
    {
        new_master_path = new_master_path + master_path_array[i][0] + master_path_array[i][1] + ',' + master_path_array[i][2];
    }
    
    new_master_path = new_master_path + 'L' + start_x + ',' + start_y + 'Z';
    
    new_polygon = canvas.path(new_master_path);
    
    new_polygon.attr({fill: "#f3e50c", 
                      "fill-opacity": .25, 
                      "stroke-opacity": 1,
                      "stroke-width": 2
                    });
    
    new_path.remove();
    
    for (var i=0; i < previous_paths.length; i++)
    {
        previous_paths[i].remove();
    }
    
    for (var i=0; i < drawn_path_vertices.length; i++)
    {
        drawn_path_vertices[i].remove();
    }
    previous_paths = [];
    drawn_path_vertices = [];
    
    addVertices();
    
    ////
    // Handling Note Data
    ////
    
    // A new note
    
    var note_data = {
        'note': '',
        'marker_number': markerNumber,
        'type': 'POLYGON',
    };
    
    markerNumber--;
    
    createPolygon(note_data, true);
    
    savePolygonLocationData(vertices, control_midpoints);
    
    // Ability to cancel an edit
    
    var last_saved_vertex_locations = [];
    var last_saved_control_locations = [];
    
    for (var i = 0; i < vertices.length; i++)
    {   
        last_saved_vertex_locations[i] = saved_polygon_location_data[active_polygon][i];
        last_saved_control_locations[i] = saved_control_location_data[active_polygon][i];
    }
    
    last_saved_polygon_location_data[active_polygon] = last_saved_vertex_locations;
    
    // Give the polygon a click handler to toggle activity    
    new_polygon.mouseover(function(index) {
                            return function() { if (active_polygon == -1 && !active_marker && !draw_mode) {polygonMouseOver(index);} }
                          }(saved_polygons.length -1));
    
    new_polygon.mouseout(function(index) {
                    return function() { if (active_polygon == -1 && !active_marker && !draw_mode) {polygonMouseOut(index);} }
                  }(saved_polygons.length -1));
    
    new_polygon.click(function(index) { 
                        return function() { if (active_polygon == -1 && !active_marker && !draw_mode) {changePolygon(index);} }
                      }(saved_polygons.length - 1));
    
    circle.remove();
    master_path = '';
    undoDrawEvents();
}
                    
function createControlMidpoints()
{
    for (var i=1; i <= vertices.length; i++)
    {
        var j = i % vertices.length;
        
        control_midpoints.push({x: .5*(vertices[i-1].x + vertices[j].x),
                                y: .5*(vertices[i-1].y + vertices[j].y)
                              });
    }
}
             
function addVertices()
{
    var master_path_array = Raphael.parsePathString(master_path);
    
    ////
    // Find the vertices
    ////
    
    for (i = 0; i < master_path_array.length - 3; i++)
    {                            
        // Push main vertices
        vertices.push({x: master_path_array[i][1], y: master_path_array[i][2]});
    }
                            
    createControlMidpoints();
    
    ////
    // Draw the vertices
    ////
    
    initialXs = new Array(vertices.length), 
    initialYs = new Array(vertices.length);
    
    for (var i = 0; i < vertices.length; i++)
    {   
        var vertex_display_object = canvas.circle(vertices[i].x,
                                                  vertices[i].y,
                                                  8);
        
        vertex_display_object.attr({fill: '#FFF',
                                    "stroke-width": 3
                                   });
                                                                
        vertex_display_objects.push(vertex_display_object);
    }
    
    // This is unnecessary duplication.
    for (var i = 0; i < vertex_display_objects.length; i++)
    {
        vertex_display_objects[i].drag(
            
            function (index) {
                ////
                // Need to use a closure
                ////
                return function(dx, dy, cx, cy, e){
                    e.stopPropagation();
                
                    this.attr({
                        cx: initialXs[index] + dx,
                        cy: initialYs[index] + dy
                    });
                    
                    setVertices(e,index,this.attr('cx'), this.attr('cy'));
                    updateMidpoints(index);
                    
                    changePolygonNotePosition();
                };
            }(i),
            
            function (index) {
            
                return function (cx, cy, e) {
                    e.stopPropagation();
                    
                    initialXs[index] = this.attr("cx");
                    initialYs[index] = this.attr("cy");
                }
                
            }(i),
            
            function (index) {
                return function() {
                    savePolygonLocationData(vertices, control_midpoints);
                }
            }(i)
        );
    }
    
    
    ////
    // Draw the control midpoints
    ////
    
    initialMidpointXs = new Array(control_midpoints.length), 
    initialMidpointYs = new Array(control_midpoints.length);
    
    for (var i = 0; i < control_midpoints.length; i++)
    {   
        var control_midpoint_display_object = canvas.circle(control_midpoints[i].x,
                                                            control_midpoints[i].y,
                                                            5);
        
        control_midpoint_display_object.attr({fill: '#FFF',
                                              "stroke-width": 1
                                            });
                                                                
        control_midpoint_display_objects.push(control_midpoint_display_object);
    }
    
    for (var i = 0; i < control_midpoint_display_objects.length; i++)
    {
        control_midpoint_display_objects[i].drag(
            
            function (index) {
                ////
                // Need to use a closure
                ////
                return function(dx, dy, cx, cy, e){
                    e.stopPropagation();
                
                    this.attr({
                        cx: initialMidpointXs[index] + dx,
                        cy: initialMidpointYs[index] + dy
                    });
                    
                    setControlMidpoints(e,index,this.attr('cx'), this.attr('cy'));
                    
                    changePolygonNotePosition();
                };
            }(i),
            
            function (index) {
            
                return function (cx, cy, e) {
                    e.stopPropagation();
                    
                    initialMidpointXs[index] = this.attr("cx");
                    initialMidpointYs[index] = this.attr("cy");
                    
                    setTempVertices(index, this.attr("cx"), this.attr("cy"));
                }
                
            }(i),
            
            function (index) {
                return function() {
                    replaceVertices(temp_vertices);
                    savePolygonLocationData(vertices, control_midpoints);
                }
            }(i)
        );
    }
    
}

function replaceVertices(vertex_points)
{
    vertices = [];
    control_midpoints = [];

    for (var i = 0; i < vertex_display_objects.length; i++) {
        vertex_display_objects[i].remove();
        control_midpoint_display_objects[i].remove();
    }
    vertex_display_objects = [];
    control_midpoint_display_objects = [];
    
    for (var i = 0; i < vertex_points.length; i++)
    {
         vertices.push({x: vertex_points[i].x, y: vertex_points[i].y});
    }
    
    createControlMidpoints();
    
    ////
    // Draw the vertices
    ////
    
    initialXs = new Array(vertices.length), 
    initialYs = new Array(vertices.length);
    
    for (var i = 0; i < vertices.length; i++)
    {   
        var vertex_display_object = canvas.circle(vertices[i].x,
                                                  vertices[i].y,
                                                  8);
        
        vertex_display_object.attr({fill: '#FFF',
                                    "stroke-width": 3
                                   });
                                                                
        vertex_display_objects.push(vertex_display_object);
    }
    
    // Is this unnecessary duplication?
    for (var i = 0; i < vertex_display_objects.length; i++)
    {
        vertex_display_objects[i].drag(
            
            function (index) {
                ////
                // Need to use a closure
                ////
                return function(dx, dy, cx, cy, e){
                    e.stopPropagation();
                
                    this.attr({
                        cx: initialXs[index] + dx,
                        cy: initialYs[index] + dy
                    });
                    
                    setVertices(e,index,this.attr('cx'), this.attr('cy'));
                    updateMidpoints(index);
                    
                    changePolygonNotePosition();
                };
            }(i),
            
            function (index) {
            
                return function (cx, cy, e) {
                    e.stopPropagation();
                    
                    initialXs[index] = this.attr("cx");
                    initialYs[index] = this.attr("cy");
                }
                
            }(i),
            
            function (index) {
                return function() {
                    savePolygonLocationData(vertices, control_midpoints);
                }
            }(i)
        );
    }
    
    ////
    // Draw the control midpoints
    ////
    
    initialMidpointXs = new Array(control_midpoints.length), 
    initialMidpointYs = new Array(control_midpoints.length);
    
    for (var i = 0; i < control_midpoints.length; i++)
    {   
        var control_midpoint_display_object = canvas.circle(control_midpoints[i].x,
                                                            control_midpoints[i].y,
                                                            5);
        
          control_midpoint_display_object.attr({fill: '#FFF',
                                                "stroke-width": 1
                                              });
                                                                
        control_midpoint_display_objects.push(control_midpoint_display_object);
    }
    
    for (var i = 0; i < control_midpoint_display_objects.length; i++)
    {
        control_midpoint_display_objects[i].drag(
            
            function (index) {
                return function(dx, dy, cx, cy, e){
                    e.stopPropagation();
                
                    this.attr({
                        cx: initialMidpointXs[index] + dx,
                        cy: initialMidpointYs[index] + dy
                    });
                    
                    setControlMidpoints(e,index,this.attr('cx'), this.attr('cy'));
                    
                    changePolygonNotePosition();
                };
            }(i),
            
            function (index) {
            
                return function (cx, cy, e) {
                    e.stopPropagation();
                    
                    initialMidpointXs[index] = this.attr("cx");
                    initialMidpointYs[index] = this.attr("cy");
                    
                    setTempVertices(index, this.attr("cx"), this.attr("cy"));
                }
                
            }(i),
            
            function (index) {
                return function() {
                    replaceVertices(temp_vertices);
                    
                    savePolygonLocationData(vertices, control_midpoints);
                }
            }(i)
        );
    }
}

function updateMidpoints(index)
{
    var this_index = index;
    var prev_index = index - 1;
    
    if (prev_index < 0) {
        prev_index = prev_index + vertices.length;
    }
    
    var next_index = index + 1;
    
    if (next_index >= vertices.length) {
        next_index = next_index - vertices.length;
    }
    
    control_midpoints[this_index].x = .5*(vertices[this_index].x + vertices[next_index].x);
    
    control_midpoints[prev_index].x = .5*(vertices[prev_index].x + vertices[this_index].x);
    
    control_midpoints[this_index].y =  .5*(vertices[this_index].y +  vertices[next_index].y);
    
    control_midpoints[prev_index].y =  .5*(vertices[prev_index].y +  vertices[this_index].y);
     
    control_midpoint_display_objects[this_index].attr({cx: control_midpoints[this_index].x, 
                                                       cy: control_midpoints[this_index].y});
     
    control_midpoint_display_objects[prev_index].attr({cx:  control_midpoints[prev_index].x, 
                                                       cy: control_midpoints[prev_index].y});
}

function setTempVertices(index, cx, cy)
{
    temp_vertices = new Array(vertices.length + 1);
    var j = 0;
    
    for (var i = 0; i < vertices.length; i++)
    {
        temp_vertices[j] = vertices[i];
        j = j + 1;
        if (i == index)
        {
            temp_vertices[j] = {x: cx, y: cy};
            j = j + 1;
        }   
    }
    
    redrawPathOnVertexDrag(temp_vertices);
}

function setControlMidpoints(e, index, x, y)
{
    control_midpoints[index].x = x;
    control_midpoints[index].y = y;
    temp_vertices[index + 1].x = x;
    temp_vertices[index + 1].y = y;
    
    redrawPathOnVertexDrag(temp_vertices);
}

function setVertices(e,index,x,y)
{
    vertices[index].x = x;
    vertices[index].y = y;
    
    redrawPathOnVertexDrag(vertices);
}

function undoDrawEvents()
{
    var canvas_element = document.getElementById('canvas');
    canvas_element.onmousemove = null;
    canvas_element.onclick = null;
    canvas_element.ondblclick = null;
}

function handleScrolling(e)
{
    pre_scroll_y = circle.attr('cy');
    moveControl(e);
}

function moveControl(e)
{
    circle.show();
    
    var map_element = document.getElementById('map');
    
    //var prev_scroll_top;
    
    if (e.type == "scroll")
    {
        console.log('scrolling');
        
        /*
        var scroll_delta = document.body.scrollTop - prev_scroll_top;
        
        circle.attr({
            cx: circle.attr('cx'),
            cy: pre_scroll_y + scroll_delta
        });
    
        console.log(circle.attr('cy'));
        prev_scroll_top = document.body.scrollTop;
        */
        
    } else {
        circle.attr({
            //cx: e.pageX - map_element.offsetLeft,
            //cy: e.pageY - map_element.offsetTop
            cx: e.pageX - 10,
            cy: e.pageY - document.getElementById('nav').offsetHeight
        });                        
    }
    
    if (draw_path) {
        drawNewPath(e);
    }
}

function addPolygon()
{   
    if (draw_mode)
    {
        alert('You are already trying to draw a polygon.');
        return;
    }
    
    draw_mode = true;
    
    changeNoteButtonStyle('polygon');
    
    if (active_polygon != -1)
    {
        savePolygon(active_polygon, true);
        active_polygon = -1;
    }
                                          
    ////
    // Clear out the previous data if necessary
    ////
    
    draw_path = false;
    start = true;
    new_path = null;
    previous_paths = [];
    
    circle = canvas.circle(20,20,6);
    circle.attr({fill: '#000',
                 stroke: "none"
                });
    
    circle.hide();
    
    var canvas_element = document.getElementById('canvas');
    
    canvas_element.onmousemove = moveControl;
    canvas_element.onclick = handlePath;
    canvas_element.ondblclick = setPolygon;
    
    // Handle scrolling
    //window.onscroll = handleScrolling;
}
                               
function convertPolyPointsToLocations()
{
    polygon_location_data = new Array(vertices.length);
    
    for (var i=0; i < vertices.length; i++)
    {
        var vertex_point = new MM.Point(vertices[i].x, vertices[i].y);
        var location= map.pointLocation(vertex_point);
        polygon_location_data[i] = location;
    }
}

function savePolygonLocationData(vertices, control_midpoints)
{
    polygon_location_data = new Array(vertices);
    control_location_data = new Array(control_midpoints);
    
    for (var i=0; i < vertices.length; i++)
    {
        var vertex_point = new MM.Point(vertices[i].x, vertices[i].y);
        var location= map.pointLocation(vertex_point);
        polygon_location_data[i] = location;
    }
    
    for (var i=0; i < control_midpoints.length; i++)
    {
        var vertex_point = new MM.Point(control_midpoints[i].x, control_midpoints[i].y);
        var location= map.pointLocation(vertex_point);
        control_location_data[i] = location;
    }
    
    saved_polygon_location_data[active_polygon] = polygon_location_data;
    saved_control_location_data[active_polygon] = control_location_data;
}

map.addCallback('panned', function(m) {
    redrawPolygonsAndVertices();
});

map.addCallback('resized', function(m) {
    redrawPolygonsAndVertices();
});

map.addCallback('zoomed', function(m) {
    redrawPolygonsAndVertices();
});

map.addCallback('centered', function(m) {
    redrawPolygonsAndVertices();
});

map.addCallback('extentset', function(m) {
    redrawPolygonsAndVertices();
});

function updateTextArea(note)
{
    if (saved_polygons[active_polygon].new_note)
    {
        document.getElementById('new_polygon_textarea').value = note;
    } else {
        document.getElementById('polygon_textarea').value = note;
    }
}

function updateTipTextArea(note, user, created)
{
    if (created && user)
    {
        var date = new Date(created*1000);
        var day = date.getDay();
        var month = date.getMonth();
        var year = date.getFullYear();
        
        var formatted_date = day + '/' + month + '/' + year;
    
        document.getElementById('polygon_tip').innerHTML = note + '<br><br>' + formatted_date;
    } else {
        document.getElementById('polygon_tip').innerHTML = note;
    }
}

function compute_area_of_polygon(vertices)
{
    var area = 0;
    var j = vertices.length - 1
    
    for (var i=0; i < vertices.length; i++)
    {
        var point1 = vertices[i];
        var point2 = vertices[j];
        
        area = area + point1.x*point2.y;
        area = area - point1.y*point2.x;
        
        j = i;
    }
    
    area = .5 * area;
    
    return area;                    
}

function getCentroid()
{
    var num_of_vertices = vertices.length;
    
    var j = num_of_vertices - 1;
    var x = 0;
    var y = 0;
    
    for (var i=0; i < num_of_vertices; i++)
    {
        var point1 = vertices[i];
        var point2 = vertices[j];
        
        var diff = point1.x*point2.y - point2.x*point1.y;
        
        x = x + diff * (point1.x+point2.x);
        y = y + diff * (point1.y+point2.y);
        
        j = i;
    }


    var factor = 6 * compute_area_of_polygon(vertices);

    var centroid = [x/factor,y/factor];
    
    var converted_centroid = map.pointLocation(new MM.Point(centroid[0], centroid[1]));

    return converted_centroid;
}

function submitPolygonNote()
{                        
    if (active_polygon === -1)
    {
        return;
    }

    if (saved_polygons[active_polygon].new_note)
    {
        if (document.getElementById('new_polygon_textarea').value.trim() == ''){
            alert('Please fill out your note!');
            return false;
        }
    } else {
        if (document.getElementById('polygon_textarea').value.trim() == ''){
            alert('Please fill out your note!');
            return false;
        }
    }
    
    savePolygon(active_polygon, true);
    
    var geometry_string = 'POLYGON ((';         
    
    for (var i = 0; i < saved_polygon_location_data[active_polygon].length; i++)
    {
        if (i == (saved_polygon_location_data[active_polygon].length - 1))
        {
            geometry_string = geometry_string + saved_polygon_location_data[active_polygon][i].lon + ' '  + saved_polygon_location_data[active_polygon][i].lat + '))';
        } else {
            geometry_string = geometry_string + saved_polygon_location_data[active_polygon][i].lon + ' '  + saved_polygon_location_data[active_polygon][i].lat + ', ';
        }
    }
    
    saved_polygons[active_polygon].note_data.geometry = geometry_string;
    
    var centroid = getCentroid();
    
    saved_polygons[active_polygon].note_data.lat = centroid.lat;
    saved_polygons[active_polygon].note_data.lon = centroid.lon;
    
    saved_polygons[active_polygon].note_data.user_id = current_user_id;
    
    if (saved_polygons[active_polygon].new_note)
    {
        if (document.getElementById('new_polygon_textarea').value.trim() == ''){
            alert('Please fill out your note!');
            return false;
        }
        
        saved_polygons[active_polygon].note_data.note = document.getElementById('new_polygon_textarea').value;
    } else {
        if (document.getElementById('polygon_textarea').value.trim() == ''){
            alert('Please fill out your note!');
            return false;
        }
        
        saved_polygons[active_polygon].note_data.note = document.getElementById('polygon_textarea').value;
    }
    
    var saved_polygon_index = active_polygon;
    
    reqwest({
        url: post_url,
        method: 'post',
        data: saved_polygons[active_polygon].note_data,
        type: 'json',
        success: function (resp) {
          console.log('response', resp);
          setMarkerNumber(resp.note_data.note_number, saved_polygon_index);
        }
    });
    
    saved_polygons[active_polygon].new_note = false;
    
    active_polygon = -1;
    
    return false; 
}


function setMarkerNumber(marker_number, index)
{
    console.log('marker_number', marker_number);
    console.log('index', index);
    
    saved_polygons[index].note_data.marker_number = marker_number;
}

function resetPolygonNote()
{
    console.log('active polygon', active_polygon);
                            
    saved_polygon_location_data[active_polygon] = last_saved_polygon_location_data[active_polygon];
    
    document.getElementById('polygon_textarea').value = saved_polygons[active_polygon].note_data.note;
    
    redrawActivePolygonFromLocationData(saved_polygon_location_data[active_polygon]);
}

function redrawActivePolygonFromLocationData(polygon_location_data)
{
    var temp_vertices = [];
    
    // Update Vertices
    for (var i = 0; i < polygon_location_data.length; i++)
    {
        var polygon_point_data = map.locationPoint(polygon_location_data[i]);
        temp_vertices[i] = {x: polygon_point_data.x,
                            y: polygon_point_data.y};
    }
    
    redrawPathOnVertexDrag(temp_vertices);
    replaceVertices(temp_vertices);
    savePolygon(active_polygon, true);
    active_polygon = -1;
}

function deleteNewPolygonNote()
{   
    if (active_polygon === -1)
    {
        return;
    }
    
    savePolygon(active_polygon, true);
        
    removeDeletedPolygonDisplay(active_polygon);
    hidePolygonNote(true);
    
    active_polygon = -1;

    return false;
}

function deletePolygonNote()
{   
    if (active_polygon === -1)
    {
        return;
    }
    
    savePolygon(active_polygon, true);
    
    if (window.confirm("Are you sure you want to delete this saved note?"))
    {
        saved_polygons[active_polygon].note_data.removed = 1;
        
        var saved_polygon_index = active_polygon;
        
        active_polygon = -1;
        
        reqwest({
            url: post_url,
            method: 'post',
            data: saved_polygons[saved_polygon_index].note_data,
            type: 'json',
            success: function (resp) {
              console.log('response', resp);
              removeDeletedPolygonDisplay(saved_polygon_index);
            }
        });
    }

    return false;
}

function removeDeletedPolygonDisplay(saved_polygon_index)
{
    saved_polygons[saved_polygon_index]['polygon'].remove();
    
    for (var i = 0; i < saved_polygons[saved_polygon_index]['vertex_display_objects'].length; i++)
    {
        saved_polygons[saved_polygon_index]['vertex_display_objects'][i].remove();
        saved_polygons[saved_polygon_index]['control_midpoint_display_objects'][i].remove();
    }
    
    saved_polygons[saved_polygon_index] = null;
}