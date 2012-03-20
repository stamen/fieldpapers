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
        <script type="text/javascript" src="{$base_dir}/raphael-min.js"></script>
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
            z-index: 4;
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
        
        #canvas {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 3;
        }
        
        .smaller {
            width: 960px; 
            height: 500px;
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
                        <button type="button" onClick= "addPolygon()">Add Polygon</button>
                    </div>
                    <p>
                        Uploaded by <a href="person.php?id={$scan.user_id}">{$user_name}</a>, 
                        <a href="uploads.php?month={"Y-m"|@date:$scan.created}">{$scan.age|nice_relativetime|escape}</a><br>
                        {if $page_number}
                            <b>Page {$page_number}<b>,
                        {/if}
                        Atlas <a href="print.php?id={$scan.print_id}">{$scan.print_id}</a>
                        {if $scan.place_woeid}
                            <a href="{$base_dir}/uploads.php?place={$scan.place_woeid}">{$scan.place_name|nice_placename}</a>,
                        {/if}
                        <a href="{$base_dir}/uploads.php?place={$scan.country_woeid}">{$scan.country_name|nice_placename}</a>
                        <span id="polygon-enabled" style="float: right">Polygon drawing currently disabled</span>
                    </p>
                </p>
            
                {if $form.form_url}
                <form id="scan-form" action="{$base_dir}/save-scan-notes.php?scan_id={$scan.id}" method="POST">
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
                    <form id="scan-form" action="{$base_dir}/save-scan-notes.php?scan_id={$scan.id}" method="POST">
                        <div class="marker">
                            <textarea id="polygon_note" class="show" style="background-color: white">Note</textarea>
                            <button type="button" style="" onclick="submitPolygonNote();">OK</button>
                        </div>
                    </form>
                    <div class="page_map smaller" id="map">
                        <div id="canvas"></div>
                    </div>
                                
                {/if}
    
                <script type="text/javascript">
                // <![CDATA[{literal}
                    
                    var MM;
                    var map;
                    
                    var circle;
                    var follow_mouse = true;
                    var draw_path = false;
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
                    // Dealing with Notes
                    ///
                    var markerNumber = -1;
                    var unsignedMarkerNumber = 1;
                    
                    var post_url = '{/literal}{$base_dir}{literal}/save-scan-notes.php?scan_id={/literal}{$scan.id}{literal}';   
                    
                        MM = com.modestmaps;
                        var provider = '{/literal}{$scan.base_url}{literal}/{Z}/{X}/{Y}.jpg';
                        map = new MM.Map("map", new MM.TemplatedMapProvider(provider), null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
                        
                    var bounds = '{/literal}{$scan.geojpeg_bounds}{literal}'.split(','),
                        north = parseFloat(bounds[0]),
                        west = parseFloat(bounds[1]),
                        south = parseFloat(bounds[2]),
                        east = parseFloat(bounds[3]),
                        extents = [new MM.Location(north, west), new MM.Location(south, east)];
                    
                    map.setExtent(extents);
                    map.zoomIn();
                    
                    canvas = Raphael("canvas");
                    
                    loadPolygonData();
                    
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
                            
                            console.log(note_geometry);
                            
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
                                
                                console.log(polygon_loc_vertices);
                                
                                var polygon_vertices = [];
                                for (var i = 0; i < polygon_loc_vertices.length; i++)
                                {
                                    var p_loc = new MM.Location(polygon_loc_vertices[i][1], polygon_loc_vertices[i][0]);
                                    var p_point = map.locationPoint(p_loc);
                                    
                                    polygon_vertices[i] = p_point;
                                }
                                
                                console.log(polygon_vertices);
                                
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
                        new_polygon.attr("fill", "#050505");
                        new_polygon.attr("opacity", .3);
                        
                        readVertices(polygon_vertices);
                        
                        createPolygon(note_data);
                        
                        savePolygonLocationData(vertices, control_midpoints);
                        
                        new_polygon.click(function(index) {
                                            return function() { changePolygon(index); }
                                        }(saved_polygons.length - 1));
                        
                        // Inactivate the loaded polygons
                        savePolygon(active_polygon);
                        active_polygon = -1;
                        document.getElementById('polygon_note').value = '';
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
                                                                      7);
                            
                            vertex_display_object.attr('fill', '#050505');
                                                                                    
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
                                                                                7);
                            
                            control_midpoint_display_object.attr('fill', '#FFF');
                                                                                    
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
                    }
                    
                    function savePolygon(index)
                    {
                        saved_polygons[index].vertices = vertices;
                        saved_polygons[index].vertex_display_objects = vertex_display_objects;
                        saved_polygons[index].polygon = new_polygon;
                        saved_polygons[index].control_midpoints = control_midpoints;
                        saved_polygons[index].control_midpoint_display_objects = control_midpoint_display_objects;
                        
                        saved_polygons[index].note_data.note = document.getElementById('polygon_note').value;
                        
                        for (var i = 0; i < vertices.length; i++)
                        {
                            vertex_display_objects[i].hide();
                            control_midpoint_display_objects[i].hide();
                        }
                    }
                    
                    function changePolygon(index)
                    {
                        console.log(index);
                        if (active_polygon != -1)
                        {
                            savePolygon(active_polygon);
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
                        
                        //showPolygonNote();
                    }
                    
                    /*
                    function showPolygonNote()
                    {
                        var textarea_note = document.getElementById('textarea_note');
                        textarea_note.className = 'show';
                    }
                    */
                    
                    function redrawPolygon(vertices, control_midpoints, vertex_display_objects, control_midpoint_display_objects, polygon, polygon_location_data, control_point_location_data)
                    {   
                        console.log('before', vertices);
                        console.log('before', polygon_location_data);
                        // Update Vertices
                        for (var i = 0; i < vertices.length; i++)
                        {
                            var polygon_point_data = map.locationPoint(polygon_location_data[i]);
                            vertices[i].x = polygon_point_data.x;
                            vertices[i].y = polygon_point_data.y;
                        }
                         console.log('after', vertices);
                        
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
                        if (start)
                        {
                            var map_element = document.getElementById('map');
                        
                            start_x = e.pageX - map_element.offsetLeft;
                            start_y = e.pageY - map_element.offsetTop;
                            
                            master_path = "M" + start_x + ',' + start_y;
                            
                            start = false;
                        }
                        // Remember previous path
                        if (new_path && path_string)
                        {
                            prev_path = canvas.path(path_string);
                            prev_path.attr("stroke-width", 4);
                            
                            previous_paths.push(prev_path);
                            
                            master_path = master_path + master_path_piece;
                        }
                        
                        turnOnPath(e);
                    }
                    
                    function turnOnPath(e)
                    {
                        draw_path = true;
                        
                        var map_element = document.getElementById('map');
                        
                        orig_x = e.pageX - map_element.offsetLeft;
                        orig_y = e.pageY - map_element.offsetTop;
                    }
                    
                    function drawNewPath(e)
                    {
                        if (new_path)
                        {
                            new_path.remove();
                        }
                        
                        var map_element = document.getElementById('map');
                        
                        var center_x = e.pageX - map_element.offsetLeft;
                        var center_y = e.pageY - map_element.offsetTop;
                        
                        path_string = "M" + orig_x + ',' + orig_y + "L" + center_x + ',' + center_y;
                        master_path_piece = "L" + center_x + ',' + center_y;
                        
                        new_path = canvas.path(path_string);
                        new_path.attr("stroke-width", 2);
                    }
                    
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
                        
                        var enabled_span = document.getElementById('polygon-enabled');
                        enabled_span.innerHTML = "Polygon drawing currently disabled."
                        enabled_span.style.fontWeight = "normal";
                        
                        master_path = master_path + 'L' + start_x + ',' + start_y + 'Z';
                        
                        var master_path_array = Raphael.parsePathString(master_path);
                        
                        var new_master_path = '';
                        
                        for (i = 0; i < master_path_array.length - 3; i++)
                        {
                            new_master_path = new_master_path + master_path_array[i][0] + master_path_array[i][1] + ',' + master_path_array[i][2];
                        }
                        
                        new_master_path = new_master_path + 'L' + start_x + ',' + start_y + 'Z';
                        
                        new_polygon = canvas.path(new_master_path);
                        new_polygon.attr("fill", "#050505");
                        new_polygon.attr("opacity", .3);
                        
                        new_path.remove();
                        
                        for (var i=0; i < previous_paths.length; i++)
                        {
                            previous_paths[i].remove();
                        }
                        
                        addVertices();
                        
                        ////
                        // Handling Note Data
                        ////
                        
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
                        
                        console.log('control midpoints');
                        console.log(control_midpoints);
                    
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
                                                                      7);
                            
                            vertex_display_object.attr('fill', '#050505');
                                                                                    
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
                                                                                7);
                            
                            control_midpoint_display_object.attr('fill', '#FFF');
                                                                                    
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
                                                                      7);
                            
                            vertex_display_object.attr('fill', '#050505');
                                                                                    
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
                                                                                7);
                            
                            control_midpoint_display_object.attr('fill', '#FFF');
                                                                                    
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
                        //console.log(index); // Don't remove this
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
                        //console.log(pre_scroll_y);
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
                                cx: e.pageX - map_element.offsetLeft,
                                cy: e.pageY - map_element.offsetTop
                            });                        
                        }
                        
                        if (draw_path) {
                            drawNewPath(e);
                        }
                    }
                
                    function addPolygon()
                    {   
                        var enabled_span = document.getElementById('polygon-enabled');
                        enabled_span.innerHTML = "Polygon drawing currently enabled."
                        enabled_span.style.fontWeight = "bold";
                                                
                        ////
                        // Clear out the previous data if necessary
                        ////
                        
                        draw_path = false;
                        start = true;
                        new_path = null;
                        previous_paths = [];
                        
                        circle = canvas.circle(20,20,7);
                        circle.attr({
                            fill: "#fff"
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
                        
                        //console.log('save polygon location data');
                        //console.log(polygon_location_data);
                        
                        console.log(active_polygon);
                        console.log(saved_polygon_location_data[active_polygon]);
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
                        document.getElementById('polygon_note').value = note;
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
                        console.log('submit polygon note');
                        
                        console.log('active_polygon', active_polygon);
                        
                        if (active_polygon === -1)
                        {
                            return;
                        }
                        
                        savePolygon(active_polygon);
                        
                        var geometry_string = 'POLYGON ((';       
                        
                        console.log('saved_polygon_location_data', saved_polygon_location_data);                 
                        
                        for (var i = 0; i < saved_polygon_location_data[active_polygon].length; i++)
                        {
                            if (i == (saved_polygon_location_data[active_polygon].length - 1))
                            {
                                geometry_string = geometry_string + saved_polygon_location_data[active_polygon][i].lon + ' '  + saved_polygon_location_data[active_polygon][i].lat + '))';
                            } else {
                                geometry_string = geometry_string + saved_polygon_location_data[active_polygon][i].lon + ' '  + saved_polygon_location_data[active_polygon][i].lat + ', ';
                            }
                        }
                        
                        console.log('geometry_string', geometry_string);
                        
                        saved_polygons[active_polygon].note_data.geometry = geometry_string;
                        
                        var centroid = getCentroid();
                        
                        saved_polygons[active_polygon].note_data.lat = centroid.lat;
                        saved_polygons[active_polygon].note_data.lon = centroid.lon;
                        
                        saved_polygons[active_polygon].note_data.note = document.getElementById('polygon_note').value;
                        
                        console.log('note_data', saved_polygons[active_polygon].note_data);
                        
                        reqwest({
                            url: post_url,
                            method: 'post',
                            data: saved_polygons[active_polygon].note_data,
                            type: 'json',
                            success: function (resp) {
                              console.log('note_data', saved_polygons[active_polygon].note_data);
                              console.log('response', resp);
                              //changeMarkerDisplay(resp);
                            }
                        });
                        
                        active_polygon = -1;
                        
                        return false; 
                    }
                    
                // {/literal}]]>
                </script>                    
                    
                
                </div>
                
            {elseif $scan}
                {include file="en/scan-process-info.htmlf.tpl"}
            {/if}
        </div>
    
</body>
</html>