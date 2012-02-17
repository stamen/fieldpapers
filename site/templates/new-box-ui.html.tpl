<!DOCTYPE html>
<html>
<head>
    <title>New Box UI</title>
    <script type="text/javascript" src="modestmaps.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript" src="raphael-min.js"></script>
    
    <script type="text/javascript">
        {literal}
        function initUI () {
            ////
            // Map
            ////
            var MM = com.modestmaps;
            
            var map = new MM.Map('map', new MM.TemplatedMapProvider('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png'));
                                
            map.setCenterZoom(new MM.Location(37.76, -122.45), 12);
            
            // Initialize value of page_zoom input
            document.getElementById('page_zoom').value = 12;
            
            ////
            // UI
            ////
            
            // Page Information
            // TODO: Make this dynamic
            
            var num_rows = 1;
            var num_columns = 1;
            var page_aspect_ratio = 11/8.5; // Sample aspect_ratio for now // Portrait size
            var aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
            
            document.getElementById('paper_size').value = 'letter';
            document.getElementById('orientation').value = 'landscape';
            
            // Initialize Coordinate Objects
            var scaleControlCoordinates = {x: 150*aspect_ratio + 60, y:180};
            var dragControlCoordinates = {x:60, y:60};
            
            var updateDragControlCoordinates = function (dx, dy) {
                dragControlCoordinates.x = dragControlCoordinates.x + dx;
                dragControlCoordinates.y = dragControlCoordinates.y + dy;
            }
            
            var updateScaleControlCoordinates = function(dx, dy) {
                scaleControlCoordinates.x = scaleControlCoordinates.x + dx;
                scaleControlCoordinates.y = scaleControlCoordinates.y + dy;
            }
            
            // Initializing page_dimensions
            // TODO: Make this dynamic
            var page_dimensions = {x: 60, y:60, width: 150*aspect_ratio, height: 150};
            
            var setPageDimensions = function(drag_position_x, drag_position_y, scale_position_x, scale_position_y) {
                page_dimensions.x = drag_position_x;
                page_dimensions.y = drag_position_y;
                
                page_dimensions.width = scale_position_x - drag_position_x;
                page_dimensions.height = scale_position_y - drag_position_y;
            }
            
            // Remember the pages
            var pages = {};
            var page_count = 0;
            
            var addPage = function(rect_obj) {
                pages[page_count] = rect_obj;
                page_count++;
            }
            
            // Get geographic extent
            var setExtent = function(topLeftPoints, bottomRightPoints) {            
                var topLeftCoords = map.pointLocation(new MM.Point(topLeftPoints[0], topLeftPoints[1]));
                var bottomRightCoords = map.pointLocation(new MM.Point(bottomRightPoints[0], bottomRightPoints[1]));
                                
                var extent = [topLeftCoords.lat, topLeftCoords.lon, bottomRightCoords.lat, bottomRightCoords.lon];
                
                setAtlasPages(extent);
            }
            
            var setAtlasPages = function(extent) {
                //var input_extent = document.getElementById('extent');
                //input_extent.value = extent.join(',');
                var atlas_pages = [];
                atlas_pages.push(extent.join(','));
                
                for (page in pages) {
                    var page_extent = document.getElementById('atlas_pages');
                    //input.name = "pages[" + index + "]";
                    page_extent.name = "pages[0]";
                    page_extent.value = atlas_pages;
                }
            }
            
            /////
            /// Set up the display objects
            /////
            
            var canvas = Raphael("canvas",1000,500);

            var dragSet = canvas.set();
            
            var rect = canvas.rect(60,60,150*aspect_ratio,150);
            rect.attr("stroke", "#050505");
            rect.attr("fill", "#fff");
            rect.attr("fill-opacity", .33);
            dragSet.push(rect);
            setExtent([dragControlCoordinates.x, dragControlCoordinates.y],
                      [scaleControlCoordinates.x, scaleControlCoordinates.y]);
            addPage(rect);
            
            var horizontal_add = canvas.rect(60+150*aspect_ratio-.5*15,60+.5*150-.5*25,15,25);
            horizontal_add.attr("stroke", "#050505");
            horizontal_add.attr("fill", "#fff");
            horizontal_add.attr("fill-opacity", 1);
            dragSet.push(horizontal_add);
            
            var horizontal_remove = canvas.rect(5,5,15,25);
            horizontal_remove.attr("stroke", "#050505");
            horizontal_remove.attr("fill", "#00ff00");
            horizontal_remove.attr("fill-opacity", 1);
            //dragSet.push(horizontal_remove);
            
            var vertical_add = canvas.rect(60+.5*150*aspect_ratio-.5*15,60+150-.5*25,15,25);
            vertical_add.attr("stroke", "#050505");
            vertical_add.attr("fill", "#fff");
            vertical_add.attr("fill-opacity", 1);
            dragSet.push(vertical_add);
            
            var vertical_remove = canvas.rect(25,5,15,25);
            vertical_remove.attr("stroke", "#050505");
            vertical_remove.attr("fill", "#ff0000");
            vertical_remove.attr("fill-opacity", 1);
            //dragSet.push(vertical_remove);
            
            var dragControl = canvas.circle(60,60,15);
            dragControl.attr("fill", "#050505");
            dragControl.attr("fill-opacity", 1);
            dragSet.push(dragControl);
            
            var scaleControl = canvas.circle(150*aspect_ratio + 60,210,15);
            scaleControl.attr("fill", "#fff");
            
            /*
            var plusIcon = canvas.path('M25.979,12.896 19.312,12.896 19.312,6.229 12.647,6.229 12.647,\
                            12.896 5.979,12.896 5.979,19.562 12.647,19.562 12.647,26.229 19.312,\
                            26.229 19.312,19.562 25.979,19.562z');
            plusIcon.attr("fill", "#050505");
            plusIcon.scale(.6,.6,0,0);
            */
            
            /////
            // dragSet drag handler: start, move, end
            /////
            var initialX, initialY; // These are used by the dragSet handler and the scaleControl handler
                        
            var delta = {dx: 0, dy: 0};
            
            var start = function(x,y,e) {                                
                e.stopPropagation();
                
                initialX = dragControl.attr("cx");
                initialY = dragControl.attr("cy");
                
                setExtent([dragControlCoordinates.x, dragControlCoordinates.y],
                          [scaleControlCoordinates.x, scaleControlCoordinates.y]);
                                
                return false;
            },
            move = function (dx,dy,x,y,e) {
                e.stopPropagation();
                
                dragControlCoordinates.x = initialX + dx;
                dragControlCoordinates.y = initialY + dy;
                
                scaleControlCoordinates.x = dragControlCoordinates.x + page_dimensions.width;
                scaleControlCoordinates.y = dragControlCoordinates.y + page_dimensions.height;
                
                setPageDimensions(dragControlCoordinates.x, dragControlCoordinates.y,scaleControlCoordinates.x,scaleControlCoordinates.y);
                
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
                
                horizontal_add.attr({
                    x: page_dimensions.x + page_dimensions.width - .5 * horizontal_add.attr("width"),
                    y: page_dimensions.y + .5 * page_dimensions.height - .5 * horizontal_add.attr("height")
                });
                
                vertical_add.attr({
                    x: page_dimensions.x + .5 * page_dimensions.width - .5 * vertical_add.attr("width"),
                    y: page_dimensions.y + page_dimensions.height - .5 * vertical_add.attr("height")
                });
                
                return false;
            },
            up = function () {                                                
                setExtent([dragControlCoordinates.x, dragControlCoordinates.y],
                          [scaleControlCoordinates.x, scaleControlCoordinates.y]);
            }
            
            dragSet.drag(move, start, up);
            
            /////
            // scaleControl drag handler: move, start, end
            /////
            
            var x,y;
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
                        
                    if ((mouse_width_dx/mouse_height_dy) >= aspect_ratio)
                    {
                        // Change X to track mouse
                        new_width = mouse_width_dx;
                        new_height = mouse_width_dx/aspect_ratio;
                    } else {
                        // Change Y to track mouse
                        new_width = mouse_height_dy * aspect_ratio;
                        new_height = mouse_height_dy;
                    }
                    
                    this.attr({
                        cx: page_dimensions.x + new_width,
                        cy: page_dimensions.y + new_height
                    });           
                    
                    scaleControlCoordinates.x = this.attr("cx");
                    scaleControlCoordinates.y = this.attr("cy");
                    
                    setPageDimensions(dragControlCoordinates.x, dragControlCoordinates.y,scaleControlCoordinates.x, scaleControlCoordinates.y);     
                    
                    /*
                    for (var page in pages) {
                        //console.log(page);
                        var page_object = pages[page];
                        console.log(page_object);
                        //page_object.remove();
                    }
                    */
                    
                    rect.remove();
                    rect = canvas.rect(dragControlCoordinates.x, 
                                       dragControlCoordinates.y,
                                       scaleControlCoordinates.x - dragControlCoordinates.x,
                                       scaleControlCoordinates.y - dragControlCoordinates.y);
                                       
                    rect.attr("stroke", "#050505");
                    rect.attr("fill", "#fff");
                    rect.attr("fill-opacity", .33);
                    rect.insertBefore(this);
                    rect.insertBefore(dragControl);
                    rect.insertBefore(horizontal_add);
                    //rect.insertBefore(vertical_add); // removing this fixes insertion order?
                                             
                horizontal_add.attr({
                    x: page_dimensions.x + page_dimensions.width - .5 * horizontal_add.attr("width"),
                    y: page_dimensions.y + .5 * page_dimensions.height - .5 * horizontal_add.attr("height")
                });
                
                vertical_add.attr({
                    x: page_dimensions.x + .5 * page_dimensions.width - .5 * vertical_add.attr("width"),
                    y: page_dimensions.y + page_dimensions.height - .5 * vertical_add.attr("height")
                });
                    
                    dragSet.clear();
                    createNewDragSet();
                    
                    return false;
                },
                
                function(mouseX,mouseY,e) {
                    e.stopPropagation();
                    
                    setExtent([dragControlCoordinates.x, dragControlCoordinates.y],
                              [scaleControlCoordinates.x, scaleControlCoordinates.y]);
                
                    scaleControlCoordinates.x = this.attr("cx");
                    scaleControlCoordinates.y = this.attr("cy");
                
                    x = this.attr("cx"),
                    y = this.attr("cy")
                    
                    initialX = x;
                    initialY = y;
                                              
                    return false;
                },
                
                function(e) {
                    scaleControlCoordinates.x = this.attr("cx");
                    scaleControlCoordinates.y = this.attr("cy");
                    
                    setExtent([dragControlCoordinates.x, dragControlCoordinates.y],
                              [scaleControlCoordinates.x, scaleControlCoordinates.y]);
                    
                    return false;
                }
            );
            
            var createNewDragSet = function () {
                dragSet.push(rect);
                dragSet.push(dragControl);
                dragSet.push(horizontal_add);
                dragSet.push(vertical_add);
            };
            
            var addHorizontalPage = function() {
                num_columns++;
                
                aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.width = page_dimensions.width * (num_columns/(num_columns - 1))
                
                scaleControlCoordinates.x = page_dimensions.x + page_dimensions.width;
                scaleControl.attr({
                    cx: scaleControlCoordinates.x
                });
                                
                rect.attr({
                    // This is really atlas dimensions at this point.
                    width:  page_dimensions.width
                });
                
                horizontal_add.attr({
                    x: page_dimensions.x + page_dimensions.width - .5 * horizontal_add.attr("width")
                });
                
                vertical_add.attr({
                    x: page_dimensions.x + .5 * page_dimensions.width - .5 * vertical_add.attr("width")
                });
            }
            
            var removeHorizontalPage = function() {
                if (num_columns === 1)
                {
                    return;
                }
            
                num_columns--;
                
                aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.width = page_dimensions.width * (num_columns/(num_columns + 1))
                
                scaleControlCoordinates.x = page_dimensions.x + page_dimensions.width;
                scaleControl.attr({
                    cx: scaleControlCoordinates.x
                });
                                
                rect.attr({
                    // This is really atlas dimensions at this point.
                    width:  page_dimensions.width
                });
                
                horizontal_add.attr({
                    x: page_dimensions.x + page_dimensions.width - .5 * horizontal_add.attr("width")
                });
                
                vertical_add.attr({
                    x: page_dimensions.x + .5 * page_dimensions.width - .5 * vertical_add.attr("width")
                });
            }
            
            var addVerticalPage = function() {
                num_rows++;
                
                aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.height = page_dimensions.height * (num_rows/(num_rows - 1))
                
                scaleControlCoordinates.y = page_dimensions.y + page_dimensions.height;
                scaleControl.attr({
                    cy: scaleControlCoordinates.y
                });
                                
                rect.attr({
                    // This is really atlas dimensions at this point.
                    height:  page_dimensions.height
                });
                
                horizontal_add.attr({
                    y: page_dimensions.y + .5 * page_dimensions.height - .5 * horizontal_add.attr("height")
                });
                
                vertical_add.attr({
                    y: page_dimensions.y + page_dimensions.height - .5 * vertical_add.attr("height")
                });
            }
            
            var removeVerticalPage = function() {
                if (num_rows === 1)
                {
                    return;
                }
                
                num_rows--;
                
                aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
                
                page_dimensions.height = page_dimensions.height * (num_rows/(num_rows + 1))
                
                scaleControlCoordinates.y = page_dimensions.y + page_dimensions.height;
                scaleControl.attr({
                    cy: scaleControlCoordinates.y
                });
                                
                rect.attr({
                    // This is really atlas dimensions at this point.
                    height:  page_dimensions.height
                });
                
                horizontal_add.attr({
                    y: page_dimensions.y + .5 * page_dimensions.height - .5 * horizontal_add.attr("height")
                });
                
                vertical_add.attr({
                    y: page_dimensions.y + page_dimensions.height - .5 * vertical_add.attr("height")
                });
            }
            
            // Add Pages
            horizontal_add.mousedown(function () {
                this.attr("fill", "#000");
            });
            
            horizontal_add.mouseup(function () {
                addHorizontalPage();
                this.attr("fill", "#fff");
            });
            
            horizontal_remove.mouseup(function () {
                removeHorizontalPage();
                this.attr("fill", "#00ff00");
            });
            
            vertical_add.mousedown(function () {
                this.attr("fill", "#000");
            });
            
            vertical_add.mouseup(function () {
                addVerticalPage();
                this.attr("fill", "#fff");
            });
            
            vertical_remove.mousedown(function () {
                this.attr("fill", "#000");
            });
            
            vertical_remove.mouseup(function () {
                removeVerticalPage();
                this.attr("fill", "#ff0000");
            });
            
            // Map Callbacks
            map.addCallback('zoomed', function(m) {
                document.getElementById('page_zoom').value = map.getZoom();
            });
            
        }
        {/literal}
    </script>
    <style type="text/css">
        {literal}
        body {
          background: #fff;
          color: #000;
          font-family: Helvetica, sans-serif;
          margin: 0;
          padding: 20px;
          border: 0;
        }
        #map {
          width: 1000px;
          height: 500px;
          position: relative;
          overflow: hidden;
          z-index: 1;
        }
        
        #canvas {
         position: absolute;
         z-index: 2;
        }
        {/literal}
    </style>
</head>
    <body onload="initUI()">
        <h1>New Box UI</h1>
        <div id="container">
        <div id="map">
            <div id="canvas"></div>
        </div>
        </div>
        <p>
            <form id="submit" method="post" action="http://fieldpapers.org/~mevans/fieldpapers/site/www/compose-print.php">
                <input type="hidden" name="action" value="compose">
                <input type="hidden" id="page_zoom" name="page_zoom">
                <input type="hidden" id="paper_size" name="paper_size">
                <input type="hidden" id="orientation" name="orientation">
                <input type="hidden" id="form_id" name="form_id" value="Select a Form for this Atlas">
                
                
                <input type="hidden" id="atlas_pages" name="pages[]">
                <!-- <input type="hidden" name="extent" id ="extent"> -->
                <input type="submit" value="Make Atlas" />
            </form>
        </p>
    </body>
</html>