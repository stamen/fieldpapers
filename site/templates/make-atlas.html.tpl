<!DOCTYPE html>
<html>
<head>
    <title>Make - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/raphael-min.js"></script>
    
    <script type="text/javascript">
        {literal}
        
        var map = null,
            map_layer;
        
        var paper_orientations = {'landscape': 11/8.5, 'portrait': 8.5/11},
            page_aspect_ratio = paper_orientations['landscape'],
            atlas_aspect_ratio;
        
        var rect = null,
            canvas = null,
            lines = null;
        
        var num_rows,
            num_columns;
        
        var scaleControl,
            dragControl,
            dragControlCoordinates,
            scaleControlCoordinates;
        
        var horizontal_add,
            vertical_add,
            horizontal_remove,
            vertical_remove,
            page_dimensions;
        
        var page_button_width = 15,
            page_button_height = 25;
            
        function setProvider(provider)
        {        
            if (provider === "Toner")
            {
                var tileURL = 'http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png';
            } else if (provider === "Bing Aerial") {
                var tileURL = 'http://tiles.teczno.com/bing-lite/{Z}/{X}/{Y}.jpg';
            } else if (provider === "Open Street Map") {
                var tileURL = 'http://tile.openstreetmap.org/{Z}/{X}/{Y}.png';
            }
            
            document.getElementById('provider').value = tileURL;
            
            map_layer.setProvider(new MM.TemplatedMapProvider(tileURL));
        }
        
        function changeOrientation(orientation) {
            if (document.getElementById('orientation').value === orientation)
            {
                return;
            }
            
            document.getElementById('orientation').value = orientation;
        
            var prev_page_width = (scaleControlCoordinates.x - dragControlCoordinates.x)/num_columns;
            var prev_page_height = (scaleControlCoordinates.y - dragControlCoordinates.y)/num_rows;
        
            page_aspect_ratio = paper_orientations[orientation];
            
            atlas_aspect_ratio = (num_columns/num_rows) * page_aspect_ratio;
            console.log(atlas_aspect_ratio);
            
            scaleControlCoordinates.x = dragControlCoordinates.x + num_columns * prev_page_height;
            scaleControlCoordinates.y = dragControlCoordinates.y + num_rows * prev_page_width;
                        
            scaleControl.attr({
                    cx: scaleControlCoordinates.x,
                    cy: scaleControlCoordinates.y
            });
            
            resetAtlasAttributes();
                        
            rect.remove();
            setAtlasBounds(dragControlCoordinates.x, dragControlCoordinates.y, scaleControlCoordinates.x, scaleControlCoordinates.y);
            drawAtlas();
        }
        
        function resetAtlasAttributes()
        {
            var pathString = drawPages(dragControlCoordinates, scaleControlCoordinates,num_rows,num_columns);
            
            lines.attr({
                path: pathString
            });
                            
            horizontal_add.attr({
                x: scaleControlCoordinates.x - .5 * page_button_width,
                y: dragControlCoordinates.y + .5 * (scaleControlCoordinates.y - dragControlCoordinates.y) - .5 * page_button_height
            });
            
            
            horizontal_remove.attr({
                x: scaleControlCoordinates.x - 1.5 * page_button_width,
                y: dragControlCoordinates.y + .5 * (scaleControlCoordinates.y - dragControlCoordinates.y) - .5 * page_button_height
            });
            
            vertical_add.attr({
                x: dragControlCoordinates.x + .5 * (scaleControlCoordinates.x - dragControlCoordinates.x) - .5 * page_button_width,
                y: scaleControlCoordinates.y - .5 * page_button_height
            });
            
            vertical_remove.attr({
                x: dragControlCoordinates.x + .5 * (scaleControlCoordinates.x - dragControlCoordinates.x) - .5 * page_button_width,
                y: scaleControlCoordinates.y - 1.5 * page_button_height
            });
        }
        
        function setAtlasBounds(drag_position_x, drag_position_y, scale_position_x, scale_position_y)
        {
            page_dimensions.x = drag_position_x;
            page_dimensions.y = drag_position_y;
            
            page_dimensions.width = scale_position_x - drag_position_x;
            page_dimensions.height = scale_position_y - drag_position_y;
        }
        
        function drawPages(dragControlCoordinates, scaleControlCoordinates,num_rows,num_columns)
        {
            var width = scaleControlCoordinates.x - dragControlCoordinates.x;
            var increment = width/num_columns;
            
            var pathString = '';
            for (var i = 0; i < num_columns - 1; i++) {
                // Creating string
                var verticalLineX = dragControlCoordinates.x + (i+1) * increment;
                
                pathString = pathString + 'M' + verticalLineX + ',' + dragControlCoordinates.y +
                             'L' + verticalLineX + ',' + scaleControlCoordinates.y;
            }
            
            var height = scaleControlCoordinates.y - dragControlCoordinates.y;
            increment = height/num_rows;
            
            for (var i = 0; i < num_rows - 1; i++) {
                var horizontalLineY = dragControlCoordinates.y + (i+1) * increment;
                
                pathString = pathString + 'M' + dragControlCoordinates.x + ',' + horizontalLineY +
                            'L' + scaleControlCoordinates.x + ',' + horizontalLineY;
            }
            
            return pathString;
        }
        
        function drawAtlas() {
            rect = canvas.rect(dragControlCoordinates.x, 
                               dragControlCoordinates.y,
                               scaleControlCoordinates.x - dragControlCoordinates.x,
                               scaleControlCoordinates.y - dragControlCoordinates.y);
            
            rect.attr("fill", "#ccc");
            rect.attr("fill-opacity", .3);
            rect.attr("stroke", "#050505");
            rect.insertBefore(scaleControl);
            rect.insertBefore(dragControl);
            rect.insertBefore(horizontal_add);
        }
        
        function setAndSubmitData()
        {
            updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
            document.forms['compose_print'].submit();
        }
        
        function updatePageExtents(topLeftPoint, bottomRightPoint)
        {            
            var width_increment = (bottomRightPoint.x - topLeftPoint.x)/num_columns;
            var height_increment = (bottomRightPoint.y -topLeftPoint.y)/num_rows;
            
            var pages = [];
            for (var i = 0; i < num_rows; i++) {
                for (var j = 0; j < num_columns; j++) {
                    var topLeftLocation = map.pointLocation(new MM.Point(topLeftPoint.x + j*width_increment, topLeftPoint.y + i*height_increment));
                    var bottomRightLocation = map.pointLocation(new MM.Point(topLeftPoint.x + (j+1)*width_increment, topLeftPoint.y + (i+1)*height_increment));
                    var page = [topLeftLocation.lat, topLeftLocation.lon, bottomRightLocation.lat, bottomRightLocation.lon];
                    pages.push(page.join(','));
                }
            }
            
            updateAtlasFormFields(pages);
        }
                
        function updateAtlasFormFields(pages)
        {            
            for (var i = 0; i < pages.length; i++)
            {
                var page_extent = document.createElement('input');
                page_extent.name = "pages[" + i + "]";
                page_extent.type = 'hidden';
                page_extent.value = pages[i];
                document.getElementById('compose_print').appendChild(page_extent);
            }
        }
        
        function initUI () {
            ////
            // Map
            ////
            var MM = com.modestmaps;
            
            var toner_provider = new MM.TemplatedMapProvider('http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png');
            map_layer = new MM.Layer(toner_provider);
            
            //map = new MM.Map('map', new MM.TemplatedMapProvider('http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png'));
            map = new MM.Map('map', map_layer);
                                
            //map.setCenterZoom(new MM.Location(37.76, -122.45), 12);
            map.setCenterZoom(new MM.Location({/literal}{$center}{literal}), 10); // Set a default case
            
            var locations = [new MM.Location({/literal}{$extent.ne}{literal}),
                             new MM.Location({/literal}{$extent.sw}{literal})];
            
            // Initialize value of page_zoom input
            document.getElementById('page_zoom').value = 12;
            document.getElementById('provider').value = 'http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png';
            
            ////
            // UI
            ////
            
            // Atlas Information            
            num_rows = 1;
            num_columns = 1;
            
            //Initialize
            atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
            document.getElementById('radio_landscape').checked = true; // Initially landscape
            
            document.getElementById('paper_size').value = 'letter';
            document.getElementById('orientation').value = 'landscape';
                        
            function updateDragControlCoordinates(dx, dy)
            {
                // Make this more general
                dragControlCoordinates.x = dragControlCoordinates.x + dx;
                dragControlCoordinates.y = dragControlCoordinates.y + dy;
            }
            
            function updateScaleControlCoordinates(dx, dy)
            {
                // Make this more general
                scaleControlCoordinates.x = scaleControlCoordinates.x + dx;
                scaleControlCoordinates.y = scaleControlCoordinates.y + dy;
            }
                        
            function checkAtlasOverflow(topLeftPoint, bottomRightPoint, resize)
            {
                var map_extent = map.getExtent();
                var map_top_left_point = map.locationPoint(map_extent[0]);
                var map_bottom_right_point = map.locationPoint(map_extent[1]);
                                
                if (topLeftPoint.x < map_top_left_point.x || topLeftPoint.y < map_top_left_point.y ||
                    bottomRightPoint.x > map_bottom_right_point.x || bottomRightPoint.y > map_bottom_right_point.y)
                { 
                    if (resize === true)
                    {                        
                        var center_point = map.locationPoint(map.getCenter());
                        
                        dragControlCoordinates.x = center_point.x - .5 * page_dimensions.width;
                        dragControlCoordinates.y = center_point.y - .5 * page_dimensions.height;

                        scaleControlCoordinates = {x: dragControlCoordinates.x + page_dimensions.width,
                                                   y: dragControlCoordinates.y + page_dimensions.height};
                        
                        resetAtlas();
                    } else {
                        var dragControlLocation = map.pointLocation(dragControlCoordinates);
                        var scaleControlLocation = map.pointLocation(scaleControlCoordinates);
                        
                        map.setCenterZoom(map.getCenter(),map.getZoom()-1);
                        
                        dragControlCoordinates = map.locationPoint(dragControlLocation);
                        scaleControlCoordinates = map.locationPoint(scaleControlLocation);
                        
                        resetAtlas();
                    }
                }
            }
            
            function resetAtlas()
            {
                setAtlasBounds(dragControlCoordinates.x, dragControlCoordinates.y,scaleControlCoordinates.x,scaleControlCoordinates.y);
                
                dragControl.attr({
                        cx: dragControlCoordinates.x,
                        cy: dragControlCoordinates.y
                });
                
                scaleControl.attr({
                        cx: scaleControlCoordinates.x,
                        cy: scaleControlCoordinates.y
                });
                
                
                rect.attr({
                    x: dragControlCoordinates.x,
                    y: dragControlCoordinates.y,
                    width: scaleControlCoordinates.x - dragControlCoordinates.x,
                    height: scaleControlCoordinates.y - dragControlCoordinates.y
                });
                
                resetAtlasAttributes();
            }
                        
            /////
            /// Set up the display objects
            /////
            
            canvas = Raphael("canvas");
                        
            var ne_location = new MM.Location({/literal}{$extent.ne}{literal});
            var sw_location = new MM.Location({/literal}{$extent.sw}{literal});
            
            var nw_point = map.locationPoint(new MM.Location(ne_location.lat,sw_location.lon));
            var se_point = map.locationPoint(new MM.Location(sw_location.lat,ne_location.lon));
            
            var center_point = map.locationPoint(new MM.Location({/literal}{$center}{literal}));
            
            var page_height = 200,
                canvasOriginX = (center_point.x - .5 * page_height * atlas_aspect_ratio) || 160,
                canvasOriginY = (center_point.y - .5 * page_height) || 160,
                controlRadius = 15;
                            
            // Initialize Coordinate Objects
            scaleControlCoordinates = {x: page_height*atlas_aspect_ratio + canvasOriginX, y: page_height + canvasOriginY};
            dragControlCoordinates = {x: canvasOriginX, y: canvasOriginY};
                        
            horizontal_add = canvas.rect(canvasOriginX+page_height*atlas_aspect_ratio-.5*page_button_width,
                                         canvasOriginY + .5 * page_height - .5 * page_button_height,
                                         page_button_width,
                                         page_button_height);
            horizontal_add.attr("stroke", "#050505");
            horizontal_add.attr("fill", "#fff");
            horizontal_add.attr("fill-opacity", 1);
            
            horizontal_remove = canvas.rect(canvasOriginX + page_height * atlas_aspect_ratio - 1.5 * page_button_width,
                                            canvasOriginY + .5 * page_height - .5 * page_button_height,
                                            page_button_width,
                                            page_button_height);
            horizontal_remove.attr("stroke", "#050505");
            horizontal_remove.attr("fill", "#050505");
            horizontal_remove.attr("fill-opacity", 1);
            
            vertical_add = canvas.rect(canvasOriginX + .5 * page_height * atlas_aspect_ratio - .5 * page_button_width,
                                       canvasOriginY + page_height - .5 * page_button_height,
                                       page_button_width,
                                       page_button_height);
            vertical_add.attr("stroke", "#050505");
            vertical_add.attr("fill", "#fff");
            vertical_add.attr("fill-opacity", 1);
            
            vertical_remove = canvas.rect(canvasOriginX + .5 * page_height * atlas_aspect_ratio - .5 * page_button_width,
                                          canvasOriginY + page_height - 1.5 * page_button_height,
                                          page_button_width,
                                          page_button_height);
            vertical_remove.attr("stroke", "#050505");
            vertical_remove.attr("fill", "#050505");
            vertical_remove.attr("fill-opacity", 1);
            
            dragControl = canvas.circle(canvasOriginX,canvasOriginY,controlRadius);
            dragControl.attr("fill", "#050505");
            dragControl.attr("fill-opacity", 1);
            
            scaleControl = canvas.circle(canvasOriginX + page_height * atlas_aspect_ratio, canvasOriginY + page_height,controlRadius);
            scaleControl.attr("fill", "#fff");
            
            drawAtlas(scaleControl,dragControl,horizontal_add);
            
            var pathString = drawPages(dragControlCoordinates, scaleControlCoordinates,num_rows,num_columns);
            
            lines = canvas.path(pathString);
            lines.attr("stroke", "#050505");
            lines.insertBefore(rect);
            
            page_dimensions = {x: canvasOriginX, y: canvasOriginY, width: page_height*atlas_aspect_ratio, height: page_height};
            
            /////
            // Drag Control drag handler: move, start, end
            /////
            var initialX, initialY; // These are used by the dragControl handler and the scaleControl handler
                        
            var delta = {dx: 0, dy: 0};
            
            dragControl.drag(
            
                function (dx,dy,x,y,e) {
                    e.stopPropagation();
                    
                    dragControlCoordinates.x = initialX + dx;
                    dragControlCoordinates.y = initialY + dy;
                    
                    scaleControlCoordinates.x = dragControlCoordinates.x + page_dimensions.width;
                    scaleControlCoordinates.y = dragControlCoordinates.y + page_dimensions.height;
                    
                    setAtlasBounds(dragControlCoordinates.x, dragControlCoordinates.y,scaleControlCoordinates.x,scaleControlCoordinates.y);
                    
                    dragControl.attr({
                            cx: dragControlCoordinates.x,
                            cy: dragControlCoordinates.y
                    });
                    
                    scaleControl.attr({
                            cx: scaleControlCoordinates.x,
                            cy: scaleControlCoordinates.y
                    });
                    
                    rect.attr({
                        x: dragControlCoordinates.x,
                        y: dragControlCoordinates.y
                    });
                    
                    resetAtlasAttributes();
                },
            
                function(x,y,e) {                                
                    e.stopPropagation();
                    
                    initialX = dragControl.attr("cx");
                    initialY = dragControl.attr("cy");
                },
            
                function () {                                                
                    checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates);
                }
            );
            
            /////
            // scaleControl drag handler: move, start, end
            /////
            
            scaleControl.drag(
            
                function(dx, dy, mouseX, mouseY, e) {
                    var curX = initialX + dx;
                    var curY = initialY + dy;
                    
                    var mouse_width_dx = curX - page_dimensions.x;
                    var mouse_height_dy = curY - page_dimensions.y;
                    
                    if (mouse_width_dx <= 0 || mouse_height_dy <= 0) 
                    {
                        return;
                    }
                    
                    var new_width,
                        new_height;
                        
                    if ((mouse_width_dx/mouse_height_dy) >= atlas_aspect_ratio)
                    {
                        // Change X to track mouse
                        new_width = mouse_width_dx;
                        new_height = mouse_width_dx/atlas_aspect_ratio;
                    } else {
                        // Change Y to track mouse
                        new_width = mouse_height_dy * atlas_aspect_ratio;
                        new_height = mouse_height_dy;
                    }
                    
                    this.attr({
                        cx: page_dimensions.x + new_width,
                        cy: page_dimensions.y + new_height
                    });           
                    
                    scaleControlCoordinates.x = this.attr("cx");
                    scaleControlCoordinates.y = this.attr("cy");
                    
                    setAtlasBounds(dragControlCoordinates.x, dragControlCoordinates.y,scaleControlCoordinates.x, scaleControlCoordinates.y);     
                                                           
                    rect.remove();
                    drawAtlas(scaleControl,dragControl,horizontal_add);
                    
                    resetAtlasAttributes();
                },
                
                function(mouseX,mouseY,e) {
                    e.stopPropagation();
                
                    scaleControlCoordinates.x = this.attr("cx");
                    scaleControlCoordinates.y = this.attr("cy");
                                    
                    initialX = scaleControlCoordinates.x;
                    initialY = scaleControlCoordinates.y;
                },
                
                function(e) {
                    scaleControlCoordinates.x = this.attr("cx");
                    scaleControlCoordinates.y = this.attr("cy");
                    
                    checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates);
                }
            );

            var addHorizontalPage = function() {
                num_columns++;
                
                if (num_rows * num_columns > 1)
                {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Pages';
                } else {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Page';
                }
                
                atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.width = page_dimensions.width * (num_columns/(num_columns - 1))
                
                scaleControlCoordinates.x = page_dimensions.x + page_dimensions.width;
                scaleControl.attr({
                    cx: scaleControlCoordinates.x
                });
                
                checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates);
                                
                rect.attr({
                    // This is really atlas dimensions at this point.
                    width:  page_dimensions.width
                });
                
                resetAtlasAttributes();
            }
            
            var removeHorizontalPage = function() {
                if (num_columns === 1)
                {
                    return;
                }
            
                num_columns--;
                
                if (num_rows * num_columns > 1)
                {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Pages';
                } else {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Page';
                }
                
                atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.width = page_dimensions.width * (num_columns/(num_columns + 1))
                
                scaleControlCoordinates.x = page_dimensions.x + page_dimensions.width;
                scaleControl.attr({
                    cx: scaleControlCoordinates.x
                });
                
                //checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates); Needed?
                                
                rect.attr({
                    width:  page_dimensions.width
                });
                
                resetAtlasAttributes();
            }
            
            var addVerticalPage = function() {
                num_rows++;
                
                if (num_rows * num_columns > 1)
                {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Pages';
                } else {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Page';
                }
                
                atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.height = page_dimensions.height * (num_rows/(num_rows - 1))
                
                scaleControlCoordinates.y = page_dimensions.y + page_dimensions.height;
                scaleControl.attr({
                    cy: scaleControlCoordinates.y
                });
                
                checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates);
                                
                rect.attr({
                    height:  page_dimensions.height
                });
                
                resetAtlasAttributes();
            }
            
            var removeVerticalPage = function() {
                if (num_rows === 1)
                {
                    return;
                }
                
                num_rows--;
                
                if (num_rows * num_columns > 1)
                {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Pages';
                } else {
                    document.getElementById("page-count").innerHTML = num_rows * num_columns + ' Page';
                }
                
                atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.height = page_dimensions.height * (num_rows/(num_rows + 1))
                
                scaleControlCoordinates.y = page_dimensions.y + page_dimensions.height;
                scaleControl.attr({
                    cy: scaleControlCoordinates.y
                });
                
                //checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates); // Needed?
                                
                rect.attr({
                    height:  page_dimensions.height
                });
                
                resetAtlasAttributes();
            }
                        
            horizontal_add.mousedown(function () {
                this.attr("fill", "#050505");
            });
            
            horizontal_add.click(function () {
                addHorizontalPage();
                this.attr("fill", "#fff");
            });
                        
            horizontal_remove.mousedown(function () {
                this.attr("fill", "#fff");
            });
            
            horizontal_remove.click(function () {
                removeHorizontalPage();
                this.attr("fill", "#050505");
            });
            
            vertical_add.mousedown(function () {
                this.attr("fill", "#000");
            });
            
            vertical_add.click(function () {
                addVerticalPage();
                this.attr("fill", "#fff");
            });
            
            vertical_remove.mousedown(function () {
                this.attr("fill", "#fff");
            });
            
            vertical_remove.click(function () {
                removeVerticalPage();
                this.attr("fill", "#050505");
            });
            
            // Map Callbacks
            map.addCallback('zoomed', function(m) {
                document.getElementById('page_zoom').value = map.getZoom();
            });
            
            map.addCallback('resized', function(m) {
                checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates,true);
            });
        }
        {/literal}
    </script>
    <style type="text/css">
        {literal}
        h1 {
           margin-left: 20px;
        }
        
        body {
           background: #fff;
           color: #000;
           font-family: Helvetica, sans-serif;
           margin: 0;
           padding: 0px;
           border: 0;
        }
        #map {
           width: 100%;
           height: 500px;
           position: relative;
           overflow: hidden;
           z-index: 1;
        }
        
        #canvas {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 2;
        }
        
        #zoom-container {
            width: 64px;
            height: 30px;
            position: absolute;
            padding: 8px 0px 0px 20px;
            z-index: 3;
        }
        
        #zoom-in, #zoom-out {
            cursor: pointer;
        }
        
        .atlas_inputs {
            margin-left: 20px;
        }
        {/literal}
    </style>
