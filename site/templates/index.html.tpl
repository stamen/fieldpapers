<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Walking Papers</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/index.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
    <script type="text/javascript" src="{$base_dir}/index.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    {include file="$language/index-top-paragraph.htmlf.tpl"}
    
    {*
    <p>
        <img src="{$base_dir}/scan-example.jpg" border="1" />
    </p>
    *}
    
    <h2>Recent Scans</h2>
    
    {include file="scans-table.htmlf.tpl"}
    
    <p class="pagination">
        <a href="{$base_dir}/scans.php">More recent scans</a> →
    </p>
    
    <h2>{strip}
        <a name="make">Make A Print</a>
    {/strip}</h2>
    
    {include file="$language/index-compose-explanation.htmlf.tpl"}

    <form onsubmit="return getPlaces(this.elements['q'].value, this.elements['appid'].value);">
        <input type="text" name="q" size="24" />
        <input class="mac-button" type="submit" name="action" value="Find" />
        <input type="hidden" name="appid" value="{$constants.GEOPLANET_APPID|escape}" />
        <span id="watch-cursor" style="visibility: hidden;"><img src="{$base_dir}/watch.gif" align="top" vspace="4" /></span>
    </form>

    <p>
        <a href="#" id="permalink"></a>
    </p>

    <div class="sheet">
        <div id="map"></div>
        <!-- <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div> -->
        <img class="slippy-nav" src="{$base_dir}/slippy-nav.png" width="43" height="57" border="0" alt="up" usemap="#slippy_nav"/>
        <map name="slippy_nav">
            <area shape="rect" alt="out" coords="14,31,28,41" href="javascript:map.zoomOut()">
            <area shape="rect" alt="in" coords="14,14,28,30" href="javascript:map.zoomIn()">
            <area shape="rect" alt="right" coords="29,21,42,35" href="javascript:map.panRight()">
            <area shape="rect" alt="down" coords="14,42,28,56" href="javascript:map.panDown()">
            <area shape="rect" alt="up" coords="14,0,28,13" href="javascript:map.panUp()">
            <area shape="rect" alt="left" coords="0,21,13,35" href="javascript:map.panLeft()">
        </map>
        <div id="atlas-pages">
            <div class="row-1 divider"></div>
            <div class="row-2 divider"></div>
            <div class="row-3 divider"></div>
            <div class="col-1 divider"></div>
            <div class="col-2 divider"></div>
            <div class="col-3 divider"></div>
        </div>
        <div class="dog-ear"> </div>
        <div id="zoom-warning" style="display: none;">
            A zoom level of <b>14 or more</b> is recommended for street-level mapping.
        </div>
    </div>
    
    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[

        var map = makeMap('map', '{$provider|escape:"javascript"}');
        map.setCenterZoom(new mm.Location({$latitude}, {$longitude}), {$zoom});
        
        // {literal}
        
        function onPlaces(res)
        {
            if(document.getElementById('watch-cursor'))
                document.getElementById('watch-cursor').style.visibility = 'hidden';
        
            if(res['places'] && res['places']['place'] && res['places']['place'][0])
            {
                var place = res['places']['place'][0];
                var bbox = place['boundingBox'];
        
                var sw = new mm.Location(bbox['southWest']['latitude'], bbox['southWest']['longitude']);
                var ne = new mm.Location(bbox['northEast']['latitude'], bbox['northEast']['longitude']);
                
                map.setExtent([sw, ne]);

            } else {
                alert("Sorry, I couldn't find a place by that name.");
            }
        }
        
        function setProvider(providerURL)
        {
            var tileURL = getTileURLFunction(providerURL);
            map.setProvider(new mm.MapProvider(tileURL));
            onMapChanged(map);
        }
        
        function setPapersize(paper)
        {
            var sheet = map.parent.parentNode;
            
            // ditch existing paper details
            sheet.className = sheet.className.replace(/\b(portrait|landscape|letter|a4|a3)\b/g, ' ');
        
            if(paper == 'portrait-letter') {
                sheet.className = sheet.className + ' portrait letter';
                map.dimensions = new mm.Point(360, 480 - 24);
            
            } else if(paper == 'portrait-a4') {
                sheet.className = sheet.className + ' portrait a4';
                map.dimensions = new mm.Point(360, 504.897);
            
            } else if(paper == 'portrait-a3') {
                sheet.className = sheet.className + ' portrait a3';
                map.dimensions = new mm.Point(360, 506.200);
            
            } else if(paper == 'landscape-letter') {
                sheet.className = sheet.className + ' landscape letter';
                map.dimensions = new mm.Point(480, 360 - 24);
            
            } else if(paper == 'landscape-a4') {
                sheet.className = sheet.className + ' landscape a4';
                map.dimensions = new mm.Point(480, 303.800);
            
            } else if(paper == 'landscape-a3') {
                sheet.className = sheet.className + ' landscape a3';
                map.dimensions = new mm.Point(480, 314.932);
            }

            map.parent.style.width = parseInt(map.dimensions.x) + 'px';
            map.parent.style.height = parseInt(map.dimensions.y) + 'px';
            map.draw();
        }
        
        function setLayout(layout)
        {
            var atlas_pages = document.getElementById('atlas-pages');

            if(layout == '4,4') {
                atlas_pages.className = 'sixteen-up';
            
            } else if(layout == '2,2') {
                atlas_pages.className = 'four-up';
            
            } else {
                atlas_pages.className = 'one-up';
            }
        }
        
        // {/literal}
    
    // ]]>
    </script>
    
    {if $constants.ADVANCED_COMPOSE_FORM}
        <form action="#">
            <script type="text/javascript" language="javascript1.2">
            // <![CDATA[{literal}
                
                function setComposeForm(name)
                {
                    var names = ['bounds', 'uploads'];
    
                    for(var i in names)
                    {
                        var form = document.forms[names[i]];
                    
                        if(names[i] == name) {
                            form.style.display = 'block';
    
                        } else {
                            form.style.display = 'none';
                        }
                    }
    
                    return false;
                }
    
            // {/literal}]]>
            </script>
            
            <p>
                Compose:
                <label>
                    <input type="radio" name="compose-form" value="bounds" onchange="setComposeForm(this.value);" checked="checked" />
                    by map area,
                </label>
                <label>
                    <input type="radio" name="compose-form" value="uploads" onchange="setComposeForm(this.value);"/>
                    by file upload.
                </label>
            </p>
        </form>

        <form action="{$base_dir}/compose-print.php" method="post" name="uploads" style="display: none;" enctype="multipart/form-data">
            <p>
                <input name="file" type="file" />
            </p>
            <p>
                Paper size:
                
                <select name="paper">
                    {foreach from=$paper_sizes item="size"}
                        <option label="{$size|ucwords}" value="{$size|lower}">{$label}</option>
                    {/foreach}
                </select>

                <input class="mac-button" type="submit" name="action" value="Upload" />
                <input type="hidden" name="source" value="upload" />
            </p>
        </form>
    {/if}

    <form action="{$base_dir}/compose-print.php" method="post" name="bounds" style="display: block;">
        <input name="north" type="hidden" />
        <input name="south" type="hidden" />
        <input name="east" type="hidden" />
        <input name="west" type="hidden" />
        <input name="zoom" type="hidden" />

        <p>
            Orientation:
            
            <select name="paper" onchange="setPapersize(this.value);">
                {foreach from=$paper_sizes item="size"}
                    <option label="{$label}" value="portrait-{$size|lower}">Portrait ({$size})</option>
                {/foreach}
    
                {foreach from=$paper_sizes item="size"}
                    <option label="{$label}" value="landscape-{$size|lower}">Landscape ({$size})</option>
                {/foreach}
            </select>
    
            <input class="mac-button" type="submit" name="action" value="Make" />
            <input type="hidden" name="source" value="bounds" />
        </p>
        
        <p>
            Layout:
            
            <label><input name="layout" type="radio" value="1,1" onchange="setLayout(this.value);" checked="checked" /> 1 page</label>
            <label><input name="layout" type="radio" value="2,2" onchange="setLayout(this.value);" /> 4 pages (2×2)</label>
            <label><input name="layout" type="radio" value="4,4" onchange="setLayout(this.value);" /> 16 pages (4×4)</label>
            {* <label><input name="layout" type="radio" value="8,8" onchange="setLayout(this.value);" /> 64 pages (8×8)</label> *}
        </p>

        {if $request.get.provider}
            <input type="hidden" name="provider" value="{$provider|escape}" />

        {else}
            <p>
                Provider:
                <select name="provider" onchange="setProvider(this.value);">
                    {foreach from=$providers item="provider" name="providers"}
                        <option label="{$provider.1|escape}" value="{$provider.0|escape}" {if $smarty.foreach.providers.first}selected="selected"{/if}>{$provider.1|escape}</option>
                    {/foreach}
                </select>
            </p>
            <p>
                Grid:
                <input type="radio" name="grid" value="" checked="checked" /> None
                <input type="radio" name="grid" value="utm" /> UTM
                <input type="radio" name="grid" value="mgrs" /> MGRS/USNG
            </p>
        {/if}
    </form>

    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[

        // do this just to dirty all the form fields
        onMapChanged(map);

    // ]]>
    </script>

    <h2>Recent Prints</h2>
    
    <ol>
        {foreach from=$prints item="rprint"}
            <li>
                {if $rprint.place_woeid}
                    <a href="{$base_dir}/print.php?id={$rprint.id|escape}">
                        <b id="print-{$rprint.id|escape}">{$rprint.age|nice_relativetime|escape}</b>
                        <br />
                        {$rprint.place_name|escape} ({$rprint.paper_size|ucwords|escape})</a>

                {else}
                    <a href="{$base_dir}/print.php?id={$rprint.id|escape}">
                        <b id="print-{$rprint.id|escape}">{$rprint.age|nice_relativetime|escape}</b></a>
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                        {if $rprint.latitude && $rprint.longitude}
                            var onPlaces_{$rprint.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('print-{$rprint.id|escape}'))");
                            getPlacename({$rprint.latitude|escape}, {$rprint.longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$rprint.id|escape}');
                        {/if}
                    // ]]>
                    </script>
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p>{strip}
        <a href="{$base_dir}/prints.php">More recent prints...</a>
    {/strip}</p>
    
    <p>
        <a href="http://www.flickr.com/photos/junipermarie/4133315811/" title="IMG_4806.JPG by ricajimarie, on Flickr"><img src="{$base_dir}/kibera-scans.jpg" border="1" /></a>
        <br/>
        <a href="http://www.flickr.com/photos/junipermarie/4133315811/" title="IMG_4806.JPG by ricajimarie, on Flickr">Walking Papers in Kibera</a> by <a href="http://www.flickr.com/photos/junipermarie/">ricajimarie on Flickr</a>
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
