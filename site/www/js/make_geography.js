var map = null,
    map_layer,
    overlay_layer;

var paper_orientations = {"landscape": 1.50, "portrait": .75},
    page_aspect_ratio = paper_orientations["landscape"],
    atlas_aspect_ratio;

var rect = null,
    canvas = null,
    lines = null;

var num_rows,
    num_columns;

var scaleControl,
    dragControl,
    dragControlCoordinates,
    scaleControlCoordinates,
    topLeftPageCoord,
    bottomRightPageCoord;

var canvas_fill;

var horizontal_add,
    vertical_add,
    horizontal_remove,
    vertical_remove,
    page_dimensions;

var page_button_width = 33,
    page_button_height = 46,
    remove_column_button_width = 23,
    remove_column_button_height = 26,
    remove_row_button_width = 26,
    remove_row_button_height = 22,
    controlRadius = 23;

function setProvider(tileURL)
{        
    map_layer.setProvider(new MM.TemplatedMapProvider(tileURL));
}

function setOverlayProvider(tileURL) 
{
    overlay_layer.setProvider(new MM.TemplatedMapProvider(tileURL));
    map.draw();
}

function setMapHeight()
{   
    var map_height = window.innerHeight - document.getElementById("nav").offsetHeight - 20;

    document.getElementById("map").style.height = map_height + "px";

    // Reset Canvas
    if (canvas)
    {                
        canvas.setSize(window.innerWidth, map_height);

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);
    }
}

function updatePageCoords()
{
    topLeftPageCoord = map.pointCoordinate(dragControlCoordinates);
    bottomRightPageCoord = map.pointCoordinate(scaleControlCoordinates);
}

function updateFromPageCoords()
{
    dragControlCoordinates = map.coordinatePoint(topLeftPageCoord);
    scaleControlCoordinates = map.coordinatePoint(bottomRightPageCoord);
    resetAtlas();
    updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
}

function checkAtlasOverflowOnAdd(topLeftPoint, bottomRightPoint)
{   
    var map_extent = map.getExtent();
    var map_bottom_right_point = map.locationPoint(map_extent[1]);

    var right_overflow = bottomRightPoint.x > map_bottom_right_point.x;
    var bottom_overflow = bottomRightPoint.y > map_bottom_right_point.y;
                    
    if (right_overflow || bottom_overflow)
    {              
        var dragControlLocation = map.pointLocation(dragControlCoordinates);
        var scaleControlLocation = map.pointLocation(scaleControlCoordinates);

        if (right_overflow && bottom_overflow)
        {
            var pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
            var pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
            map.panBy(pan_delta_x, pan_delta_y);
        } else if (right_overflow) {
            var pan_delta = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
            map.panBy(pan_delta, 0);
        } else if (bottom_overflow) {
            var pan_delta = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
            map.panBy(0, pan_delta);
        }
                                    
        dragControlCoordinates = map.locationPoint(dragControlLocation);
        scaleControlCoordinates = map.locationPoint(scaleControlLocation);

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        resetAtlas();
    }
}

/*
function checkAtlasOverflowOnDrag(topLeftPoint, bottomRightPoint)
{       
    var map_extent = map.getExtent();
    var map_top_left_point = map.locationPoint(map_extent[0]);
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
    
        var dragControlLocation = map.pointLocation(dragControlCoordinates);
        var scaleControlLocation = map.pointLocation(scaleControlCoordinates);
        
        if (left_overflow && top_overflow) {
            pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
            pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
        } else if (left_overflow && bottom_overflow) {
            pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
            pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
        } else if (left_overflow) {
            // Number of pixels to pan
            pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
        } else if (top_overflow) {
            pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
        } else if (right_overflow && bottom_overflow) {
            pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
            pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
        } else if (right_overflow && top_overflow) {
            pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
            pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
        } else if (right_overflow) {
            pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
        } else if (bottom_overflow) {
            pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
        }
        
        if (((topLeftPoint.x - 3) + pan_delta_x) < map_top_left_point.x) {
            pan_delta_x = map_top_left_point.x - (topLeftPoint.x - 3);
        }
        
        if (((topLeftPoint.y - controlRadius) + pan_delta_y) < map_top_left_point.y) {
            pan_delta_y = map_top_left_point.y - (topLeftPoint.x - controlRadius);
        }
        
        map.panBy(pan_delta_x, pan_delta_y);
                            
        dragControlCoordinates = map.locationPoint(dragControlLocation);
        scaleControlCoordinates = map.locationPoint(scaleControlLocation);

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        resetAtlas();
    }
}
*/

