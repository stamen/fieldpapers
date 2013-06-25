var canvas,
    print_extent,
    atlas_page_objects = [],
    page_label_objects = [],
    page_label_background_objects = [],
    text_locs = [],
    page_extent,
    text_offset = 6,
    text_dimensions = null;
                                    
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
    if (page_data.length == 1)
    {
        var page_limit = page_data.length;
    } else {
        var page_limit = page_data.length - 1;
    }
    
    for (var i=0; i < page_limit; i++) 
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
                                
        page_label_objects[i].attr({
            x: new_loc.x,
            y: new_loc.y
        });
        
        text_dimensions = page_label_objects[i].getBBox();
        
        page_label_background_objects[i].attr({
            x: new_loc.x - text_dimensions.width + text_offset,
            y: new_loc.y - .5 * text_dimensions.height
        });
    }
}

function loadMaps() {
        var map = null,
            MM = com.modestmaps;
        
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
        
        var hashStr = (location.hash.charAt(0) == '#') ? location.hash.substr(1) : location.hash;
        var incomingCoords = MM.Hash.prototype.parseHash(hashStr) || null;
        
        if (overview_provider.search(','))
        {
            var overview_providers = overview_provider.split(',');
            for (var i = 0; i < overview_providers.length; i++) {
                // Create layers
                overview_map_layers.push(new MM.Layer(new MM.Template(overview_providers[i])));
            }
        } else {
            overview_map_layers.push(new MM.Layer(new MM.Template(overview_provider)));
        }
        
        if (main_provider.search(','))
        {
            var main_providers = main_provider.split(',');
            for (var i = 0; i < main_providers.length; i++) {
                main_map_layers.push(new MM.Layer(new MM.Template(main_providers[i])));
            }
        } else {
            main_map_layers.push(new MM.Layer(new MM.Template(main_provider)));
        }
        
        // Map 1
        var overview_map = new MM.Map("atlas-overview-map", overview_map_layers, null, []);
        
        // Map 2
        var map = new MM.Map("atlas-index-map", main_map_layers, null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
                                
        var extents = [new MM.Location(north, west), new MM.Location(south, east)];
        
        map.setExtent(extents);
        overview_map.setCenterZoom(map.getCenter(),5);
        var hash = new MM.Hash(map); 
        
        if(incomingCoords){
            map.setCenterZoom(incomingCoords.center,incomingCoords.zoom);
        }

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
        
        var map_extent = map.getExtent();
        var map_top_left_point = map.locationPoint(map_extent.northWest());
        var map_bottom_right_point = map.locationPoint(map_extent.southEast());
        
        var atlas_x_proportion = (ne_point.x - nw_point.x)/(map_bottom_right_point.x - map_top_left_point.x);
        var atlas_y_proportion = (ne_point.y - se_point.y)/(map_bottom_right_point.y - map_bottom_right_point.y);
        
        var start_zoom = map.getZoom();
        
        var max_zoom = null;
        
        if (Math.max(atlas_x_proportion, atlas_y_proportion) > .8)
        {
            max_zoom = start_zoom;
        } else if (Math.max(atlas_x_proportion, atlas_y_proportion) > .55) {
            max_zoom = start_zoom + 1;
        } else {
            max_zoom = start_zoom + 2;
        }
                                
        ////
        // Draw the page grid for the main atlas page
        ////
        
        if (atlas_pages.length == 1)
        {
            var page_limit = atlas_pages.length
        } else {
            var page_limit = atlas_pages.length - 1;
        }
        
        for (var i = 0; i < page_limit; i++)
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
            
            ////
            // Draw text labels
            ////
            
            var text_coordinates = {x: nw_page_point.x + .5 * page_width,
                                    y: nw_page_point.y + .5 * page_height};
            
            text_locs.push(map.pointLocation(text_coordinates));
                                                                
            var page_label = canvas.text(text_coordinates.x, 
                                         text_coordinates.y, 
                                         atlas_pages[i].page_number);
                                         
            page_label.attr({"font-size": 18, 
                             "font-family": 'Arial',
                             "font-weight": 'bold',
                             "cursor": "pointer"});
            
            var text_dimensions = page_label.getBBox();
            
            var page_label_background = canvas.rect(text_coordinates.x - text_dimensions.width + text_offset,
                                                    text_coordinates.y - .5 * text_dimensions.height,
                                                    text_dimensions.width*2 - 2 * text_offset,
                                                    text_dimensions.height);
            
            page_label_background.toBack();
            
            page_label_background.attr({fill: "#FFF",
                                        "stroke-width": 0
                                      });
                                        
            atlas_page_objects.push(atlas_page_extent);
            page_label_objects.push(page_label);
            page_label_background_objects.push(page_label_background);
            
            atlas_page_objects[i].click(function(nw, ne, se, sw) {
                return function ()
                {
                    if (map.getZoom() <= start_zoom) {
                        easey.slow(map, {location: new MM.Location(.5*(nw.lat+sw.lat), .5*(nw.lon+ne.lon)),
                                         zoom: max_zoom
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
                                         zoom: max_zoom
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
                        "fill-opacity": .2
                    });
                    
                    page_label_objects[index].attr({
                        fill: "#FFF"
                    });
                    
                    page_label_background_objects[index].attr({
                        fill: "#09F"
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
                        "fill-opacity": .2
                    });
                    
                    page_label_background_objects[index].attr({
                        fill: "#09F"
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
        
        if (selected_page)
        {                           
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
        }
    }
