<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>Atlases - fieldpapers.org</title>
<script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
<link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
<style>
    {literal}
    #map {
        position: relative;
        height: 600px;
    }
    #markers {
        position: absolute;
        top: 0;
        left: 0;
        z-index: 100;
    }
    #markers .marker {
        position: absolute;
        background: green;
        border: 2px solid #000;
    }
    {/literal}
</style>
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h1>Atlases {$title|escape}</h1>
        <h2>Atlases | <a href="{$base_dir}/snapshots.php?{$request.query|escape}">Snapshots</a></h2>

        {* add a map here (https://github.com/stamen/fieldpapers/issues/212) *}
	<div id="map">
            <div id="markers"></div>
        </div>

        
        {foreach from=$prints item="print" name="index"}
            <div class="atlasThumb">
                <a href="{$base_dir}/atlas.php?id={$print.id}"><img src="{$print.preview_url}" alt="printed page" width="100%"{if $print.private} class="private"{/if}></a>

                <a href="{$base_dir}/atlas.php?id={$print.id}">{if $print.title}{$print.title|decode_utf8|escape}{else}Untitled{/if}</a>

                {if $print.user.name}
                    by <a href="{$base_dir}/atlases.php?user={$print.user_id}">{$print.user.name}</a>,
                {else}
                    by Anonymous,
                {/if}

                {if $print.place_name}
                    <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">{$print.region_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a>
                {/if}

                {if $print.number_of_pages == 1}
                    1 page,
                {elseif $print.number_of_pages == 2}
                    two pages,
                {else}
                    {$print.number_of_pages} pages,
                {/if}

                <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a>. {if $print.private}<span class="private"> private</span>{/if}
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
	<div class="clearfloat"></div>

    <script>
        var prints = {$prints_json},
            print_href = "{$base_dir}/atlas.php?id=";
        {literal}
        var corners = [],
            markers = [];
        prints.forEach(function(print) {
            print.northwest = {lat: +print.north, lon: +print.west}; 
            print.southeast = {lat: +print.south, lon: +print.east};
            corners.push(print.northwest, print.southeast);
            var marker = document.createElement("a");
            marker.print = print;
            marker.setAttribute("href", print_href + print.id);
            markers.push(marker);
        });
        var template = 'http://tile.stamen.com/toner-lite/{Z}/{X}/{Y}.png';
        var provider = new MM.TemplatedMapProvider(template);
        var map = new MM.Map('map', provider, null, []);
        map.setExtent(corners);

        var marker_container = document.getElementById("markers");
        markers.forEach(function(marker, i) { 
            var top_left = map.locationPoint(marker.print.northwest),
                bottom_right = map.locationPoint(marker.print.southeast);
            marker.style.left = top_left.x + "px";
            marker.style.top = top_left.y + "px";
            marker.style.width = (bottom_right.x - top_left.x) + "px";
            marker.style.height = (bottom_right.y - top_left.y) + "px";
            marker.className = "marker"; 
            marker_container.appendChild(marker);
        });
        {/literal}
    </script>

    {include file="footer.htmlf.tpl"} 
    </div>

</body>
</html>