function checkAtlasOverflowOnDrag(topLeftPoint, bottomRightPoint)
{   
    var map_extent = map.getExtent();
    var map_top_left_point = map.locationPoint(map_extent[0]);
    var map_bottom_right_point = map.locationPoint(map_extent[1]);

    // Create 4 Boolean values for overflow tests
    var left_overflow = topLeftPoint.x < map_top_left_point.x;
    var top_overflow = topLeftPoint.y < map_top_left_point.y;
    var right_overflow = bottomRightPoint.x > map_bottom_right_point.x;
    var bottom_overflow = bottomRightPoint.y > map_bottom_right_point.y;
                    
    if (left_overflow || top_overflow || right_overflow || bottom_overflow)
    {                  
        var dragControlLocation = map.pointLocation(dragControlCoordinates);
        var scaleControlLocation = map.pointLocation(scaleControlCoordinates);

        var ui_width = scaleControlCoordinates.x - dragControlCoordinates.x;
        var ui_height = scaleControlCoordinates.y - dragControlCoordinates.y;
        var map_width = map_bottom_right_point.x - map_top_left_point.x;
        var map_height = map_bottom_right_point.y - map_top_left_point.y;

        if (((ui_width > map_width) || (ui_height > map_height)) && (top_overflow || left_overflow))
        {
            if (left_overflow && top_overflow) {
                var pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
                var pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (left_overflow) {
                // Number of pixels to pan
                var pan_delta = map_top_left_point.x - topLeftPoint.x + 3;
                map.panBy(pan_delta,0);
            } else if (top_overflow) {
                var pan_delta = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(0, pan_delta);
            }
        } else {
            if (right_overflow && bottom_overflow)
            {
                var pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
                var pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (right_overflow && top_overflow) {
                var pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
                var pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (left_overflow && top_overflow) {
                var pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
                var pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (left_overflow && bottom_overflow) {
                var pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
                var pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (right_overflow) {
                var pan_delta = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
                map.panBy(pan_delta, 0);
            } else if (bottom_overflow) {
                var pan_delta = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
                map.panBy(0, pan_delta);
            } else if (left_overflow) {
                // Number of pixels to pan
                var pan_delta = map_top_left_point.x - topLeftPoint.x + 3;
                map.panBy(pan_delta,0);
            } else if (top_overflow) {
                var pan_delta = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(0, pan_delta);
            }
        }
                            
        dragControlCoordinates = map.locationPoint(dragControlLocation);
        scaleControlCoordinates = map.locationPoint(scaleControlLocation);

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        resetAtlas();
    }
}

function checkAtlasOverflow(topLeftPoint, bottomRightPoint, resize)
{   
    var map_extent = map.getExtent();
    var map_top_left_point = map.locationPoint(map_extent[0]);
    var map_bottom_right_point = map.locationPoint(map_extent[1]);

    // Create 4 Boolean values for overflow tests
    var left_overflow = topLeftPoint.x < map_top_left_point.x;
    var top_overflow = topLeftPoint.y < map_top_left_point.y;
    var right_overflow = bottomRightPoint.x > map_bottom_right_point.x;
    var bottom_overflow = bottomRightPoint.y > map_bottom_right_point.y;
                    
    if (left_overflow || top_overflow || right_overflow || bottom_overflow)
    { 
        if (resize === true)
        {                        
            var center_point = map.locationPoint(map.getCenter());

            dragControlCoordinates.x = center_point.x - .5 * page_dimensions.width;
            dragControlCoordinates.y = center_point.y - .5 * page_dimensions.height;

            scaleControlCoordinates = {x: dragControlCoordinates.x + page_dimensions.width,
                                       y: dragControlCoordinates.y + page_dimensions.height};

            changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

            resetAtlas();
        } else {                    
            var dragControlLocation = map.pointLocation(dragControlCoordinates);
            var scaleControlLocation = map.pointLocation(scaleControlCoordinates);

            var ui_width = scaleControlCoordinates.x - dragControlCoordinates.x;
            var ui_height = scaleControlCoordinates.y - dragControlCoordinates.y;
            var map_width = map_bottom_right_point.x - map_top_left_point.x;
            var map_height = map_bottom_right_point.y - map_top_left_point.y;


            if (right_overflow && bottom_overflow)
            {
                var pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
                var pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (right_overflow && top_overflow) {
                var pan_delta_x = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
                var pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (left_overflow && top_overflow) {
                var pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
                var pan_delta_y = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (left_overflow && bottom_overflow) {
                var pan_delta_x = map_top_left_point.x - topLeftPoint.x + 3;
                var pan_delta_y = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
                map.panBy(pan_delta_x, pan_delta_y);
            } else if (right_overflow) {
                var pan_delta = map_bottom_right_point.x - bottomRightPoint.x - controlRadius;
                map.panBy(pan_delta, 0);
            } else if (bottom_overflow) {
                var pan_delta = map_bottom_right_point.y - bottomRightPoint.y - controlRadius;
                map.panBy(0, pan_delta);
            } else if (left_overflow) {
                // Number of pixels to pan
                var pan_delta = map_top_left_point.x - topLeftPoint.x + 3;
                map.panBy(pan_delta,0);
            } else if (top_overflow) {
                var pan_delta = map_top_left_point.y - topLeftPoint.y + controlRadius;
                map.panBy(0, pan_delta);
            }
                                
            dragControlCoordinates = map.locationPoint(dragControlLocation);
            scaleControlCoordinates = map.locationPoint(scaleControlLocation);

            changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

            resetAtlas();
        }
    }
}

function resetAtlas()
{
    changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

    updateAtlasBounds();

    dragControl.attr({
        x: dragControlCoordinates.x,
        y: dragControlCoordinates.y
    });

    scaleControl.attr({
        x: scaleControlCoordinates.x,
        y: scaleControlCoordinates.y
    });


    rect.attr({
        x: dragControlCoordinates.x,
        y: dragControlCoordinates.y,
        width: scaleControlCoordinates.x - dragControlCoordinates.x,
        height: scaleControlCoordinates.y - dragControlCoordinates.y
    });

    resetAtlasAttributes();
}

function changeOrientation(orientation) {
    if (document.getElementById("orientation").value === orientation)
    {
        return;
    }

    changeOrientationButtonStyle(orientation);

    document.getElementById("orientation").value = orientation;

    if (page_aspect_ratio > 1)
    {
        var new_page_height = (scaleControlCoordinates.x - dragControlCoordinates.x)/num_columns;
        page_aspect_ratio = paper_orientations[orientation];

        var new_page_width = page_aspect_ratio * new_page_height;
    } else {
        var new_page_width = (scaleControlCoordinates.y - dragControlCoordinates.y)/num_rows;
        page_aspect_ratio = paper_orientations[orientation];

        var new_page_height = new_page_width/page_aspect_ratio; 
    }

    atlas_aspect_ratio = (num_columns/num_rows) * page_aspect_ratio;

    scaleControlCoordinates.x = dragControlCoordinates.x + num_columns * new_page_width;
    scaleControlCoordinates.y = dragControlCoordinates.y + num_rows * new_page_height;

    updatePageCoords();

    scaleControl.attr({
        x: scaleControlCoordinates.x,
        y: scaleControlCoordinates.y
    });

    changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

    resetAtlasAttributes();
                
    rect.remove();
    updateAtlasBounds();
    drawAtlas();

    checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates);
    //setTimeout(function() { checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates); }, 50);
    updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
}

function changeOrientationButtonStyle(orientation)
{
    /* probably not necessary */
    if (document.getElementById("orientation").value === orientation)
    {
        return;
    }

    if (orientation === "portrait")
    {
        document.getElementById("portrait_button").setAttribute("class", "radio_portrait_selected");
        document.getElementById("landscape_button").setAttribute("class", "radio_landscape");
    } else if (orientation === "landscape") {
        document.getElementById("portrait_button").setAttribute("class", "radio_portrait");
        document.getElementById("landscape_button").setAttribute("class", "radio_landscape_selected");
    }
}

function resetAtlasAttributes()
{
    if (num_rows > 1 && num_columns > 1)
    {
        horizontal_remove.show();
        vertical_remove.show();   
    } else if (num_columns > 1 && num_rows === 1) {
        horizontal_remove.show();  
        vertical_remove.hide(); 
    } else if (num_rows > 1 && num_columns === 1) {
        horizontal_remove.hide();
        vertical_remove.show();
    } else {
        horizontal_remove.hide();
        vertical_remove.hide(); 
    }

    var pathString = drawPages(dragControlCoordinates, scaleControlCoordinates,num_rows,num_columns);

    lines.attr({
        path: pathString
    });
                    
    horizontal_add.attr({
        x: scaleControlCoordinates.x - .5 * page_button_width,
        y: dragControlCoordinates.y + .5 * (scaleControlCoordinates.y - dragControlCoordinates.y) - .5 * page_button_height
    });

    horizontal_remove.attr({
        x: scaleControlCoordinates.x - .5 * page_button_width - remove_column_button_width,
        y: dragControlCoordinates.y + .5 * (scaleControlCoordinates.y - dragControlCoordinates.y) - .5 * remove_column_button_height
    });

    vertical_add.attr({
        x: dragControlCoordinates.x + .5 * (scaleControlCoordinates.x - dragControlCoordinates.x) - .5 * page_button_width,
        y: scaleControlCoordinates.y - .5 * page_button_height
    });

    vertical_remove.attr({
        x: dragControlCoordinates.x + .5 * (scaleControlCoordinates.x - dragControlCoordinates.x) - .5 * remove_row_button_width - 1,
        y: scaleControlCoordinates.y - .5 * page_button_height - remove_row_button_height
    });
}

function updateAtlasBounds()
{
    page_dimensions.x = dragControlCoordinates.x;
    page_dimensions.y = dragControlCoordinates.y;

    page_dimensions.width = scaleControlCoordinates.x - dragControlCoordinates.x;
    page_dimensions.height = scaleControlCoordinates.y - dragControlCoordinates.y;

}

function drawPages(dragControlCoordinates, scaleControlCoordinates,num_rows,num_columns)
{
    var width = scaleControlCoordinates.x - dragControlCoordinates.x;
    var increment = width/num_columns;

    var pathString = "";
    for (var i = 0; i < num_columns - 1; i++) {
        // Creating string
        var verticalLineX = dragControlCoordinates.x + (i+1) * increment;

        pathString = [pathString, "M", verticalLineX, ",", dragControlCoordinates.y,
                     "L", verticalLineX, ",", scaleControlCoordinates.y].join("");
    }

    var height = scaleControlCoordinates.y - dragControlCoordinates.y;
    increment = height/num_rows;

    for (var i = 0; i < num_rows - 1; i++) {
        var horizontalLineY = dragControlCoordinates.y + (i+1) * increment;

        pathString = [pathString, "M", dragControlCoordinates.x, ",", horizontalLineY,
                    "L", scaleControlCoordinates.x, ",", horizontalLineY].join("");
    }

    return pathString;
}

function drawAtlas() {
    rect = canvas.rect(dragControlCoordinates.x, 
                       dragControlCoordinates.y,
                       scaleControlCoordinates.x - dragControlCoordinates.x,
                       scaleControlCoordinates.y - dragControlCoordinates.y);

    rect.attr("stroke", "#050505");
    rect.insertBefore(scaleControl);
    rect.insertBefore(dragControl);
    rect.insertBefore(horizontal_add);
}

function createCanvasFillPath(topLeftPoint, bottomRightPoint)
{   
    // ** Note: fill-rule attribute is not currently supported by Raphael.
    // By default, the fill-rule is nonzero. To achieve the correct fill,
    // we draw the outer path counter-clockwise to the clockwise inner path.

    var pathString = ["M0,0L0,", canvas.height, "L", canvas.width, ",", canvas.height, "L",
                     canvas.width, ",0L0,0M", topLeftPoint.x, ",", topLeftPoint.y, "L",
                     bottomRightPoint.x, ",", topLeftPoint.y,
                     "L", bottomRightPoint.x, ",", bottomRightPoint.y, "L",
                     topLeftPoint.x, ",", bottomRightPoint.y, "L", topLeftPoint.x,
                     topLeftPoint.y, "Z"].join("");

    return pathString;
}


function changeCanvasFillPath(topLeftPoint, bottomRightPoint)
{
    var pathString = createCanvasFillPath(topLeftPoint, bottomRightPoint)
    canvas_fill.attr({
        path: pathString
    });
}

function updatePageExtents(topLeftPoint, bottomRightPoint)
{  
    var width_increment = (bottomRightPoint.x - topLeftPoint.x)/num_columns;
    var height_increment = (bottomRightPoint.y -topLeftPoint.y)/num_rows;

    var rows = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,AA,AB,AC,AD,AE,AF,AG,AH,AI,AJ,AK,AL,AM,AN,AO,AP,AQ,AR,AS,AT,AU,AV,AW,AX,AY,AZ,BA,BB,BC,BD,BE,BF,BG,BH,BI,BJ,BK,BL,BM,BN,BO,BP,BQ,BR,BS,BT,BU,BV,BW,BX,BY,BZ".split(",");
    var cols = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,30,31,32,33,34,35,36,37,38,39".split(",");

    var pages = [];
    for (var i = 0; i < num_rows; i++) {
        for (var j = 0; j < num_columns; j++) {
            var topLeftLocation = map.pointLocation(new MM.Point(topLeftPoint.x + j*width_increment, topLeftPoint.y + i*height_increment));
            var bottomRightLocation = map.pointLocation(new MM.Point(topLeftPoint.x + (j+1)*width_increment, topLeftPoint.y + (i+1)*height_increment));
            var page = [topLeftLocation.lat, topLeftLocation.lon, bottomRightLocation.lat, bottomRightLocation.lon];
            pages.push({name: rows[i]+cols[j], value: page.join(",")});
        }
    }

    updateAtlasFormFields(pages);
}

function updateAtlasFormFields(pages)
{               
    var form_data_div = document.getElementById("form_data_div");

    if (form_data_div.hasChildNodes())
    {
        while(form_data_div.childNodes.length >= 1)
        {
            form_data_div.removeChild(form_data_div.firstChild);
        }
    }

    for (var i = 0; i < pages.length; i++)
    {
        var page_extent = document.createElement("input");
        page_extent.name = "pages[" + pages[i].name + "]";
        page_extent.type = "hidden";
        page_extent.value = pages[i].value;
        form_data_div.appendChild(page_extent);
    }
}

function initUI () {
    ////
    // Map
    ////
    var MM = com.modestmaps;
    var layers = [];

    if (mbtiles_data)
    {
        var providerURL = mbtiles_data["provider"],
            provider = new MM.TemplatedMapProvider(providerURL);
    } else {
        var providerURL = document.forms["compose_print"].elements["provider"].value,
            provider = new MM.TemplatedMapProvider(providerURL);
    }

    map_layer = new MM.Layer(provider);
    layers.push(map_layer);

    if(user_mbtiles)
    {
        var overlayURL = user_mbtiles[0]["url"],
            overlayProvider = new MM.TemplatedMapProvider(overlayURL);

        overlay_layer = new MM.Layer(overlayProvider);
        layers.push(overlay_layer);
    }
    

    setMapHeight();

    map = new MM.Map("map", layers, null,[new MM.DragHandler(), new MM.DoubleClickHandler()]);

    if (mbtiles_data)
    {
        var map_center_x = mbtiles_data["center_x"];
        var map_center_y = mbtiles_data["center_y"];
        var map_zoom = mbtiles_data["zoom"];

        var map_coordinates = new MM.Coordinate(map_center_y, map_center_x, map_zoom);

        var map_center = map.coordinateLocation(map_coordinates);
    } else {
        center = center.split(",");
        var map_center = new MM.Location(parseFloat(center[0]), parseFloat(center[1]));
        var map_zoom = zoom;
    }
                    
    map.setCenterZoom(map_center, map_zoom); // Set a default case, deal with zoom

    // Initialize value of page_zoom input

    document.getElementById("zoom-out").style.display = "inline";
    document.getElementById("zoom-in").style.display = "inline";

    document.getElementById("page_zoom").value = map_zoom;

    ////
    // UI
    ////

    // Atlas Information            
    num_rows = 1;
    num_columns = 1;

    //Initialize
    atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);
    //document.getElementById("radio_landscape").checked = true; // Initially landscape

    document.getElementById("paper_size").value = "letter";
    document.getElementById("orientation").value = "landscape";
                
    /////
    /// Set up the display objects
    /////

    canvas = Raphael("canvas");
                
    var center_point = map.locationPoint(map_center);

    var page_height = 150,
        canvasOriginX = (center_point.x - page_height * atlas_aspect_ratio) || 160,
        canvasOriginY = (center_point.y - .5 * page_height) || 160,
        controlRadius = 15;

    page_dimensions = {x: canvasOriginX, y: canvasOriginY, width: page_height*atlas_aspect_ratio, height: page_height};
                    
    // Initialize Coordinate Objects
    dragControlCoordinates = {x: canvasOriginX, y: canvasOriginY};
    scaleControlCoordinates = {x: page_height*atlas_aspect_ratio + canvasOriginX, y: page_height + canvasOriginY};

    updatePageCoords();
                
    horizontal_add = canvas.image(button_add_inactive,
                    canvasOriginX+page_height*atlas_aspect_ratio-.5*page_button_width,
                    canvasOriginY + .5 * page_height - .5 * page_button_height,
                    33,
                    46);
    horizontal_add.attr("cursor","pointer");
                
    horizontal_remove = canvas.image(button_remove_column_inactive,
                                     canvasOriginX + page_height*atlas_aspect_ratio - remove_column_button_width - .5 * page_button_width,
                                     canvasOriginY + .5 * page_height - .5 * remove_column_button_height,
                                     remove_column_button_width,
                                     remove_column_button_height);
    horizontal_remove.attr("cursor","pointer");
    horizontal_remove.hide();
                
    vertical_add = canvas.image(button_add_inactive,
                                 canvasOriginX + .5 * page_height * atlas_aspect_ratio - .5 * page_button_width,
                                 canvasOriginY + page_height - .5 * page_button_height,
                                 page_button_width,
                                 page_button_height);
    vertical_add.attr("cursor","pointer");
                
    vertical_remove = canvas.image(button_remove_row_inactive,
                                      canvasOriginX + .5 * page_height * atlas_aspect_ratio - .5 * remove_row_button_width - 1,
                                      canvasOriginY + page_height - .5 * page_button_height - remove_row_button_height,
                                      remove_row_button_width,
                                      remove_row_button_height);
    vertical_remove.attr("cursor","pointer");
    vertical_remove.hide();

    dragControl = canvas.image(button_drag_inactive,
                                dragControlCoordinates.x,
                                dragControlCoordinates.y,
                                46,
                                46);
    dragControl.attr("cursor","move");
    dragControl.translate(-3, -3);

    scaleControl = canvas.image(button_scale_inactive,
        scaleControlCoordinates.x,
        scaleControlCoordinates.y,
        46,
        46);
    scaleControl.attr("cursor","se-resize");
    scaleControl.translate(-23, -23);

    drawAtlas(scaleControl,dragControl,horizontal_add);

    // Filling the canvas outside
    var fill_path = createCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);
    canvas_fill = canvas.path(fill_path);
    canvas_fill.attr("fill", "#050505");
    canvas_fill.attr("opacity", .3);
    canvas_fill.insertBefore(rect);

    var pathString = drawPages(dragControlCoordinates, scaleControlCoordinates,num_rows,num_columns);

    lines = canvas.path(pathString);
    lines.attr("stroke", "#050505");
    lines.insertBefore(rect);

    updatePageExtents(dragControlCoordinates, scaleControlCoordinates);

    /////
    // Handle the highlighting of all of the atlas controls
    /////

    /* The next two variables are being used in the scale control drag handler */
    var changeHighlightImages = true;
    var mouseInsideScaleControl = false;
                
    function setControlHighlight()
    {
        dragControl.mouseover(function(e) {
            e.stopPropagation();
            this.attr("src", button_drag_active);     
        });

        dragControl.mouseout(function(e) {
            e.stopPropagation();
            this.attr("src", button_drag_inactive);
        });

        scaleControl.mouseover(function(e) {
            e.stopPropagation();

            mouseInsideScaleControl = true;

            if (changeHighlightImages) {
                scaleControl.attr("src", button_scale_active);
            }
        });

        scaleControl.mouseout(function(e) {
            e.stopPropagation();

            mouseInsideScaleControl = false;

            if (changeHighlightImages) {
                scaleControl.attr("src", button_scale_inactive);
            }
        });
                        
        horizontal_remove.mouseover(function(e) {
            e.stopPropagation();
            this.attr("src", button_remove_column_active);
        });

        horizontal_remove.mouseout(function(e) {
            e.stopPropagation();
            this.attr("src", button_remove_column_inactive);
        });

        horizontal_add.mouseover(function (e) {
            e.stopPropagation();
            this.attr("src", button_add_active);
        });

        horizontal_add.mouseout(function (e) {
            e.stopPropagation();
            this.attr("src", button_add_inactive);
        });

        vertical_add.mouseover(function(e) {
            e.stopPropagation();
            this.attr("src", button_add_active);
        });

        vertical_add.mouseout(function(e) {
            e.stopPropagation();
            this.attr("src", button_add_inactive);
        });

        vertical_remove.mouseover(function(e) {
            e.stopPropagation();
            this.attr("src", button_remove_row_active);
        });

        vertical_remove.mouseout(function(e) {
            e.stopPropagation();
            this.attr("src", button_remove_row_inactive);
        });
    }

    setControlHighlight();

    /////
    // Drag Control drag handler: move, start, end
    /////
    var initialX, initialY; // These are used by the dragControl handler and the scaleControl handler
                
    /**
     * panBy() is used both in the control dragging and whenever the map is
     * panned.
     */
    function panBy(dx, dy) {
        dragControlCoordinates.x = initialX + dx;
        dragControlCoordinates.y = initialY + dy;

        scaleControlCoordinates.x = dragControlCoordinates.x + page_dimensions.width;
        scaleControlCoordinates.y = dragControlCoordinates.y + page_dimensions.height;

        updatePageCoords();
        updateAtlasBounds();

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        dragControl.attr({
            x: dragControlCoordinates.x,
            y: dragControlCoordinates.y
        });

        scaleControl.attr({
            x: scaleControlCoordinates.x,
            y: scaleControlCoordinates.y
        });

        rect.attr({
            x: dragControlCoordinates.x,
            y: dragControlCoordinates.y
        });

        resetAtlasAttributes();
    }

    map.addCallback("panned", function(m, delta) {
        // FIXME this is hacky, and shouldn't be necessary
        initialX = dragControlCoordinates.x;
        initialY = dragControlCoordinates.y;
        panBy(delta[0], delta[1]);
    });

    dragControl.drag(

        function (dx,dy,x,y,e) {
            e.stopPropagation();
            panBy(dx, dy);
        },

        function(x,y,e) {                                
            e.stopPropagation();

            this.attr("cursor", "grabbing");
            this.attr("cursor", "-moz-grabbing");
            this.attr("cursor", "-webkit-grabbing");

            var canvasElement = document.getElementById("canvas");
            canvasElement.style.cursor = "grabbing";
            canvasElement.style.cursor = "-moz-grabbing";
            canvasElement.style.cursor = "-webkit-grabbing";

            initialX = dragControl.attr("x");
            initialY = dragControl.attr("y");
        },

        function () {
            this.attr("cursor", "move");

            document.getElementById("canvas").style.cursor = "default";                                               
            //checkAtlasOverflowOnDrag(dragControlCoordinates, scaleControlCoordinates);
            setTimeout(function() { checkAtlasOverflowOnDrag(dragControlCoordinates, scaleControlCoordinates); }, 50);
            updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
        }
    );

    /////
    // scaleControl drag handler: move, start, end
    /////
                            
    scaleControl.drag(

        function(dx, dy, mouseX, mouseY, e) {
            //e.stoppropagation?

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
                x: page_dimensions.x + new_width,
                y: page_dimensions.y + new_height
            });

            scaleControlCoordinates.x = page_dimensions.x + new_width;
            scaleControlCoordinates.y = page_dimensions.y + new_height;

            changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

            updatePageCoords();
            updateAtlasBounds();
                                                   
            rect.remove();
            drawAtlas(scaleControl,dragControl,horizontal_add);

            resetAtlasAttributes();
        },

        function(mouseX,mouseY,e) {
            e.stopPropagation();

            changeHighlightImages = false;

            this.attr("cursor", "grabbing");
            this.attr("cursor", "-moz-grabbing");
            this.attr("cursor", "-webkit-grabbing");

            var canvasElement = document.getElementById("canvas");
            canvasElement.style.cursor = "grabbing";
            canvasElement.style.cursor = "-moz-grabbing";
            canvasElement.style.cursor = "-webkit-grabbing";
                            
            initialX = scaleControlCoordinates.x;
            initialY = scaleControlCoordinates.y;
        },

        function(e) {
            //turnOnControlHighlight();
            changeHighlightImages = true;
            if (!mouseInsideScaleControl) {
                scaleControl.attr("src", button_scale_inactive);
            }

            //scaleControlCoordinates.x = this.attr("x");
            //scaleControlCoordinates.y = this.attr("y");
            this.attr("cursor", "se-resize");
            document.getElementById("canvas").style.cursor = "default";

            //checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates);
            setTimeout(function() { checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates); }, 50);
            updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
        }
    );

    var addHorizontalPage = function() {
        num_columns++;

        if (num_rows * num_columns > 1)
        {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGES";
        } else {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGE";
        }

        atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);

        page_dimensions.width = page_dimensions.width * (num_columns/(num_columns - 1))

        scaleControlCoordinates.x = page_dimensions.x + page_dimensions.width;
        scaleControl.attr({
            x: scaleControlCoordinates.x
        });

        updatePageCoords();

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        //checkAtlasOverflowOnAdd(dragControlCoordinates, scaleControlCoordinates);
        setTimeout(function() { checkAtlasOverflowOnAdd(dragControlCoordinates, scaleControlCoordinates); }, 50);
                      
        rect.attr({
            // This is really atlas dimensions at this point.
            width:  page_dimensions.width
        });

        resetAtlasAttributes();
        updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
    }

    addHorizontalPage();

    var removeHorizontalPage = function() {
        if (num_columns === 1)
        {
            return;
        }

        num_columns--;

        if (num_rows * num_columns > 1)
        {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGES";
        } else {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGE";
        }

        atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);

        page_dimensions.width = page_dimensions.width * (num_columns/(num_columns + 1))

        scaleControlCoordinates.x = page_dimensions.x + page_dimensions.width;
        scaleControl.attr({
            x: scaleControlCoordinates.x
        });

        updatePageCoords();

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates); //Needed?
                        
        rect.attr({
            width:  page_dimensions.width
        });

        resetAtlasAttributes();
        updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
    }

    var addVerticalPage = function() {
        num_rows++;

        if (num_rows * num_columns > 1)
        {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGES";
        } else {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGE";
        }

        atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);

        page_dimensions.height = page_dimensions.height * (num_rows/(num_rows - 1))

        scaleControlCoordinates.y = page_dimensions.y + page_dimensions.height;
        scaleControl.attr({
            y: scaleControlCoordinates.y
        });

        updatePageCoords();

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        //checkAtlasOverflowOnAdd(dragControlCoordinates, scaleControlCoordinates);
        setTimeout(function() { checkAtlasOverflowOnAdd(dragControlCoordinates, scaleControlCoordinates); }, 50);
                      
        rect.attr({
            height:  page_dimensions.height
        });

        resetAtlasAttributes();
        updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
    }

    var removeVerticalPage = function() {
        if (num_rows === 1)
        {
            return;
        }

        num_rows--;

        if (num_rows * num_columns > 1)
        {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGES";
        } else {
            document.getElementById("page_count").innerHTML = "<b>" + num_rows * num_columns + "</b>";
            document.getElementById("page_plural").innerHTML = "PAGE";
        }

        atlas_aspect_ratio = page_aspect_ratio*(num_columns/num_rows);

        page_dimensions.height = page_dimensions.height * (num_rows/(num_rows + 1))


        scaleControlCoordinates.y = page_dimensions.y + page_dimensions.height;
        scaleControl.attr({
            y: scaleControlCoordinates.y
        });

        updatePageCoords();

        changeCanvasFillPath(dragControlCoordinates, scaleControlCoordinates);

        checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates); // Needed?
                        
        rect.attr({
            height:  page_dimensions.height
        });

        resetAtlasAttributes();
        updatePageExtents(dragControlCoordinates, scaleControlCoordinates);
    }

    ////
    //  Set Click Handlers for row and columm buttons
    ////            
    horizontal_add.click(function (e) {
        e.stopPropagation();
        addHorizontalPage();
        this.attr("src", button_add_inactive);
    });

    horizontal_remove.click(function(e) {
        e.stopPropagation()
        removeHorizontalPage();
        this.attr("src", button_remove_column_inactive);
    });

    vertical_add.click(function(e) {
        e.stopPropagation();
        addVerticalPage();
        this.attr("src", button_add_inactive);
    });

    vertical_remove.click(function(e) {
        e.stopPropagation();
        removeVerticalPage();
        this.attr("src", button_remove_row_inactive);
    });

    // Map Callbacks
    map.addCallback("zoomed", function(m) {
        document.getElementById("page_zoom").value = map.getZoom();
        updateFromPageCoords();
    });

    
    // check atlas overflow on map resize (but not for now)
    map.addCallback("resized", function(m) {
        checkAtlasOverflow(dragControlCoordinates, scaleControlCoordinates,true);
    });
    
                
    var zoom_in = document.getElementById("zoom-in"),
        zoom_out = document.getElementById("zoom-out"),
        zoom_return = document.getElementById("zoom-return");
                
    var zoom_in_button = document.getElementById("zoom-in-button");
    zoom_in.onmouseover = function() { zoom_in_button.src = zoom_in_active; };
    zoom_in.onmouseout = function() { zoom_in_button.src = zoom_in_inactive; };

    zoom_in.onclick = function() {
        map.zoomIn();
        map.dispatchCallback("zoomed");
        return false;
    };

    var zoom_out_button = document.getElementById("zoom-out-button");
    zoom_out.onmouseover = function() { zoom_out_button.src = zoom_out_active; };
    zoom_out.onmouseout = function() { zoom_out_button.src = zoom_out_inactive; };

    zoom_out.onclick = function() {
        map.zoomOut();
        map.dispatchCallback("zoomed");
        return false;
    };

    var zoom_return_button = document.getElementById("zoom-return-button");
    zoom_return.onmouseover = function() { zoom_return_button.src = zoom_return_active; };
    zoom_return.onmouseout = function() { zoom_return_button.src = zoom_return_inactive; };
    zoom_return_button.onclick = function() {
        var northWest = map.coordinateLocation(topLeftPageCoord),
            southEast = map.coordinateLocation(bottomRightPageCoord);
        map.setExtent([northWest, southEast]);
        map.dispatchCallback("zoomed");
        return false;
    };

    // Window Callbacks
    window.onresize = setMapHeight;
}