</head>
    <body onload="initUI()">
        {include file="navigation.htmlf.tpl"}
        
        <h1>Create Your Atlas</h1>
        <div id="container">

        <div id="map">
            <span id="zoom-container">
                <img src='{$base_dir}/img/plus.png' id="zoom-in"
                          width="30" height="30" onclick="map.setCenterZoom(map.getCenter(),map.getZoom()+1)" />
                <img src='{$base_dir}/img/minus.png' id="zoom-out"
                          width="30" height="30" onclick="map.setCenterZoom(map.getCenter(),map.getZoom()-1)" />
            </span>
            <div id="canvas"></div>
        </div>
        </div>
        <p class="atlas_inputs">                        
            <input type="radio" id="radio_landscape" name="orientation" value="landscape" onclick="changeOrientation(this.value)"> Landscape
            <input type="radio" id="radio_portrait" name="orientation" value="portrait" onclick="changeOrientation(this.value)"> Portrait
            <select style="margin-left:10px" name="provider" onchange="setProvider(this.value);">
                <option>Toner</option>
                <option>Bing Aerial</option>
                <option>Open Street Map</option>
            </select>
            <span style="margin-left:10px"><span id="page-count">1 Page</span>
            

                    
            <form id="compose_print" method="post" action="{$base_dir}/compose-print.php">
                <input type="hidden" name="action" value="compose">
                <input type="hidden" id="page_zoom" name="page_zoom">
                <input type="hidden" id="paper_size" name="paper_size">
                <input type="hidden" id="orientation" name="orientation">
                <input type="hidden" id="provider" name="provider">
                <!-- <input type="hidden" id="form_id" name="form_id"> -->
                
                <select id="forms" name="form_id" style="margin-left: 30px">
                    {if $default_form == 'none'}
                        <option selected>Select a Form for this Atlas</option>
                    {else}
                        <option>Forms</option>
                        <option value="{$default_form.id}" selected>{$default_form.title} ({$default_form.id})</option>
                    {/if}
                    
                    {foreach from=$forms item="form"}
                        {if $form.id != $default_form.id}
                            <option value="{$form.id}">{$form.title} ({$form.id})</option>
                        {/if}
                    {/foreach}
                </select>
                
                <input class="atlas_inputs" type="button" onclick="setAndSubmitData()" value="Make Atlas" />
            </form>
        </p>
    </body>
</html>