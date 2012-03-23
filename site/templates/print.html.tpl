<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Atlas - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">    
    {if $print && !$print.composed}
        <meta http-equiv="refresh" content="5">
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/raphael-min.js"></script>
        <script type="text/javascript" src="{$base_dir}/js/easey.js"></script>
        <script type="text/javascript" src="{$base_dir}/js/easey.handlers.js"></script>
    {/if}
    <style type="text/css">
        {literal}
        #canvas {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 3;
        }
        
        #atlas-overview-map-holder
        {
            height: 138px;
            border: 1px solid black;
            position: relative;
            
            background-color: #ddd;
        }
            
            #atlas-overview-map-holder h2
            {
                font-size: 24px;
                position: absolute;
                padding: 7px 12px;
                margin: 0;
                bottom: 0;
                
                color: white;
                background-color: black;
            }
        
            #atlas-overview-map-holder #atlas-overview-map
            {
                width: 100%;
                height: 100%;
            }
        
        #atlas-index-map-holder
        {
            height: 738px;
            border: 1px solid black;
            position: relative;
            margin-top: -1px;
            
            background-color: #ddd;
        }
            
            #atlas-index-map-holder #atlas-index-map
            {
                width: 100%;
                height: 100%;
            }
                
            #atlas-index-map-holder #atlas-index-map-canvas
            {
                width: 100%;
                height: 100%;
                position: absolute;
                z-index: 3;
            }
            
            #atlas-index-map-holder .title,
            #atlas-index-map-holder .count,
            #atlas-index-map-holder .borrow,
            #atlas-index-map-holder .download
            {
                z-index: 4;
                position: absolute;
                width: auto;
                height: 18px;

                color: white;
                background-color: black;
                margin: 0;
                padding: 7px 12px;

                font-size: 18px;
                line-height: 18px;
                font-weight: bold;
            }
            
            #atlas-index-map-holder a
            {
                color: white;
            }
            
            #atlas-index-map-holder .title
            {
                top: 0;
                left: 0;
            }
            
            #atlas-index-map-holder .count
            {
                top: 32px;
                left: 0;
            }
            
            #atlas-index-map-holder .borrow
            {
                bottom: 32px;
                right: 0;
            }
            
            #atlas-index-map-holder .download
            {
                bottom: 0;
                right: 0;
            }
            
            #atlas-index-map-holder .download .size
            {
                font-weight: normal;
            }
            
        #atlas-export-column
        {
            float: right;
            width: 25%;
        }
        
        #atlas-export-column a,
        #atlas-activity-stream a
        {
            color: #23a5fb;
        }

        #atlas-export-column,
        #atlas-activity-stream
        {
            margin-top: 14px;
        }
        
        #atlas-export-column li,
        #atlas-activity-stream a.date,
        #atlas-activity-stream ul li .details,
        #atlas-activity-stream ul li .details a
        {
            color: #999;
        }
        
        #atlas-export-column,
        #atlas-activity-stream
        {
            font-size: 18px;
            line-height: 30px;
        }
        
        #atlas-activity-stream h3
        {
            font-size: 24px;
        }
        
        #atlas-export-column h4,
        #atlas-activity-stream h3
        {
            margin-bottom: .5em;
        }
        
        #atlas-export-column>ul,
        #atlas-activity-stream>ul
        {
            margin-top: .5em;
        }
        
        #atlas-activity-stream img
        {
            border: 1px solid #ddd;
        }
        
        #zoom-container {
            width: 46px;
            height: 92px;
            position: absolute;
            padding: 8px 0px 0px 20px;
            z-index: 3;
            top: 66px;
            left: 0;
        }
        
        #zoom-in, #zoom-out {
            cursor: pointer;
        }
        
        {/literal}
    </style>
