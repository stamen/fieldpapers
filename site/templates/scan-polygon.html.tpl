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
                    <div class="mapFormHolder">
                        <div class="fieldSet">
                            <iframe align="middle" frameborder="0" src="{$form.form_url}"></iframe>
                        </div>
                        <div class="page_map small" id="map">
                            <div id="canvas"></div>
                        </div>
                    </div>
                    
                {else}
                    <div class="page_map smaller" id="map">
                        <div id="canvas"></div>
                    </div>
                                
                {/if}
    
                    
                <form id="scan-form" action="{$base_dir}/save-scan-notes.php?scan_id={$scan.id}" method="POST">
                    <!-- <input id="notes_submit" type="submit" value="Submit"> -->
                </form>
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
                    var control_midpoint_display_objects = [];
                    
                    var new_polygon;
                    
                    var polygon_location_data = [];
                    
                    var saved_polygons = [];
                    
                    /*
                    function addNewIntermediateVertices(index)
                    {
                        if (index % 2 != 0)
                        {
                            console.log('adding new intermediate vertices');
                            console.log(index);
                            
                            // Add new vertices to the vertices array
                            var intermediate_vertex = {x: .5*(vertices[index-1].x + vertices[index].x),
                                                       y: .5*(vertices[index-1].y + vertices[index].y)};
                            vertices.splice(index-1, 0, intermediate_vertex);
                            
                            intermediate_vertex = {x: .5*(vertices[index].x + vertices[index+1].x),
                                                   y: .5*(vertices[index].y + vertices[index+1].y)};
                                                       
                            vertices.splice(index+1, 0, intermediate_vertex);
                        }
                        
                        addVertices();
                    }
                    */
                    
                    function redrawPolygonAndVertices(polygon_location_data)
                    {
                        console.log('redraw polygon');
                        
                        // Update Vertices
                        for (var i = 0; i < vertices.length; i++)
                        {
                            var polygon_point_data = map.locationPoint(polygon_location_data[i]);
                            console.log(map.locationPoint(polygon_location_data[0]));
                            vertices[i] = {x: polygon_point_data.x, y: polygon_point_data.y};
                        }
                        
                        // Move the vertices
                                                                                              
                        for (var i = 0; i < vertex_display_objects.length; i++)
                        {
                            vertex_display_objects[i].attr({
                                cx: vertices[i].x,
                                cy: vertices[i].y
                            });
                        
                        }
                        
                        // Move the path
                        
                        var new_path = 'M' + vertices[0].x + ',' + vertices[0].y;
                        
                        for (var i = 1; i < vertices.length; i++)
                        {
                            new_path = new_path + 'L' + vertices[i].x + ',' + vertices[i].y;
                        }
                        
                        new_path = new_path + 'Z';
                        
                        new_polygon.attr({
                            path: new_path
                        });
                        
                    }
                    
                    function redrawPathOnVertexDrag(vertex_points)
                    {
                        console.log('redraw path');
                        
                        var new_path = 'M' + vertex_points[0].x + ',' + vertex_points[0].y;
                        
                        for (var i = 1; i < vertex_points.length; i++)
                        {
                            new_path = new_path + 'L' + vertex_points[i].x + ',' + vertex_points[i].y;
                        }
                        
                        new_path = new_path + 'Z';
                        
                        new_polygon.attr({
                            path: new_path
                        });
                                                
                        //savePolygonLocationData();
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
                        //console.log(e);
                        draw_path = true;
                        
                        var map_element = document.getElementById('map');
                        
                        orig_x = e.pageX - map_element.offsetLeft;
                        orig_y = e.pageY - map_element.offsetTop;
                    }
                    
                    function drawNewPath(e)
                    {
                        console.log('new path');
                        //console.log(e);
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
                        console.log('double click');
                        e.stopPropagation();
                        
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
                        console.log(new_master_path);
                        
                        new_polygon = canvas.path(new_master_path);
                        new_polygon.attr("fill", "#050505");
                        new_polygon.attr("opacity", .3);
                        
                        new_path.remove();
                        
                        for (var i=0; i < previous_paths.length; i++)
                        {
                            previous_paths[i].remove();
                        }
                        
                        addVertices();
                        
                        //savePolygonLocationData(vertices);
                        
                        circle.remove();
                        
                        master_path = '';
                        undoDrawEvents();
                    }
                    
                    var initialXs, 
                        initialYs,
                        initialMidpointXs,
                        initialMidpointYs;
                    
                    var delta = {dx: 0, dy: 0};
                    
                    var control_midpoints = [];
                    
                    
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
                        
                        console.log('master path array');
                        console.log(master_path_array);
                        
                        ////
                        // Find the vertices
                        ////
                        
                        for (i = 0; i < master_path_array.length - 3; i++)
                        {
                            /*
                            // Push intermediary vertices
                            if (i > 0)
                            {
                                vertices.push({x: .5*(master_path_array[i-1][1] + master_path_array[i][1]),
                                               y: .5*(master_path_array[i-1][2] + master_path_array[i][2])
                                              });
                            }
                            */
                            
                            // Push main vertices
                            vertices.push({x: master_path_array[i][1], y: master_path_array[i][2]});
                        }
                        
                        /*
                        vertices.push({x: .5*(master_path_array[master_path_array.length-3][1] + master_path_array[master_path_array.length-2][1]),
                                       y: .5*(master_path_array[master_path_array.length-3][2] + master_path_array[master_path_array.length-2][2])
                                      });
                        */
                        
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
                                        
                                        //this.attr("fill", "#FFF");
                                        
                                        initialXs[index] = this.attr("cx");
                                        initialYs[index] = this.attr("cy");
                                    }
                                    
                                }(i),
                                
                                function (index) {
                                    return function() {
                                        console.log('End');
                                        
                                        //savePolygonLocationData(vertices);
                                        
                                        //addNewIntermediateVertices(index);
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
                                        redrawPathOnVertexDrag(temp_vertices);
                                    };
                                }(i),
                                
                                function (index) {
                                
                                    return function (cx, cy, e) {
                                        e.stopPropagation();
                                        
                                        //this.attr("fill", "#FFF");
                                        
                                        initialMidpointXs[index] = this.attr("cx");
                                        initialMidpointYs[index] = this.attr("cy");
                                        
                                        setTempVertices(index, this.attr("cx"), this.attr("cy"));
                                    }
                                    
                                }(i),
                                
                                function (index) {
                                    return function() {
                                        console.log('End');
                                        
										replaceVertices(temp_vertices);
                                        //savePolygonLocationData(vertices);
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
                                        
                                        //this.attr("fill", "#FFF");
                                        
                                        initialXs[index] = this.attr("cx");
                                        initialYs[index] = this.attr("cy");
                                    }
                                    
                                }(i),
                                
                                function (index) {
                                    return function() {
                                        console.log('End');
                                        
                                        replaceVertices(temp_vertices);
                                        
                                        //savePolygonLocationData(vertices);
                                        
                                        //addNewIntermediateVertices(index);
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
                                        
                                        setControlMidPoints(e,index,this.attr('cx'), this.attr('cy'));
                                        
                                        redrawPathOnVertexDrag(temp_vertices);
                                    };
                                }(i),
                                
                                function (index) {
                                
                                    return function (cx, cy, e) {
                                        e.stopPropagation();
                                        
                                        //this.attr("fill", "#FFF");
                                        
                                        initialMidpointXs[index] = this.attr("cx");
                                        initialMidpointYs[index] = this.attr("cy");
                                        
                                        setTempVertices(index, this.attr("cx"), this.attr("cy"));
                                    }
                                    
                                }(i),
                                
                                function (index) {
                                    return function() {
                                        console.log('End');
                                        
                                        replaceVertices(temp_vertices);
                                        
                                        //savePolygonLocationData(vertices);
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
                         
                         control_midpoint_display_objects[this_index].attr({cx: control_midpoints[this_index].x, cy: control_midpoints[this_index].y});
                         
                        control_midpoint_display_objects[prev_index].attr({cx:  control_midpoints[prev_index].x, cy:  control_midpoints[prev_index].y});
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
                        console.log(index); // Don't remove this
                        vertices[index].x = x;
                        vertices[index].y = y;
                        
                        redrawPathOnVertexDrag(vertices);
                    }
                    
                    function undoDrawEvents()
                    {
                        console.log('remove event listener');
                        var canvas_element = document.getElementById('canvas');
                        canvas_element.onmousemove = null;
                        canvas_element.onclick = null;
                        canvas_element.ondblclick = null;
                        //canvas_element.removeEventListener('onmousemove',moveCircle,false)
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
                        console.log('Add Polygon.');
                        
                        //alert('Polygon drawing enabled.');
                        
                        var enabled_span = document.getElementById('polygon-enabled');
                        enabled_span.innerHTML = "Polygon drawing currently enabled."
                        enabled_span.style.fontWeight = "bold";
                        
                        ////
                        // Save the previous polygon
                        ////
                        
                        ////
                        // Clear out the previous data if necessary
                        ////
                        
                        draw_path = false;
                        start = true;
                        new_path = null;
                        
                        if (vertices || vertex_display_objects || previous_paths)
                        {
                            vertices = [];
                            vertex_display_objects = [];
                            previous_paths = [];
                        }
                        
                        canvas = Raphael("canvas");
                        
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
                    
                    function convertPolyPointsToLocations()
                    {
                        console.log('convert poly points');
                        
                        polygon_location_data = new Array(vertices.length);
                        
                        for (var i=0; i < vertices.length; i++)
                        {
                            var vertex_point = new MM.Point(vertices[i].x, vertices[i].y);
                            var location= map.pointLocation(vertex_point);
                            polygon_location_data[i] = location;
                        }
                    }
                    
                    /*
                    function savePolygonLocationData(vertices)
                    {
                        console.log('save polygon location data');
                        
                        polygon_location_data = new Array(vertices.length);
                        
                        for (var i=0; i < vertices.length; i++)
                        {
                            var vertex_point = new MM.Point(vertices[i].x, vertices[i].y);
                            var location= map.pointLocation(vertex_point);
                            polygon_location_data[i] = location;
                        }
                        
                        console.log('converted');
                        console.log(polygon_location_data);
                        //console.log(vertices);
                        //convertPolyPointsToLocations();
                    }
                    */
                    
                    map.addCallback('panned', function(m) {
                        redrawPolygonAndVertices(polygon_location_data);
                    });
                    
                    map.addCallback('zoomed', function(m) {
                        redrawPolygonAndVertices(polygon_location_data);
                    });
                    
                    map.addCallback('centered', function(m) {
                        redrawPolygonAndVertices(polygon_location_data);
                    });
                    
                    map.addCallback('extentset', function(m) {
                        redrawPolygonAndVertices(polygon_location_data);
                    });
                    
                // {/literal}]]>
                </script>                    
                    
                
                </div>
                
            {elseif $scan}
                {include file="en/scan-process-info.htmlf.tpl"}
            {/if}
        </div>
    
</body>
</html>