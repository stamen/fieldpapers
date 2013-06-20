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
        #nearby-atlases {
            margin-top: 75px;
        }
        
        .atlasThumb-container {
            position: relative;
        }

        .atlasThumb-small {
            //width: 180px;
            height: 180px;
            background-position: center center;
            overflow: hidden;
        }

        h6.header {
            //postion: relative;
            //bottom: 0;
        }

        .atlasThumb-title {
            position: relative;
            bottom: 0;
        }

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
            #atlas-index-map-holder .borrow,
            #atlas-index-map-holder .download
            {
                position: relative;
                display: inline-block;
                zoom: 1;
                *display: inline;
                min-height: 18px;
                _height:18px;
                vertical-align: top;
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
            .map-buttons-br{
                position: absolute;
                bottom: 0px;
                right: 0px;
                height: auto;
            }
            .map-buttons-tl{
                position: absolute;
                top: 0;
                right: -1px;
                height: auto;
            }   
            .map-buttons-br form,
            .map-buttons-tl form{
                display:inline-block;
                zoom: 1;
                *display: inline;
            }
            
            .borrow input{
                background: black;
                border: none;
                color: #fff;
                font-size: 18px;
                text-decoration: underline;
                font-weight: bold;
                line-height: 19px;
                padding: 0;
                margin: 0;
                cursor: pointer;
            }
            .borrow input:hover{
                text-decoration:none;
            }
             #atlas-index-map-holder .borrow
            {
                bottom: 0;
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
		
		
#atlases-nearby { }
#atlases-nearby ul { margin-left: -30px;  }
#atlases-nearby li { margin:0; padding-right: 18px;  display: block; float: left; list-style: none; }
#atlases-nearby div {width:140px; height: 140px; background-image: url(http://fieldpapers.org/files/prints/lnpnk6cx/preview.jpg)}		
        
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
                {if $print.place_woeid || $print.country_woeid}
                <h2>
                    {if $print.place_woeid}{$print.place_name|nice_placename},{/if}
                    {if $print.country_woeid}{$print.country_name|nice_placename}{/if}
                </h2>
                {/if}
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
                {if $isosm}
                <div class="map-buttons-tl">
                    <form action="{$base_dir}/make-step3-info.php" accept-charset="utf-8" method="POST"> 
                        <p class="borrow"><input type="submit" value="Refresh"></p>
                        <input type="hidden" name="atlas_title" value="{$print.title|escape}">
                        <input type="hidden" name="atlas_text" value="{$print.text|escape}">                        
                        <input type="hidden" id="page_zoom" name="page_zoom" value="{$print.page_zoom|escape}">
                        <input type="hidden" id="paper_size" name="paper_size" value="{$print.paper_size|escape}">
                        <input type="hidden" id="orientation" name="orientation" value="{$print.orientation|escape}">
                        <input type="hidden" id="provider" name="provider" value="{$print.provider|escape}">
                        <input type="hidden" id="refresh_id" name="refresh_id" value="{$print.id}"> 
                        {foreach from=$pages item="page" key="index"}
                            {if $page.page_number != "i"}    
                                <input type="hidden" name="pages[{$page.page_number|escape}]" value="{$page.nwse|escape}">
                            {/if}
                        {/foreach}  
                    </form>
                </div>
                {/if}
                <div class="map-buttons-br">
                    <form action="{$base_dir}/make-step3-info.php" accept-charset="utf-8" method="POST">    
                        <p class="borrow">{*<a href="#">Copy this atlas</a>*}<input type="submit" value="Copy this atlas"></p>
                        <input type="hidden" name="atlas_title" value="{$print.title|escape}">
                        <input type="hidden" name="atlas_text" value="{$print.text|escape}">                    
                        <input type="hidden" id="page_zoom" name="page_zoom" value="{$print.page_zoom|escape}">
                        <input type="hidden" id="paper_size" name="paper_size" value="{$print.paper_size|escape}">
                        <input type="hidden" id="orientation" name="orientation" value="{$print.orientation|escape}">
                        <input type="hidden" id="provider" name="provider" value="{$print.provider|escape}">
                        <input type="hidden" id="clone_id" name="clone_id" value="{$print.id}"> 
                        {foreach from=$pages item="page" key="index"}
                            {if $page.page_number != "i"}    
                                <input type="hidden" name="pages[{$page.page_number|escape}]" value="{$page.nwse|escape}">
                            {/if}
                        {/foreach} 
                    </form>
                    <p class="download"><a href="{$print.pdf_url}">Download PDF {* TODO: <span class="size">17MB</span> *}</a></p>
                </div>
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
                <!--<h4>Edit Atlas</h4>-->
                <select id="editors">
                    <option id="ignore">Edit In...</option>
                    <option id="iD">iD</option>
                    <option id="potlatch">Potlatch</option>
                </select>
                <!--
                <ul>
                    <li><a href="http://www.openstreetmap.us/iD/release/#background=custom:http://fieldpapers.org/files/scans/{$print.id}/{literal}{z}/{x}/{y}{/literal}.jpg&map={    $zoom}/{$print.longitude}/{$print.latitude}">Edit in iD</a></li>
                    <li><a href="http://www.openstreetmap.org/edit?lat={$print.latitude}&lon={$print.longitude}&zoom={$zoom}&tileurl=http://fieldpapers.org/files/scans/{$print.id    }/$z/$x/$y.jpg">Edit in Potlatch</a></li>
                </ul>
                -->
            </div>
          
            <script>
                var sel = document.getElementById("editors");
                {literal}
                sel.onchange = function(e) {
                    switch (e.target.value) { {/literal}
                        case "iD": window.open("http://www.openstreetmap.us/iD/release/#background=custom:http://fieldpapers.org/files/scans/{$print.id}/{literal}{z}/{x}/{y}{/literal}.jpg&map={$zoom}/{$print.longitude}/{$print.latitude}"); break;
                        case "Potlatch": window.open("http://www.openstreetmap.org/edit?lat={$print.latitude}&lon={$print.longitude}&zoom={$zoom}&tileurl=http://fieldpapers.org/files/scans/{$print.id}/$z/$x/$y.jpg"); break; 
                        default: break;
                    {literal}
                    };
                };

                {/literal}
            </script>

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
                                made this atlas 
                                {if $print.place_name}
                                    of   
                                    <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>,
                                    <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">{$print.region_name|nice_placename}</a>,
                                    <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a>
                                {/if}

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
                            </li>
                            {if $clone_child}
                                <li>
                                    <span class='extra-meta-note'>
                                    {if $clone_child.user_name}<a href="{$base_dir}/atlas.php?id={$cloned_child.user_id|escape}">{$clone_child.user_name|escape}</a>{else}Someone{/if}</a>
                                     made a 
                                    <a href="{$base_dir}/atlas.php?id={$clone_child.id|escape}"><i>copy</i></a>
                                     of this atlas - <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$clone_child.created}" class="date">{$clone_child.age|nice_relativetime|escape}</a>.
                                    </span>
                                </li>
                            {/if}
                            {if $clone_parent}
                                <li>
                                    <span class='extra-meta-note'>This atlas is a <i>copy</i> of <a href="{$base_dir}/atlas.php?id={$print.cloned|escape}">
                                    {if $clone_parent.title}{$clone_parent.title|escape:'html'}{else}Untitled{/if}</a></span>
                                </li>
                            {/if}
                           {if $refresh_child}
                                <li>
                                    <span class='extra-meta-note'>A <a href="{$base_dir}/atlas.php?id={$refresh_child.id|escape}">new, refreshed version</a> of this atlas was made by
                                    {if $refresh_child.user_name}{$refresh_child.user_name|escape}{else}someone{/if} 
                                    <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$refresh_child.created}" class="date">{$refresh_child.age|nice_relativetime|escape}</a>.
                                    </span>
                                </li>
                            {/if}
                            {if $refresh_parent}
                                <li>
                                    <span class='extra-meta-note'>This atlas is a <i>refresh</i> of <a href="{$base_dir}/atlas.php?id={$print.refreshed|escape}">
                                    {if $refresh_parent.title}{$refresh_parent.title|escape:'html'}{else}Untitled{/if}</a></span>
                                </li>
                            {/if} 
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
                                <a href="{$base_dir}/snapshots.php?month={"Y-m"|@date:$scan.created}" class="date">{$scan.age|nice_relativetime|escape}</a>
                                <br>
                                
                                <a href="{$base_dir}/snapshot.php?id={$scan.id|escape}"><img src="{$scan.base_url|escape}/preview.jpg"></a>
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
                                <a class="date">{$last_note.age|nice_relativetime|escape}</a>
                                
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
                                <a class="date">{$note.age|nice_relativetime|escape}</a>
                                <ol>
                                    <li>{$note.note|escape}</li>
                                </ol>
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
                {if $print.private}
                <p>
                    Since this atlas is <span class="private">private</span>, you probably should <a href="{$base_dir}/atlas.php?id={$print.id|escape}">bookmark it</a>.
                </p>
                {/if}
            </div>
        {/if}        

{* XXX MT follows *}
<div id="nearby-atlases">
<h3>Nearby</h3>

{foreach from=$nearby_prints item="print" name="index"}
<div class="atlasThumb-container atlasThumb">
    <div class="atlasThumb-small" style="background-image: url({$print.preview_url});"></div>
    <div class="atlasThumb-title">
        <h4 class="header"><a href="{$base_dir}/atlas.php?id={$print.id}">{if $print.title}{$print.title|decode_utf8|escape}{else}Untitled{/if}</a></h4>
    </div>
</div>
{/foreach}
</div>




{include file="footer.htmlf.tpl"}

</div>
</body>
</html>
