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
        <script type="text/javascript" src="{$base_dir}/js/print.js"></script>
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
{if $print.composed}
<body onload="loadMaps()">
{else}
<body>
{/if}
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        {if $print.composed}
            <script>
                var base_url = {$base_dir|json_encode};
                var selected_page = {$print.selected_page|json_encode} || null;
                
                {if $print.selected_page}
                    var overview_provider = {$print.selected_page.provider|json_encode};
                    var main_provider = {$print.selected_page.provider|json_encode};
                    
                    var north_page = {$pages[0].north|json_encode};
                    var west_page = {$pages[0].west|json_encode};
                    var south_page = {$pages[0].south|json_encode};
                    var east_page = {$pages[0].east|json_encode};
                {else}
                    var overview_provider = {$pages[0].provider|json_encode};
                    var main_provider = {$pages[0].provider|json_encode};
                    var atlas_pages = {$pages|@json_encode};
                {/if}
                
                var north = {$print.north|json_encode},
                    west = {$print.west|json_encode},
                    south = {$print.south|json_encode},
                    east = {$print.east|json_encode};
                    zoom = {$pages[0].zoom|json_encode};
                
                var zoom_in_active = base_url + '/img/button-zoom-in-on.png',
                    zoom_in_inactive = base_url + '/img/button-zoom-in-off.png',
                    zoom_out_active = base_url + '/img/button-zoom-out-on.png',
                    zoom_out_inactive = base_url + '/img/button-zoom-out-off.png';
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
                
                <h3 class="title">{if $print.title}{$print.title|escape:'html'}{else}Untitled{/if}{if $print.private} <span class="private">private</span>{/if}</h3>
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
            
            <div id="atlas-export-column">
                <h4>Export Data</h4>
                <ul>
                    <li><a href="{$base_dir}/activity.php?print={$print.id|escape}&amp;type=json">GeoJSON</a></li>
                    <li><a href="{$base_dir}/activity.php?print={$print.id|escape}&amp;type=csv">Plain Text (CSV)</a></li>
                    
                    {if $constants.OGR2OGR_PATH && $constants.ZIP_PATH}
                        <li><a href="{$base_dir}/activity.php?print={$print.id|escape}&amp;type=shp">Shapefile</a></li>
                    {/if}
                </ul>
            </div>
            
            <div id="atlas-activity-stream">
                <h3>Activity</h3>
                
                <ul>
                    {foreach from=$activity item="event"}
                        {if $event.type == "print"}
                            <li>
                                {assign var="print" value=$event.print}

                                {if $print.user_name}
                                    <a href="{$base_dir}/atlases.php?user={$print.user_id|escape}">{$print.user_name|escape}</a>
                                {else}
                                    Someone anonymous
                                {/if}
                                made this atlas of <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename|escape}</a>
                                <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}" class="date">- {$print.age|nice_relativetime|escape}</a>
                                <div class="details">
                                    {if $print.page_count == 1}
                                        One page
                                    {elseif $print.page_count == 2}
                                        Two pages
                                    {else}
                                        {$print.page_count} pages
                                    {/if}
                                    
                                    {foreach from=$providers item="provider"}
                                        {if $pages.0.provider == $provider.0}
                                            + {$provider.1|lower|escape}
                                        {/if}
                                    {/foreach}
                                    + {$print.orientation|escape}
                                    + {$print.layout|escape}
                                </div>
                                {*
                                <a>George</a> made this atlas of <a>Dubai</a> <a class="date">- 3 weeks ago</a>
                                <br>
                                <span class="details">18 pages + satellite and labels + portrait + map/notes layout, 2-up + <a>imported MBTiles</a></span>
                                *}
                            </li>

                        {elseif $event.type == "scan"}
                            <li>
                                {assign var="scan" value=$event.scan}
                                
                                {if $scan.user_name}
                                    <a href="{$base_dir}/snapshots.php?user={$scan.user_id|escape}">{$scan.user_name|escape}</a>
                                {else}
                                    Someone anonymous
                                {/if}
                                uploaded a <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}">snapshot of page {$scan.print_page_number|escape}</a>
                                {if $scan.has_geotiff == 'yes'}
                                    (<a href="{$scan.base_url|escape}/walking-paper-{$scan.id|escape}.tif">GeoTIFF</a>)
                                {/if}
                                <a href="{$base_dir}/snapshots.php?month={"Y-m"|@date:$scan.created}" class="date">- {$scan.age|nice_relativetime|escape}</a>
                                <br>
                                
                                <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}"><img src="{$scan.base_url|escape}/preview.jpg"></a>

                                {*
                                <a>George</a> uploaded a <a>snapshot</a> of <a>page B2</a> <a class="date">- 3 weeks ago</a>
                                <br>
                                <img>
                                *}
                            </li>

                        {elseif $event.type == "notes"}
                            <li>
                                {assign var="notes" value=$event.notes}
                                {assign var="last_note" value=$notes|@end}
                                {assign var="scan" value=$last_note.scan}
                                {assign var="count" value=$notes|@count}
                                
                                {if $last_note.user_name}
                                    <a href="{$base_dir}/snapshots.php?user={$last_note.user_id|escape}">{$last_note.user_name|escape}</a>
                                {else}
                                    Someone anonymous
                                {/if}
                                
                                {if $count == 1}
                                    added <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}">a note about page {$scan.print_page_number|escape}</a>
                                {else}
                                    added <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}">{$count} notes about page {$scan.print_page_number|escape}</a>
                                {/if}
                                <a class="date">- {$last_note.age|nice_relativetime|escape}</a>
                                
                                <ol>
                                    {foreach from=$notes item="note"}
                                        <li>{$note.note|escape}</li>
                                    {/foreach}
                                </ol>
                            </li>

                        {elseif $event.type == "note"}
                            <li>
                                {assign var="note" value=$event.note}
                                {assign var="scan" value=$note.scan}

                                {if $note.user_name}
                                    <a href="{$base_dir}/snapshots.php?user={$note.user_id|escape}">{$note.user_name|escape}</a>
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
                            </li>
                        {/if}
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
                    You don't need to keep this window open; you can <a href="{$base_dir}/atlas.php?id={$print.id|escape}">bookmark 
                    this page</a> and come back later.
                </p>
                <p>
                    Since this atlas is <span class="private">private</span>, you probably should <a href="{$base_dir}/atlas.php?id={$print.id|escape}">bookmark it</a>.
                </p>
            </div>
        {/if}        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
