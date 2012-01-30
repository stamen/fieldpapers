<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Home - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/css/style_makeset.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/js/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/js/modestmaps.extent-selector.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
    
    <script>
        {literal}
                var map, selector, pages = [],
            rows = 0, columns = 0, aspect_ratio = 7.5/9.5,
            page_container,
            pages_offset,
            unscaled_page_width = 75,
            unscaled_page_height = 95,
            page_zoom = 11,
            mask;

        // TODO: generate these in PHP from constants in lib/data.php
        var MMPPT = 0.352777778,
            INPPT = 0.013888889,
            PTPIN = 1/INPPT,
            PTPMM = 1/MMPPT;
        var paper_sizes = {};
        // landscape
        paper_sizes["A3:landscape"] = {width: 420 * PTPMM, height: 297 * PTPMM};
        paper_sizes["A4:landscape"] = {width: 297 * PTPMM, height: 210 * PTPMM};
        paper_sizes["letter:landscape"] = {width: 11 * PTPIN, height: 8.5 * PTPIN};
        paper_sizes["tabloid:landscape"] = {width: 17 * PTPIN, height: 11 * PTPIN};
        // portrait
        paper_sizes["A3:portrait"] = {height: 420 * PTPMM, width: 297 * PTPMM};
        paper_sizes["A4:portrait"] = {height: 297 * PTPMM, width: 210 * PTPMM};
        paper_sizes["letter:portrait"] = {height: 11 * PTPIN, width: 8.5 * PTPIN};
        paper_sizes["tabloid:portrait"] = {height: 17 * PTPIN, width: 11 * PTPIN};

        function setPageSize(width, height) {
            unscaled_page_width = width / 10;
            unscaled_page_height = height / 10;
            aspect_ratio = width / height;
            
            setAspectRatio(width, height);
            updatePages(selector.extent);
        }

        function updatePages(extent) {
            var northwest = extent.northWest();
            var southeast = extent.southEast();

            var top_left = map.locationPoint(northwest),
                bottom_right = map.locationPoint(southeast),
                coord_top_left = map.pointCoordinate(top_left).zoomTo(page_zoom),
                coord_bottom_right = map.pointCoordinate(bottom_right).zoomTo(page_zoom);

            var width = bottom_right.x - top_left.x;
            var height = bottom_right.y - top_left.y;

            // console.log('width: ' + width, 'height: ' + height);

            var page_scale = Math.pow(2, map.getZoom() - page_zoom);
            // console.log('page_scale: ' + page_scale);

            var page_width = unscaled_page_width * page_scale;
            var page_height = unscaled_page_height * page_scale;

            var columns = Math.ceil(width/page_width);
            var rows = Math.ceil(height/page_height);
            var num_pages = columns * rows;

            var container_width = columns * page_width; //quantized width
            var container_height = rows * page_height;

            page_container.style.width = container_width + 'px';
            page_container.style.height = container_height + 'px';
            // pages_offset = new MM.Point(-(container_width - width) / 2, -(container_height - height) / 2);
            pages_offset = new MM.Point(0, 0);
            page_container.style.left = pages_offset.x + 'px';
            page_container.style.top = pages_offset.y + 'px';

            // if we need more pages, create them
            if (pages.length < num_pages) {
                while (pages.length < num_pages) {
                    var page = document.createElement("div");
                    page.appendChild(document.createElement("span")).setAttribute("class","page-label");
                    page.setAttribute("class","page");
                    page.style.position = "absolute";
                    page_container.appendChild(page);
                    pages.push(page);
                }
            // or, if there are too many, remove them
            } else if (pages.length> num_pages) {
                while (pages.length > num_pages) {
                    var page = pages.pop();
                    page_container.removeChild(page);
                }
            }
            
            // get the per-page offset in tile coordinate space
            var coord_top_left_offset = map.pointCoordinate(new MM.Point(top_left.x + page_width, top_left.y + page_height)).zoomTo(page_zoom);
            // these are the x and y step values, also in tile coordinate space
            var col_step = coord_top_left_offset.column - coord_top_left.column;
            var row_step = coord_top_left_offset.row - coord_top_left.row;

            var x = 0,
                y = 0,
                row = coord_top_left.row,
                column = coord_top_left.column;

            var size = "tiny";
            if (page_width > 200) {
                size = "xlarge";
            } else if (page_width > 100) {
                size = "large";
            } else if (page_width > 50) {
                size = "medium";
            } else if (page_width > 20) {
                size = "small";
            }
            
            //var preview_points = []; //Leaves the possibility to cycle through the preview pages

            for (var i=0; i < num_pages; i++) {
                var page = pages[i];
                var coord_tl = new MM.Coordinate(row, column, page_zoom),
                    coord_br = new MM.Coordinate(row + row_step, column + col_step, page_zoom),
                    point_tl = map.coordinatePoint(coord_tl),
                    point_br = map.coordinatePoint(coord_br);
                    
                //preview_points.push([map.pointLocation(point_tl),map.pointLocation(point_br)]);
                
                page.style.left = (point_tl.x - top_left.x) + 'px';
                page.style.top = (point_tl.y - top_left.y) + 'px';
                page.style.width = page_width + 'px';
                page.style.height = page_height + 'px';
                
                page.coord_top_left = coord_tl;
                page.coord_bottom_right = coord_br;

                // update label text
                if (size === "tiny") {
                    page.firstChild.innerText = "";
                } else {
                    page.firstChild.innerText = i + 1;
                }
                page.setAttribute("data-size", size);

                // only update labels if the grid is big enough

                if (x == columns - 1) {
                    row += row_step;
                    column = coord_top_left.column; 
                    x = 0;      
                    y += 1;
                } else {
                    column += col_step;
                    x += 1;
                }
            }

            if (mask) {
                updateMask(extent);
            }

            document.getElementById("page-count").innerText = num_pages;
            
            updatePreviewMap();
        }

        function updateMask(extent) {
            // clear
            mask.width = mask.width;
            var ctx = mask.getContext("2d");
            ctx.fillStyle = "rgba(0,0,0,.3)";
            ctx.fillRect(0, 0, mask.width, mask.height);
            var top_left = map.coordinatePoint(pages[0].coord_top_left),
                bottom_right = map.coordinatePoint(pages[pages.length - 1].coord_bottom_right);
            ctx.clearRect(
                top_left.x + pages_offset.x,
                top_left.y + pages_offset.y,
                Math.ceil(bottom_right.x - top_left.x + 1),
                Math.ceil(bottom_right.y - top_left.y + 1)
            );
        }

        function onExtentChange(extent) {
            updatePages(extent);
        }
        
        function updatePreviewMap() {
            var loc_nw = map.coordinateLocation(pages[0].coord_top_left);
            var loc_se = map.coordinateLocation(pages[0].coord_bottom_right);
            
            // var index = parseInt(pages.length * .5);
            
            preview_map.setExtent([loc_nw,loc_se], true); 
        }
        
        function setAspectRatio(width, height) {
            var factor = .3;
            
            var preview_width = factor * width;
            var preview_height = factor * height;
            
            preview_map.parent.style.width = preview_width + "px";
            preview_map.parent.style.height = preview_height + "px";
        }
        
        function changePage() {
            // Stub if needed
        }

        /**
         * Form submission stuff
         */
        var form, submit_button, extent_inputs = [];

        function onSubmitClick(e) {
            console.log(pages);
            submit_button.className = "working";
            submit_button.disabled = true;
            console.log("updating inputs...");
            
            $("#page_zoom").val(page_zoom);
            
            updateExtentInputs(function(len) {
                console.log("done updating inputs!");
                submit_button.disabled = false;                
                form.submit();
            });
            return MM.cancelEvent(e);
        }

        function updateExtentInputs(callback) {
            if (updateExtentInputs.interval) {
                clearInterval(updateExtentInputs.interval);
            }
            var len = pages.length,
                index = 0;
            if (extent_inputs.length > len) {
                while (extent_inputs.length > len) {
                    form.removeChild(extent_inputs.pop());
                }
            }
            function updateInput() {
                if (index == len) {
                    // Appending paper size to the form
                    /*
                    var orient = $("#paper-orient"),
                        size = $("#paper-size"),
                        width = paper_sizes[[size.val(), orient.val()].join(":")].width,
                        height = paper_sizes[[size.val(), orient.val()].join(":")].height;
                
                    var paper_info = form.appendChild(input);
                    paper_info.setAttribute("type", "hidden");
                    paper_info.name = "paper_info";
                    paper_info.value = [width,height,orient.val(),size.val()];
                    */
                    
                    clearInterval(updateExtentInputs.interval);
                    if (callback) {
                        callback.call(null, len);
                    }
                } else {
                
                    var page = pages[index],
                        northwest = map.coordinateLocation(page.coord_top_left),
                        southeast = map.coordinateLocation(page.coord_bottom_right);
    
                    var input = extent_inputs[index];
                    if (!input) {
                        input = form.appendChild(document.createElement("input"));
                        input.setAttribute("type", "hidden");
                        input.name = "pages[" + index + "]";
                        extent_inputs[index] = input;
                    }
                    //input.value = [northwest.lat, southeast.lat, southeast.lon, northwest.lon].join(",");
                    input.value = [northwest.lat, northwest.lon, southeast.lat, southeast.lon].join(",");
                    
                    // TODO: append input to form
                    console.log('updateInput: ', index);
                    
                    index++;
                }
            }
            return updateExtentInputs.interval = setInterval(updateInput, 10);
        }

        function initMap() {
            // the map
            // TODO: add provider <select> input
            var provider = new MM.TemplatedMapProvider("http://tiles.teczno.com/bing-lite/{Z}/{X}/{Y}.jpg");
            // var provider = new MM.TemplatedMapProvider("http://{S}tile.cloudmade.com/1a1b06b230af4efdbb989ea99e9841af/999/256/{Z}/{X}/{Y}.png", ["a.", "b.", "c.", ""]);
            map = new MM.Map("map", provider);

            // the initial extent
            var extent = new MM.MapExtent(37.837, -122.522, 37.691, -122.350);
            map.setExtent(extent);
            
            // Initialize the preview map
            preview_map = new MM.Map("preview_map", provider);
            preview_map.setExtent(extent);

            // the selector is a map "layer"
            selector = new MM.ExtentSelector(document.getElementById("extent"));
            selector.allowMoveCenter = false;
            map.addLayer(selector);

            // initialize page_container
            page_container = document.getElementById("pages");

            try {
                mask = document.getElementById("mask");
                if (mask) {
                    mask.width = map.dimensions.x * 2;
                    mask.height = map.dimensions.y * 2;
                    map.addCallback("resized", function() {
                        mask.width = map.dimensions.x * 2;
                        mask.height = map.dimensions.y * 2;
                        updateMask();
                    });
                    map.addCallback("panned", function() {
                        updateMask();
                    });
                    mask.style.setProperty("pointer-events", "none");
                    mask.style.setProperty("position", "absolute");
                    map.parent.appendChild(mask);
                }
            } catch (e) {
                console.warn("no canvas support = no mask");
            }

            // update the northwest and south east labels when the extent
            // changes
            var extentField = document.getElementById("extent-string");
            selector.addCallback("extentset", function(o, ext) {
                // and update the extent string field for good measure
                extentField.value = ext;
                onExtentChange(ext);
            });
            selector.setExtent(extent);

            function updateExtent() {
                updatePages(selector.extent);
            }
            map.addCallback("zoomed", updateExtent);
            map.addCallback("extentset", updateExtent);

            form = document.getElementById("submit");
            submit_button = form.elements[form.elements.length - 1];
            MM.addEvent(submit_button, "click", onSubmitClick);

            $("#page-zoom").slider({
                min: 8,
                max: 14,
                step: 1,
                value: page_zoom
            }).bind("slide", function(e, ui) {
                page_zoom = ui.value;
                updatePages(selector.extent);
            });

            MM.addEvent(document.getElementById("show-extent"), "click", function(e) {
                map.setExtent(selector.extent, false);
                return MM.cancelEvent(e);
            });

            MM.addEvent(document.getElementById("fit-to-view"), "click", function(e) {
                selector.setExtent(map.getExtent());
                return MM.cancelEvent(e);
            });

            var orient = $("#paper-orient"),
                size = $("#paper-size");

            function updatePageSize() {
                var size_name = [size.val(), orient.val()].join(":"),
                    actual_size = paper_sizes[size_name];
                console.log("page size:", size_name, [actual_size.width, actual_size.height]);
                setPageSize(actual_size.width, actual_size.height);
            }

            size.bind("change", updatePageSize);
            orient.bind("change", updatePageSize);

            updatePageSize();
        }
        {/literal}
    </script>
    <style type="text/css">
        {literal}
        @import url(http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/ui-lightness/jquery-ui.css);
        {/literal}
    </style>
    