</head>
<body onload="loadMaps()">
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        {if $print.composed}
            <script>
            var atlas_pages = {$pages_json};
            var base_url = {$base_dir|json_encode};
            
            var zoom_in_active = base_url + '/img/button-zoom-in-on.png';
            var zoom_in_inactive = base_url + '/img/button-zoom-in-off.png';
            
            var zoom_out_active = base_url + '/img/button-zoom-out-on.png';
            var zoom_out_inactive = base_url + '/img/button-zoom-out-off.png';
            {literal}
                var canvas,
                    print_extent,
                    atlas_page_objects = [],
                    page_label_objects = [],
                    page_label_background_objects = [],
                    text_locs = [],
                    page_extent;
                                                        
                function redrawExtent(map, MM, north, south, east, west)
                {
                    var new_nw_point = map.locationPoint(new MM.Location(north, west));
                    var new_ne_point = map.locationPoint(new MM.Location(north, east));
                    var new_se_point = map.locationPoint(new MM.Location(south, east));
                    var new_sw_point = map.locationPoint(new MM.Location(south, west));
                    
                    var new_width = new_ne_point.x - new_nw_point.x;
                    var new_height = new_se_point.y - new_ne_point.y;
                    
                    print_extent.attr({
                        x: new_nw_point.x,
                        y: new_nw_point.y,
                        width: new_width,
                        height: new_height
                    });
                }
                
                function redrawPageExtents(map, MM, page_data, pages)
                {
                    for (var i=0; i < page_data.length - 1; i++) 
                    {
                        var north = page_data[i].north;
                        var west = page_data[i].west;
                        var south = page_data[i].south;
                        var east = page_data[i].east;
                            
                        var new_nw_point = map.locationPoint(new MM.Location(north, west));
                        var new_ne_point = map.locationPoint(new MM.Location(north, east));
                        var new_se_point = map.locationPoint(new MM.Location(south, east));
                        var new_sw_point = map.locationPoint(new MM.Location(south, west));
                        
                        var new_width = new_ne_point.x - new_nw_point.x;
                        var new_height = new_se_point.y - new_ne_point.y;
                    
                        pages[i].attr({
                            x: new_nw_point.x,
                            y: new_nw_point.y,
                            width: new_width,
                            height: new_height
                        });
                    }         
                }
                
                function redrawPageExtent(map, MM, north, south, east, west)
                {
                    var new_nw_point = map.locationPoint(new MM.Location(north, west));
                    var new_ne_point = map.locationPoint(new MM.Location(north, east));
                    var new_se_point = map.locationPoint(new MM.Location(south, east));
                    var new_sw_point = map.locationPoint(new MM.Location(south, west));
                    
                    var new_width = new_ne_point.x - new_nw_point.x;
                    var new_height = new_se_point.y - new_ne_point.y;
                           
                    page_extent.remove();
                            
                    page_extent = canvas.rect(new_nw_point.x, new_nw_point.y, new_width, new_height);
                    page_extent.attr({
                        stroke: "#FFF",
                        "stroke-width": 4
                    });
                }
                
                function changeTextPosition(map, MM, atlas_pages, page_label_background_objects, page_label_objects)
                {                    
                    for (var i=0; i < page_label_objects.length; i++)
                    {
                        var new_loc = map.locationPoint(text_locs[i]);
                        
                        page_label_background_objects[i].attr({
                            x: new_loc.x - 20,
                            y: new_loc.y - 10
                        });
                        
                        page_label_objects[i].attr({
                            x: new_loc.x,
                            y: new_loc.y
                        });
                    }
                }
                
                function loadMaps() {
                        var map = null,
                        MM = com.modestmaps;
                        
                        {/literal}
            
                        {if $print.selected_page}
                            var overview_provider = '{$print.selected_page.provider}';
                            var main_provider = '{$print.selected_page.provider}';
                        {else}
                            var overview_provider = '{$pages[0].provider}';
                            var main_provider = '{$pages[0].provider}';
                        {/if}
            
                        {literal}
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
                            
                            document.getElementById('zoom-out').style.display = 'inline';
                            document.getElementById('zoom-in').style.display = 'inline';
                      
                            var overview_map_layers = [];
                            var main_map_layers = [];
                            
                            if (overview_provider.search(','))
                            {
                                var overview_providers = overview_provider.split(',');
                                for (var i = 0; i < overview_providers.length; i++) {
                                    // Create layers
                                    overview_map_layers.push(new MM.Layer(new MM.TemplatedMapProvider(overview_providers[i])));
                                }
                            } else {
                                overview_map_layers.push(new MM.Layer(new MM.TemplatedMapProvider(overview_provider)));
                            }
                            
                            if (main_provider.search(','))
                            {
                                var main_providers = main_provider.split(',');
                                for (var i = 0; i < main_providers.length; i++) {
                                    main_map_layers.push(new MM.Layer(new MM.TemplatedMapProvider(main_providers[i])));
                                }
                            } else {
                                main_map_layers.push(new MM.Layer(new MM.TemplatedMapProvider(main_provider)));
                            }
                        
                        // Map 1
                        var overview_map = new MM.Map("atlas-overview-map", overview_map_layers, null, []);
                        
                        
                        // Map 2
                        var map = new MM.Map("atlas-index-map", main_map_layers, null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
                        
                        var north = '{/literal}{$print.north}{literal}';
                        var west = '{/literal}{$print.west}{literal}';
                        var south = '{/literal}{$print.south}{literal}';
                        var east = '{/literal}{$print.east}{literal}';
                        
                        var zoom = '{/literal}{$pages[0].zoom}{literal}';
                        
                        var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                        
                        map.setExtent(extents);
                        overview_map.setCenterZoom(map.getCenter(),5);
                        
                        ////
                        // Draw the Extent of the Atlas
                        ////
                        
                        canvas = Raphael("atlas-index-map-canvas"); // Use this for both the print and page extents
                        
                        var nw_point = map.locationPoint(new MM.Location(north, west));
                        var ne_point = map.locationPoint(new MM.Location(north, east));
                        var se_point = map.locationPoint(new MM.Location(south, east));
                        var sw_point = map.locationPoint(new MM.Location(south, west));
                        
                        var width = ne_point.x - nw_point.x;
                        var height = se_point.y - ne_point.y;
                        
                        print_extent = canvas.rect(nw_point.x, nw_point.y, width, height);
                        print_extent.attr({
                            stroke: "#050505",
                            "stroke-width": 4
                        });
                                                
                        ////
                        // Draw the page grid for the main atlas page
                        ////
                        
                        for (var i = 0; i < atlas_pages.length-1; i++)
                        {
                            var north_page = atlas_pages[i].north;
                            var west_page = atlas_pages[i].west;
                            var south_page = atlas_pages[i].south;
                            var east_page = atlas_pages[i].east;
                            
                            var nw_loc = new MM.Location(north_page, west_page);
                            var ne_loc = new MM.Location(north_page, east_page);
                            var se_loc = new MM.Location(south_page, east_page);
                            var sw_loc = new MM.Location(south_page, west_page);
                            
                            var nw_page_point = map.locationPoint(nw_loc);
                            var ne_page_point = map.locationPoint(ne_loc);
                            var se_page_point = map.locationPoint(se_loc);
                            var sw_page_point = map.locationPoint(sw_loc);
                            
                            var page_width = ne_page_point.x - nw_page_point.x;
                            var page_height = se_page_point.y - ne_page_point.y;
                            
                            atlas_page_extent = canvas.rect(nw_page_point.x, nw_page_point.y, page_width, page_height);
                            atlas_page_extent.attr({
                                cursor: "pointer",
                                stroke: "#050505",
                                "stroke-width": 1,
                                fill: "#FFF",
                                "fill-opacity": .3
                            });
                            
                            // draw text
                            
                            var text_coordinates = {x: nw_page_point.x + .5 * page_width,
                                                    y: nw_page_point.y + .5 * page_height};
                            
                            text_locs.push(map.pointLocation(text_coordinates));
                            
                            // TODO: Account for text width
                            var page_label_background = canvas.rect(text_coordinates.x - 20,
                                                                    text_coordinates.y - 10,
                                                                    40,
                                                                    20);
                            
                            page_label_background.attr({fill: "#FFF",
                                                        "stroke-width": 0
                                                      });
                                                    
                            var page_label = canvas.text(text_coordinates.x, 
                                                         text_coordinates.y, 
                                                         atlas_pages[i].page_number);
                                                         
                            page_label.attr({"font-size": 18, 
                                             "font-family": 'Arial',
                                             "font-weight": 'bold',
                                             "cursor": "pointer"});
                            
                            //var page_label_set = canvas.set();
                            //page_label_set.push(atlas_page_objects, page_label_objects);
                                                        
                            atlas_page_objects.push(atlas_page_extent);
                            page_label_objects.push(page_label);
                            page_label_background_objects.push(page_label_background);
                            
                            var start_zoom = map.getZoom();
                            
                            //var set_zoom = start_zoom + 1;
                            
                            atlas_page_objects[i].click(function(nw, ne, se, sw) {
                                return function ()
                                {
                                    //map.setExtent([nw, ne, se, sw]);
                                    if (map.getZoom() <= start_zoom) {
                                        easey.slow(map, {location: new MM.Location(.5*(nw.lat+sw.lat), .5*(nw.lon+ne.lon)),
                                                         zoom: start_zoom + 2
                                                         }
                                                  );
                                    } else {
                                        easey.slow(map, {location: new MM.Location(.5*(nw.lat+sw.lat), .5*(nw.lon+ne.lon))
                                                         }
                                                   );
                                    }
                                }
                            }(nw_loc, ne_loc, se_loc, sw_loc));
                            
                            page_label_objects[i].click(function(nw, ne, se, sw) {
                                return function ()
                                {
                                    if (map.getZoom() <= start_zoom) {
                                        easey.slow(map, {location: new MM.Location(.5*(nw.lat+sw.lat), .5*(nw.lon+ne.lon)),
                                                         zoom: start_zoom + 2
                                                         }
                                                  );
                                    } else {
                                        easey.slow(map, {location: new MM.Location(.5*(nw.lat+sw.lat), .5*(nw.lon+ne.lon))
                                                         }
                                                   );
                                    }
                                }
                            }(nw_loc, ne_loc, se_loc, sw_loc));
                        }
                        
                        for (var i=0; i < atlas_page_objects.length; i++)
                        {                             
                            atlas_page_objects[i].mouseover(function(index) {
                                return function() {
                                    this.attr({
                                        fill: "#09F",
                                        "fill-opacity": 1
                                    });
                                    
                                    page_label_objects[index].attr({
                                        fill: "#FFF"
                                    });
                                    
                                    page_label_background_objects[index].attr({
                                        fill: ""
                                    });
                                }
                            }(i));
                            
                            page_label_objects[i].mouseover(function(index) {
                                return function() {
                                    this.attr({
                                        fill: "#FFF"
                                    });
                                    
                                    atlas_page_objects[index].attr({
                                        fill: "#09F",
                                        "fill-opacity": 1
                                    });
                                    
                                    page_label_background_objects[index].attr({
                                        fill: ""
                                    });
                                }
                            }(i));
                            
                            atlas_page_objects[i].mouseout(function(index) {
                                return function() {
                                    this.attr({
                                        fill: "#FFF",
                                        "fill-opacity": .3
                                    });
                                    
                                    page_label_objects[index].attr({
                                        fill: "#000"
                                    });
                                    
                                    page_label_background_objects[index].attr({
                                        fill: "#FFF"
                                    });
                                }
                            }(i));
                        }
                        
                        map.addCallback('panned', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                            redrawPageExtents(map, MM, atlas_pages, atlas_page_objects);
                            changeTextPosition(map, MM, atlas_pages, page_label_background_objects, page_label_objects);
                        });
                        
                        map.addCallback('zoomed', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                            redrawPageExtents(map, MM, atlas_pages, atlas_page_objects);
                            changeTextPosition(map, MM, atlas_pages, page_label_background_objects, page_label_objects);
                        });
                        
                        map.addCallback('centered', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                            redrawPageExtents(map, MM, atlas_pages, atlas_page_objects);
                            changeTextPosition(map, MM, atlas_pages, page_label_background_objects, page_label_objects);
                        });
                        
                        map.addCallback('extentset', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                            redrawPageExtents(map, MM, atlas_pages, atlas_page_objects);
                            changeTextPosition(map, MM, atlas_pages, page_label_background_objects, page_label_objects);
                        });
                                                
                        ////
                        // Draw individual pages
                        ////
                        
                        {/literal}{if $print.selected_page}{literal}
                            var north_page = '{/literal}{$pages[0].north}{literal}';
                            var west_page = '{/literal}{$pages[0].west}{literal}';
                            var south_page = '{/literal}{$pages[0].south}{literal}';
                            var east_page = '{/literal}{$pages[0].east}{literal}';
                            
                            var nw_page_point = map.locationPoint(new MM.Location(north_page, west_page));
                            var ne_page_point = map.locationPoint(new MM.Location(north_page, east_page));
                            var se_page_point = map.locationPoint(new MM.Location(south_page, east_page));
                            var sw_page_point = map.locationPoint(new MM.Location(south_page, west_page));
                            
                            var page_width = ne_page_point.x - nw_page_point.x;
                            var page_height = se_page_point.y - ne_page_point.y;
                        
                            page_extent = canvas.rect(nw_page_point.x, nw_page_point.y, page_width, page_height);
                            page_extent.attr({
                                stroke: "#FFF",
                                "stroke-width": 4
                            });
                            
                            
                            map.addCallback('panned', function(m) {
                                redrawPageExtent(m, MM, north_page, south_page, east_page, west_page);
                            });
                            
                            map.addCallback('zoomed', function(m) {
                                redrawPageExtent(m, MM, north_page, south_page, east_page, west_page);
                            });
                            
                            map.addCallback('centered', function(m) {
                                redrawPageExtent(m, MM, north_page, south_page, east_page, west_page);
                            });
                            
                            map.addCallback('extentset', function(m) {
                                redrawPageExtent(m, MM, north_page, south_page, east_page, west_page);
                            });
                         {/literal}{/if}{literal}
                    }
                    {/literal}
            </script>
            
            <div id="atlas-overview-map-holder">
                <div id="atlas-overview-map"></div>
                <h2>
                    {if $print.place_woeid}{$print.place_name|nice_placename},{/if}
                    {if $print.country_woeid}{$print.country_name|nice_placename}{/if}
                </h2>
            </div>
            
            <div id="atlas-index-map-holder">
                <div id="atlas-index-map"><div id="atlas-index-map-canvas"></div></div>
                
                <h3 class="title">{if $print.title}{$print.title|escape}{else}Untitled{/if}</h3>
                <p class="count">
                    {if $pages|@count == 1}
                        One page
                    {elseif $pages|@count == 2}
                        Two pages
                    {else}
                        {$pages|@count} pages
                    {/if}
                </p>
                
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

                {* TODO: <p class="borrow">Borrow this Atlas</p> *}
                <p class="download"><a href="{$print.pdf_url}">Download PDF {* TODO: <span class="size">17MB</span> *}</a></p>
            </div>
            
            {* TODO: this
            <div id="atlas-export-column">
                <h4>Export Geodata</h4>
                <ul>
                    <li><a>GeoJSON</a> 24KB</li>
                    <li><a>GeoTIFF</a> 24KB</li>
                </ul>
            </div>
            *}
            
            <div id="atlas-activity-stream">
                <h3>Activity</h3>
                
                <ul>
                    {foreach from=$activity item="event"}
                        <li>
                            {if $event.type == "print"}
                                {assign var="print" value=$event.print}

                                {if $print.user_name}
                                    <a href="{$base_dir}/person.php?id={$print.user_id|escape}">{$print.user_name|escape}</a>
                                {else}
                                    Someone anonymous
                                {/if}
                                made this atlas of <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename|escape}</a>
                                <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}" class="date">- {$print.age|nice_relativetime|escape}</a>
                                <br>
                                <span class="details">[page count] + [style name] + {$print.orientation|escape} + {$print.layout|escape}</span>
        
                                {*
                                <a>George</a> made this atlas of <a>Dubai</a> <a class="date">- 3 weeks ago</a>
                                <br>
                                <span class="details">18 pages + satellite and labels + portrait + map/notes layout, 2-up + <a>imported MBTiles</a></span>
                                *}

                            {elseif $event.type == "scan"}
                                {assign var="scan" value=$event.scan}

                                {if $scan.user_name}
                                    <a href="{$base_dir}/person.php?id={$scan.user_id|escape}">{$scan.user_name|escape}</a>
                                {else}
                                    Someone anonymous
                                {/if}
                                uploaded a <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}">snapshot of page {$scan.print_page_number|escape}</a>
                                <a href="{$base_dir}/uploads.php?month={"Y-m"|@date:$scan.created}" class="date">- {$scan.age|nice_relativetime|escape}</a>
                                <br>
                                <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}"><img src="{$scan.base_url|escape}/preview.jpg"></a>

                                {*
                                <a>George</a> uploaded a <a>snapshot</a> of <a>page B2</a> <a class="date">- 3 weeks ago</a>
                                <br>
                                <img>
                                *}

                            {elseif $event.type == "note"}
                                {assign var="note" value=$event.note}
                                {assign var="scan" value=$note.scan}

                                {if $note.user_name}
                                    <a href="{$base_dir}/person.php?id={$note.user_id|escape}">{$note.user_name|escape}</a>
                                {else}
                                    Someone anonymous
                                {/if}
                                added <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}">a note about page {$scan.print_page_number|escape}</a>
                                <a class="date">- {$note.age|nice_relativetime|escape}</a>
                                <ol>
                                    <li>{$note.note|escape}</li>
                                </ol>

                                {*
                                <a>George</a> added 3 notes about <a>page B2</a> <a class="date">- 2 weeks ago</a>
                                <ol>
                                    <li>This is where I found a</li>
                                    <li>Fire hydrant looks busted</li>
                                    <li>Best eggs in the city</li>
                                </ol>

                                Someone anonymous added a note to <a>page B2</a> <a class="date">- 4 days ago</a>
                                <ol>
                                    <li>This is where I found a</li>
                                    <li>Fire hydrant looks busted</li>
                                    <li>Best eggs in the city</li>
                                </ol>
                                *}
                            {/if}
                        </li>
                    {/foreach}
                </ul>
            </div>
        {else}
            <div class="smallContainer">
                <p>Preparing your atlas... ({$print.progress*100|string_format:"%d"}% complete)</p>
                <div class="progressBarCase">
                    <div class="progressBar" style="width: {$print.progress*100}%;"></div>
                </div>
                <p>
                    This may take a while, generally a few minutes. <br><br>
                    You don't need to keep this window open; you can <a href="{$base_dir}/print.php?id={$print.id|escape}">bookmark 
                    this page</a> and come back later.
                </p>
            </div>
        {/if}        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>