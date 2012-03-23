<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>
        Snapshot - fieldpapers.org
    </title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    {if $scan && !$scan.decoded && !$scan.failed}
        <meta http-equiv="refresh" content="5">
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/raphael-min.js"></script>
        <script type="text/javascript" src="{$base_dir}/reqwest.min.js"></script>
        <script type="text/javascript" src="{$base_dir}/marker_notes.js"></script>
    {/if}
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
        
        #atlas_inputs_container {
            height: 0px;
            position: absolute;
            z-index: 2;
            width: 100%;
            top:0;
            text-align: center;
        }
        
        .atlas_inputs {
            font-size: 13px;
            padding: 10px 10px 0px 0px;
            margin: -25px auto 0 auto;
            background-color: #FFF;
            border-top: 2px solid #000;
            width: 200px;
        }
    
        /*
        #area_title_container {
            display: inline-block;
            width: 1em;
            margin: 0px 45px 10px 0px;
            text-align: left;
        }
        */
        
        #toolbar_title {
            font-size: 13px;
            position: relative;
            top: -8px;
            margin: 0px 15px 0px 0px;
        }
        
        .radio_shape {
            background: url("{/literal}{$base_dir}{literal}/img/icon-shape.png") no-repeat;
            display: inline-block;
            padding: 2px 2px 6px 2px;
            margin-left: 5px;
            position: relative;
            top: 3px;
            width: 31px;
            height: 23px;
            cursor: pointer;
        }
        
        .radio_pin {
            background: url("{/literal}{$base_dir}{literal}/img/icon-pin-black.png") no-repeat;
            display: inline-block;
            padding: 2px 0px 2px 2px;
            width: 15px;
            height: 26px;
            cursor: pointer;
        }
        
        #next_button {
            font-size: 13px;
            position: relative;
            top: -8px;
            margin: 0px 0px 0px 10px;
        }
            
        #map {
           width: 100%;
           height: 570px;
           position: absolute;
           background-color: #000;
           overflow: hidden;
           z-index: 1;
        }
        
        .smaller {
            width: 100%; 
            height: 600px;
        }
        
        #zoom-container {
            width: 46px;
            height: 92px;
            position: absolute;
            padding: 8px 0px 0px 20px;
            z-index: 2;
        }
        
        #zoom-in, #zoom-out {
            cursor: pointer;
        }
        
        #canvas {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 3;
        }
    
        #scan-form,
        #scan-form .marker
        {
            position: absolute;
            z-index: 4;
        }
        
        #polygon_note
        {
            background-color: #fff;
            border: 1px solid #050505;
            padding: 5px;
            position: absolute;
            z-index: 5;
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
        
        #textarea_note {
            margin: 0;
            position: absolute;
            z-index: 4;
        }
        
        #textarea_note_button {
            margin: 0;
            position: absolute;
            z-index: 4;
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
    <div id="container" style="position: relative">
            {if $scan && $scan.decoded}
            
                <p>
                    <div class="buttonBar">
                        <button type="button" onClick= "addPolygon()">Add Polygon Note</button>
                        <button type="button" onClick= "addMarkerNote()">Add Marker Note</button>
                    </div>
                </p>
            
                {if $form.form_url}
                <form id="scan-form">
                    <textarea id="textarea_note" class="hide" style="background-color: white">Note</textarea>
                    <input type="button" value="OK" onclick="submitPolygonNote();" />
                </form>
                    <div class="mapFormHolder">
                        <div class="fieldSet">
                            <iframe align="middle" frameborder="0" src="{$form.form_url}"></iframe>
                        </div>
                        <div class="page_map small" id="map">
                            <div id="canvas"></div>
                        </div>
                    </div>
                    
                {else}
                    <div id="atlas_inputs_container">
                        <div class="atlas_inputs">
                            <span id="toolbar_title">
                                <b>Add</b>
                            </span>
                            <div class="radio_pin" id="marker_button" title="Add Marker" onclick="addMarkerNote('marker');"></div>
                            <div class="radio_shape" id="polygon_button" title="Add Polygon" onclick="addPolygon();"></div>
                            <input id="next_button" type="button" value="Finished" onclick="finishedRedirect()">
                        </div>
                    </div>
                    <form id="scan-form">
                        <div id="polygon_note" class="hide">
                            <textarea id="polygon_textarea" style="background-color: white">Note</textarea>
                            <button type="button" id="polygon_ok_button" onclick="submitPolygonNote();">OK</button>
                            <button type="button" id="polygon_delete_button" onclick="deletePolygonNote();">Delete</button>
                        </div>
                    </form>
                    <div id="zoom-container">
                        <span id="zoom-in" style="display: none;">
                        <img src='{$base_dir}/img/button-zoom-in-off.png' id="zoom-in-button"
                                  width="46" height="46">
                        </span>
                        <span id="zoom-out" style="display: none;">
                            <img src='{$base_dir}/img/button-zoom-out-off.png' id="zoom-out-button"
                                      width="46" height="46">
                        </span>
                    </div>
                    <div id="map">
                        <div id="canvas"></div>
                    </div>
                                
                {/if}
    
                <script type="text/javascript">
                    var scan_id = {$scan.id|json_encode};
                    var base_url = {$base_dir|json_encode};
                    var post_url = base_url + '/save-scan-notes.php?scan_id=' + scan_id;
                    var base_provider = {$scan.base_url|json_encode};
                    var redirect_url = {$scan.print_href|json_encode};
                    var geojpeg_bounds = {$scan.geojpeg_bounds|json_encode};
                    
                    var zoom_in_active = base_url + '/img/button-zoom-in-on.png',
                        zoom_in_inactive = base_url + '/img/button-zoom-in-off.png',
                        zoom_out_active = base_url + '/img/button-zoom-out-on.png',
                        zoom_out_inactive = base_url + '/img/button-zoom-out-off.png';
                
                // <![CDATA[{literal}
                    
                    var MM;
                    var map;
                    
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
                    
                    var saved_polygon_location_data = [];
                    var saved_control_location_data = [];
                    
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
                                        
                        MM = com.modestmaps;
                        var provider = base_provider + '/{Z}/{X}/{Y}.jpg';
                        map = new MM.Map("map", new MM.TemplatedMapProvider(provider), null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
                        
                    var bounds = geojpeg_bounds.split(','),
                        north = parseFloat(bounds[0]),
                        west = parseFloat(bounds[1]),
                        south = parseFloat(bounds[2]),
                        east = parseFloat(bounds[3]),
                        extents = [new MM.Location(north, west), new MM.Location(south, east)];
                    
                    map.setExtent(extents);
                    map.zoomIn();
                    
                    document.getElementById('zoom-out').style.display = 'inline';
                    document.getElementById('zoom-in').style.display = 'inline';
                    
                    canvas = Raphael("canvas");
                    
                    //setMapHeight();
                    // Window Callbacks
                    //window.onresize = setMapHeight;
            
                    
                    displaySavedNotes();
                    loadPolygonData();
                    
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
                    
                    function displaySavedNotes() 
                    {
                        {/literal}{foreach from=$notes item="note"}{literal}
                            var note_geometry = '{/literal}{$note.geometry}{literal}';
                            
                            if (note_geometry.substring(0,5) == 'POINT')
                            {
                                var note = {/literal}{$note.note|@json_encode}{literal},
                                    note_num = {/literal}{$note.note_number}{literal},
                                    lat = {/literal}{$note.latitude}{literal},
                                    lon = {/literal}{$note.longitude}{literal};
                                
                                addSavedNote(note,note_num,lat,lon);
                            }
                        {/literal}{/foreach}{literal}
                    }
                    
                    function loadPolygonData()
                    {
                        {/literal}{foreach from=$notes item="note"}{literal}
                            var note_geometry = '{/literal}{$note.geometry}{literal}';
                            
                            var note_data = {
                                'lat': '{/literal}{$note.latitude}{literal}',
                                'lon': '{/literal}{$note.longitude}{literal}',
                                'note': {/literal}{$note.note|@json_encode}{literal},
                                'marker_number': '{/literal}{$note.note_number}{literal}',
                                'type': 'POINT',
                            };
                            
                            if (note_geometry.substring(0,7) == 'POLYGON')
                            {  
                                note_data.type = 'POLYGON';
                                
                                var polygon_vertices_string = note_geometry.substring(10, note_geometry.length - 2);
                                var polygon_loc_vertices = polygon_vertices_string.split(', ');
                                
                                polygon_loc_vertices = polygon_loc_vertices.map(function(p) { return p.split(' ')});
                                
                                for (var i = 0; i < polygon_loc_vertices.length; i++)
                                {
                                    for (var j = 0; j < polygon_loc_vertices[i].length; j++)
                                    {
                                        polygon_loc_vertices[i][j] = parseFloat(polygon_loc_vertices[i][j]);
                                    }
                                }
                                
                                var polygon_vertices = [];
                                for (var i = 0; i < polygon_loc_vertices.length; i++)
                                {
                                    var p_loc = new MM.Location(polygon_loc_vertices[i][1], polygon_loc_vertices[i][0]);
                                    var p_point = map.locationPoint(p_loc);
                                    
                                    polygon_vertices[i] = p_point;
                                }
                                
                                loadPolygon(note_data, polygon_vertices);
                            }
                        {/literal}{/foreach}{literal}
                    }
                    
                    function loadPolygon(note_data, polygon_vertices)
                    {
                        if (active_polygon != -1)
                        {
                            savePolygon(active_polygon);
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
                                          "stroke-width": 2}); // Working?
                        
                        readVertices(polygon_vertices);
                        
                        createPolygon(note_data);
                        
                        savePolygonLocationData(vertices, control_midpoints);
                        
                        new_polygon.click(function(index) {
                                            return function() { changePolygon(index); }
                                        }(saved_polygons.length - 1));
                        
                        // Inactivate the loaded polygons
                        savePolygon(active_polygon);
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
                                                                      5);
                            
                            vertex_display_object.attr({fill: '#FFF',
                                                        "stroke-width": 2
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
                    
                    
                    function createPolygon(note_data)
                    {
                        // Adding active polygon
                        var polygon_to_add = {'vertices': vertices,
                                              'vertex_display_objects': vertex_display_objects,
                                              'polygon': new_polygon,
                                              'control_midpoints': control_midpoints,
                                              'control_midpoint_display_objects': control_midpoint_display_objects,
                                              'note_data': note_data
                                              };
                        
                        saved_polygons.push(polygon_to_add);
                        
                        active_polygon = saved_polygons.length - 1;
                        updateTextArea(note_data.note);
                        
                        new_polygon.attr({fill: '#F3e50c',
                                          "stroke-width": 2,
                                          "fill-opacity": .25
                                         });
                        showPolygonNote();
                    }
                    
                    function savePolygon(index)
                    {
                        new_polygon.attr({fill: '#F3e50c',
                                          "stroke-width": 2,
                                          "fill-opacity": .25
                                         });
                        
                        saved_polygons[index].vertices = vertices;
                        saved_polygons[index].vertex_display_objects = vertex_display_objects;
                        saved_polygons[index].polygon = new_polygon;
                        saved_polygons[index].control_midpoints = control_midpoints;
                        saved_polygons[index].control_midpoint_display_objects = control_midpoint_display_objects;
                        
                        saved_polygons[index].note_data.note = document.getElementById('polygon_textarea').value;
                        
                        for (var i = 0; i < vertices.length; i++)
                        {
                            vertex_display_objects[i].hide();
                            control_midpoint_display_objects[i].hide();
                        }
                        
                        hidePolygonNote();
                    }
                    
                    function changePolygon(index)
                    {
                        if (active_polygon != -1)
                        {
                            savePolygon(active_polygon);
                            
                            new_polygon.attr({fill: '#F3e50c',
                              "stroke-width": 2,
                              "fill-opacity": .25
                             });
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
                        
                        new_polygon.attr({fill: '#F3e50c',
                          "stroke-width": 2,
                          "fill-opacity": .25
                         });
                                         
                        showPolygonNote();
                    }
                    
                    function showPolygonNote()
                    {                        
                        var polygon_note = document.getElementById('polygon_note');
                        polygon_note.className = 'show';
                        
                        changePolygonNotePosition();
                    }
                    
                    function hidePolygonNote()
                    {
                        var polygon_note = document.getElementById('polygon_note');
                        polygon_note.className = 'hide';
                    }
                    
                    function changePolygonNotePosition()
                    {
                        var polygon_note = document.getElementById('polygon_note');
                        
                        var offsetY = 20;
                        var current_polygon_bbox = new_polygon.getBBox();
                        var note_height = polygon_note.offsetHeight;
                        var note_width = polygon_note.offsetWidth;
                        
                        polygon_note.style.left = current_polygon_bbox.x + .5 * current_polygon_bbox.width - .5 * note_width + 'px';
                        polygon_note.style.top = current_polygon_bbox.y - note_height - offsetY + 'px';
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
                            if (i != active_polygon)
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
                            savePolygon(active_polygon);
                            active_polygon = -1;
                        }
                        
                        if (start)
                        {
                            var map_element = document.getElementById('map');
                        
                            start_x = e.pageX - 10;
                            start_y = e.pageY - document.getElementById('nav').offsetHeight - 13;
                            
                            drawn_path_vertex = canvas.circle(start_x, start_y, 5);
                            
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
                            
                            drawn_path_vertex = canvas.circle(e.pageX - 10, 
                                                              e.pageY - document.getElementById('nav').offsetHeight - 13, 
                                                              5);
                            drawn_path_vertex.attr('fill', '#050505');
                            
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
                        orig_y = e.pageY - document.getElementById('nav').offsetHeight - 13;
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
                        var center_y = e.pageY - document.getElementById('nav').offsetHeight - 13;
                        
                        path_string = "M" + orig_x + ',' + orig_y + "L" + center_x + ',' + center_y;
                        master_path_piece = "L" + center_x + ',' + center_y;
                        
                        new_path = canvas.path(path_string);
                        new_path.attr({"stroke-width": 3, 
                                        "stroke-opacity": 1
                                     });
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
                    
                        if (active_polygon != -1)
                        {
                            savePolygon(active_polygon);
                        }
                        
                        active_polygon = -1;
                        //document.getElementById('polygon_note').value = '';
                        
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
                        
                        createPolygon(note_data);
                        
                        savePolygonLocationData(vertices, control_midpoints);
                        
                        // Give the polygon a click handler to toggle activity
                        new_polygon.click(function(index) { 
                                            return function() { changePolygon(index); }
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
                                                                      5);
                            
                            vertex_display_object.attr({fill: '#FFF',
                                                        "stroke-width": 2
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
                                                                      5);
                            
                            vertex_display_object.attr({fill: '#FFF',
                                                        "stroke-width": 2
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
                                cy: e.pageY - document.getElementById('nav').offsetHeight - 13
                            });                        
                        }
                        
                        if (draw_path) {
                            drawNewPath(e);
                        }
                    }
                
                    function addPolygon()
                    {   
                        changeNoteButtonStyle('polygon');
                        
                        if (active_polygon != -1)
                        {
                            savePolygon(active_polygon);
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
                                     "stroke-width": 0
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
                        document.getElementById('polygon_textarea').value = note;
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
                        
                        savePolygon(active_polygon);
                        
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
                        
                        saved_polygons[active_polygon].note_data.note = document.getElementById('polygon_textarea').value;
                        
                        var saved_polygon_index = active_polygon;
                        
                        reqwest({
                            url: post_url,
                            method: 'post',
                            data: saved_polygons[active_polygon].note_data,
                            type: 'json',
                            success: function (resp) {
                              console.log('response', resp.note_data.marker_number);
                              setMarkerNumber(resp.note_data.marker_number, saved_polygon_index);
                            }
                        });
                        
                        active_polygon = -1;
                        
                        return false; 
                    }
                    
                    
                    function setMarkerNumber(marker_number, index)
                    {
                        saved_polygons[index].note_data.marker_number = marker_number;
                    }
                    
                    
                    function deletePolygonNote()
                    {   
                        if (active_polygon === -1)
                        {
                            return;
                        }
                        
                        savePolygon(active_polygon);
                        
                        if (window.confirm("Are you sure you want to delete this saved note?"))
                        {
                            saved_polygons[active_polygon].note_data.removed = 1;
                            
                            var saved_polygon_index = active_polygon;
                            
                            reqwest({
                                url: post_url,
                                method: 'post',
                                data: saved_polygons[active_polygon].note_data,
                                type: 'json',
                                success: function (resp) {
                                  console.log('response', resp);
                                  removeDeletedPolygonDisplay(saved_polygon_index);
                                }
                            });
                            
                            active_polygon = -1;
                            
                        }
                    
                        return false;
                    }
                    
                    function removeDeletedPolygonDisplay(active_polygon)
                    {
                        saved_polygons[active_polygon]['polygon'].hide();
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
            
                          
                // {/literal}]]>
                </script>                    
            </div>                    
            {elseif $scan}
                {include file="en/scan-process-info.htmlf.tpl"}
            {/if}
        </div>
    
</body>
</html>