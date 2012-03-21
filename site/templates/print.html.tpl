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
        
        {/literal}
    </style>
</head>
<body onload="loadMaps()">
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        {if $print.composed}
            <script>
            {literal}
                var canvas,
                    print_extent,
                    page_extent;
                    
                function redrawExtent(map, MM, north, south, east, west)
                {
                    var new_nw_point = map.locationPoint(new MM.Location(north, west));
                    var new_ne_point = map.locationPoint(new MM.Location(north, east));
                    var new_se_point = map.locationPoint(new MM.Location(south, east));
                    var new_sw_point = map.locationPoint(new MM.Location(south, west));
                    
                    var new_width = new_ne_point.x - new_nw_point.x;
                    var new_height = new_se_point.y - new_ne_point.y;
                           
                    print_extent.remove();
                            
                    print_extent = canvas.rect(new_nw_point.x, new_nw_point.y, new_width, new_height);
                    print_extent.attr({
                        stroke: "#050505",
                        "stroke-width": 4
                    });
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
                        map.setCenterZoom(map.getCenter(), zoom - 2);
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
                        
                        map.addCallback('panned', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                        });
                        
                        map.addCallback('zoomed', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                        });
                        
                        map.addCallback('centered', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
                        });
                        
                        map.addCallback('extentset', function(m) {
                            redrawExtent(m, MM, north, south, east, west);
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
                
                <h3 class="title">[Atlas Title]</h3>
                <p class="count">
                    {if $pages|@count == 1}
                        One page
                    {elseif $pages|@count == 2}
                        Two pages
                    {else}
                        {$pages|@count} pages
                    {/if}
                </p>

                <p class="borrow"><strike>Borrow this Atlas</strike></p>
                <p class="download"><a href="{$print.pdf_url}">Download PDF <!--<span class="size">17MB</span>--></a></p>
            </div>
            
            <div id="atlas-export-column">
                <h4>Export Geodata</h4>
                <ul>
                    <li><a>GeoJSON</a> 24KB</li>
                    <li><a>GeoTIFF</a> 24KB</li>
                </ul>
            </div>
            
            <div id="atlas-activity-stream">
                <h3>Activity</h3>
                
                <ul>
                    <li>
                        <a>George</a> made this atlas of <a>Dubai</a> <a class="date">- 3 weeks ago</a>
                        <br>
                        <span class="details">18 pages + satellite and labels + portrait + map/notes layout, 2-up + <a>imported MBTiles</a></span>
                    </li>
                    <li>
                        <a>George</a> uploaded a <a>snapshot</a> of <a>page B2</a> <a class="date">- 3 weeks ago</a>
                        <br>
                        <img>
                    </li>
                    <li>
                        <a>George</a> added 3 notes about <a>page B2</a> <a class="date">- 2 weeks ago</a>
                        <ol>
                            <li>This is where I found a</li>
                            <li>Fire hydrant looks busted</li>
                            <li>Best eggs in the city</li>
                        </ol>
                    </li>
                    <li>
                        Someone anonymous added a note to <a>page B2</a> <a class="date">- 4 days ago</a>
                        <ol>
                            <li>This is where I found a</li>
                            <li>Fire hydrant looks busted</li>
                            <li>Best eggs in the city</li>
                        </ol>
                    </li>
                    <li>
                        <a>Roger Ramjet</a> borrowed this atlas, and made <a>My Summer Holiday in Dubai</a> (14 pages) <a class="date">- yesterday</a>
                    </li>
                </ul>
            </div>
            
            <hr>
            
            <div class="overview_print" id="overview_map"></div>
            <h1>
                Untitled
            </h1>
            <p>
                <b>
                    {if $print.place_woeid}
                        <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>,
                    {/if}
                    {if $print.country_woeid}
                        <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a>
                    {/if}
                </b><br>
                
                Created by <a href='{$base_dir}/atlases.php?user={$print.user_id}'>{$user.name}</a>, 
                <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a>
                <br>
                {$pages|@count}
                {if $pages|@count == 1}
                    page
                {else}
                    pages
                {/if}
            </p>
            <ul><li><a href="{$print.pdf_url}"><b>Download PDF</b></a></li></ul>
            
            <div class="print" id="map">
                <div id="canvas"></div>
            </div>
            
            <div class="clearfloat"></div>
            
            <h2>Scans</h2>
        
            <ul>
                {foreach from=$scans item="scan"}
                    <li>
                        <a href="scan.php?id={$scan.id|escape}">Scan {$scan.id|escape}</a>, {$scan.age|nice_relativetime|escape}
                    </li>
                {/foreach}
            </ul>
            
            <h2>Notes</h2>
        
            <ul>
                 {foreach from=$notes item="note"}
                     <li>
                        <i>{$note.note|escape}</i> on <a href="scan.php?id={$note.scan_id|escape}">scan {$note.scan_id|escape}</a>
                    </li>
                {/foreach}
            </ul>
            
            {if $print.selected_page}
                <h2>Page {$print.selected_page.page_number}</h2>
        
                <div class="atlasPage"> 
                    <img src="{$print.selected_page.preview_url}" alt="printed page" name="atlasPage" id="atlasPage">
                    <br>
                    <span class="atlasPageNumber">{$print.selected_page.page_number}</span>
                </div>
            
            {else}
                <h2 class="pageCount">{$pages|@count} page{if $pages|@count > 1}s{/if}</h2>
                
                {foreach from=$pages item="page"}
                    <div class="atlasPage"> 
                        <a href="{$base_dir}/print.php?id={$print.id}/{$page.page_number}">
                            <img src="{$page.preview_url}" alt="printed page" name="atlasPage" id="atlasPage">
                        </a>
                        <br>
                        <span class="atlasPageNumber">{$page.page_number}</span>
                    </div>
                {/foreach}
            {/if}
        
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