</head>
<body onload="initMap()">
        {include file="header.htmlf.tpl"}
            
        {include file="navigation.htmlf.tpl"}
        
        <h1>Field Papers: Atlas Page Selector</h1>

        <form id="submit" method="post" action="{$base_dir}/compose-print.php">
            <div id="controls">
                <p>
                    <input type="hidden" name="action" value="compose">
                    <input type="hidden" id="page_zoom" name="page_zoom">

                    <label for="paper-size">Paper size: <select id="paper-size" name="paper_size">
                        <option value="A3" selected>A3</option>
                        <option value="A4">A4</option>
                        <option value="letter">Letter</option>
                        <option value="tabloid">Tabloid</option>
                    </select></label>

                    <label for="paper-orient">orientation: <select id="paper-orient" name="orientation">
                        <option value="landscape" selected>landscape</option>
                        <option value="portrait">portrait</option>
                    </select></label>

                    Page zoom: <span id="page-zoom"></span>
                    <strong id="page-count"></strong> page(s)
                </p>
            </div>
    
            <div id="container">
                <div id="preview">
                    <div class="padding">
                        <h2 style="text-align: center">Field Papers Preview</h2>
                        <div id="preview_map"></div>
                    </div>
                </div>
                <div id="map">
                    <div id="extent" class="map-extent">
                        <div id="pages"></div>
                        <span id="nw-label" class="label label-northwest"></span>
                        <span id="se-label" class="label label-southeast"></span>
                    </div>
    
                    <canvas id="mask"></canvas>
                </div>
            </div>

            <div id="finish">
                <p>Extent (N,W,S,E): <input id="extent-string" type="text" size="40"> <button id="show-extent">zoom to extent</button> <button id="fit-to-view">fit to current view</button></p>
                <p><input type="submit" value="submit"></p>
            </div>
        </form>
    </body>
</html>