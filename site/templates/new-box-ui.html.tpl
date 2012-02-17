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
            var aspect_ratio = 11/8.5; // Sample aspect_ratio for now // Portrait size
            document.getElementById('paper_size').value = 'letter';
            document.getElementById('orientation').value = 'landscape';
            
            // Initialize Coordinate Objects
            var scaleControlCoordinates = {x: 150*aspect_ratio + 30, y:180};
            var dragControlCoordinates = {x:30, y:30};
            
            var updateDragControlCoordinates = function (x, y) {
                dragControlCoordinates.x = x;
                dragControlCoordinates.y = y;
            }
            
            // What's the current page height?
            var page_dimensions = {x: 30, y:30, width: 150*aspect_ratio, height: 150};
            
            var setPageDimensions = function(rect_obj, scale_position_x, scale_position_y) {
                var rect_obj_bounds = rect_obj.getBBox();
                
                page_dimensions.x = rect_obj_bounds.x;
                page_dimensions.y = rect_obj_bounds.y;
                
                page_dimensions.width = scale_position_x;
                page_dimensions.height = scale_position_y;
            
                //console.log(page_dimensions);
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
                
                console.log(page_extent);
            }
            
            ///
            
            var canvas = Raphael("canvas",1000,500);

            var dragSet = canvas.set();
            
            var rect = canvas.rect(30,30,150*aspect_ratio,150);
            rect.attr("stroke", "#050505");
            rect.attr("fill", "#fff");
            rect.attr("fill-opacity", .33);
            dragSet.push(rect);
            addPage(rect);
            
            var horizontal_add = canvas.rect(30+150*aspect_ratio-.5*15,30+.5*150-.5*25,15,25);
            horizontal_add.attr("stroke", "#050505");
            horizontal_add.attr("fill", "#fff");
            horizontal_add.attr("fill-opacity", 1);
            dragSet.push(horizontal_add);
            
            var vertical_add = canvas.rect(30+.5*150*aspect_ratio-.5*15,30+150-.5*25,15,25);
            vertical_add.attr("stroke", "#050505");
            vertical_add.attr("fill", "#fff");
            vertical_add.attr("fill-opacity", 1);
            dragSet.push(vertical_add);
            
            
            var dragControl = canvas.circle(30,30,15);
            dragControl.attr("fill", "#050505");
            dragControl.attr("fill-opacity", 1);
            dragSet.push(dragControl);
            
            var scaleControl = canvas.circle(150*aspect_ratio + 30,180,15);
            scaleControl.attr("fill", "#fff");
            
            /*
            var plusIcon = canvas.path('M25.979,12.896 19.312,12.896 19.312,6.229 12.647,6.229 12.647,\
                            12.896 5.979,12.896 5.979,19.562 12.647,19.562 12.647,26.229 19.312,\
                            26.229 19.312,19.562 25.979,19.562z');
            plusIcon.attr("fill", "#050505");
            plusIcon.scale(.6,.6,0,0);
            */
            
            var dragDeltaOrigX;
            var dragDeltaOrigY;
            
            var start = function(x,y,e) {
                e.stopPropagation();
                dragSet.oBB = dragSet.getBBox();
                
                setExtent([rect.getBBox().x, rect.getBBox().y],
                          [rect.getBBox().x + rect.getBBox().width, rect.getBBox().x + rect.getBBox().height]);
                                
                return false;
            },
            move = function (dx,dy,x,y,event) {
                event.stopPropagation();
                var bbox = dragSet.getBBox();
                dragSet.translate(dragSet.oBB.x - bbox.x + dx, dragSet.oBB.y - bbox.y + dy);
                
                scaleControl.translate(dragSet.oBB.x - bbox.x + dx, dragSet.oBB.y - bbox.y + dy);
                return false;
            },
            up = function () {                                
                dragDeltaOrigX = dragSet.getBBox().x - 15;
                dragDeltaOrigY = dragSet.getBBox().y - 15;
                
                // Update drag control coordinates
                updateDragControlCoordinates(dragControl.attr("cx"), dragControl.attr("cy"));
                
                setExtent([rect.getBBox().x, rect.getBBox().y],
                          [rect.getBBox().x + rect.getBBox().width, rect.getBBox().x + rect.getBBox().height]);
            }
            
            dragSet.drag(move, start, up);
            
            var x,y;
            var initialX, initialY;
            scaleControl.drag(
            
            function(dx, dy, mouseX, mouseY, e) {
                setPageDimensions(rect,this.attr("cx"), this.attr("cy"));
                
                this.attr({
                    cx: Math.max(x + aspect_ratio*dx, dragControlCoordinates.x + aspect_ratio*20),
                    cy: Math.max(y + dx, dragControlCoordinates.y + 20)
                });                
                
                var prev_rect_bbox = rect.getBBox();
                
                
                for (var page in pages) {
                    //console.log(page);
                    var page_object = pages[page];
                    console.log(page_object);
                    //page_object.remove();
                    
                    //page_object = canvas.rect(page_dimensions.x,page_dimensions.y,page_dimensions.width-30,page_dimensions.height-30);
                    
                }
                
                
                rect.remove();
                
                // The rect should be dependent on position of both circles.
                
                rect = canvas.rect(page_dimensions.x,page_dimensions.y,page_dimensions.width-30,page_dimensions.height-30);
                rect.attr("stroke", "#050505");
                rect.attr("fill", "#fff");
                rect.attr("fill-opacity", .33);
                rect.insertBefore(this);
                rect.insertBefore(dragControl);
                rect.insertBefore(horizontal_add);
                //rect.insertBefore(vertical_add); // removing this fixes insertion order?
                
                
                setPageDimensions(rect,this.attr("cx"), this.attr("cy"));
                
                var new_rect_bbox = rect.getBBox();
                
                var dragOffsetX = dragDeltaOrigX || 0;
                var dragOffsetY = dragDeltaOrigY || 0;
                
                horizontal_add.attr({x: new_rect_bbox.x + new_rect_bbox.width - .5 * 15 - dragOffsetX, 
                                     y: new_rect_bbox.y + .5 * new_rect_bbox.height - .5*25 - dragOffsetY});
                
                   
                vertical_add.attr({x: new_rect_bbox.x + .5 * new_rect_bbox.width - .5*15 - dragOffsetX, 
                                   y: new_rect_bbox.y + new_rect_bbox.height - .5*25 - dragOffsetY});
                
                dragSet.clear();
                createNewDragSet();
                
                return false;
            },
            
            function(mouseX,mouseY,e) {
                setExtent([rect.getBBox().x, rect.getBBox().y],
                          [rect.getBBox().x + rect.getBBox().width, rect.getBBox().x + rect.getBBox().height]);
            
                scaleControlCoordinates.x = this.attr("cx");
                scaleControlCoordinates.y = this.attr("cy");
                
                //console.log(scaleControlCoordinates);
            
                e.stopPropagation();
                x = this.attr("cx"),
                y = this.attr("cy")
                
                initialX = x;
                initialY = y;
                                          
                return false;
            },
            
            function(e) {
                this.attr("fill", "#fff");
                
                setExtent([rect.getBBox().x, rect.getBBox().y],
                          [rect.getBBox().x + rect.getBBox().width, rect.getBBox().x + rect.getBBox().height]);
                
                return false;
            }
            );
            
            var createNewDragSet = function () {
                dragSet.push(rect);
                dragSet.push(dragControl);
                dragSet.push(horizontal_add);
                dragSet.push(vertical_add);
            };
            
            var rect_bounds = rect.getBBox();
            
            var addHorizontalPage = function() {
                // TODO: account for the last rect
                // Check for number of rows
                // Do a bounds check
                //rect_bounds = rect.getBBox();
                
                
                var x = rect_bounds.x + rect_bounds.width,
                    y = rect_bounds.y,
                    width = rect_bounds.width,
                    height = rect_bounds.height;
            
                var new_rect = canvas.rect(x,y,width,height);
                new_rect.attr("stroke", "#050505");
                new_rect.attr("fill", "#fff");
                new_rect.attr("fill-opacity", .33);
                
                new_rect.insertBefore(horizontal_add);
                //new_rect.insertBefore(scaleControl); //?
                
                addPage(new_rect);
                dragSet.push(new_rect);
                
                // Move the Horizontal Button and the Scale Control to the correct position
                var new_rect_bounds = new_rect.getBBox();
                scaleControl.attr({                    
                    cx: scaleControl.attr("cx") + new_rect_bounds.width
                });
                
                horizontal_add.attr({
                    x: horizontal_add.attr("x") + new_rect_bounds.width,
                    fill: "#fff"
                });
                
                rect_bounds = new_rect.getBBox();
            }
            
            // Add Pages
            horizontal_add.mousedown(function () {
                this.attr("fill", "#000");
                //addHorizontalPage();
            });
            
            horizontal_add.mouseup(function () {
                addHorizontalPage();
                this.attr("fill", "#fff");
            });
            
            vertical_add.mousedown(function () {
                this.attr("fill", "#000");
            });
            
            vertical_add.mouseup(function () {
                this.attr("fill", "#fff");
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