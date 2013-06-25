<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>Atlases - fieldpapers.org</title>
<script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
<link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div id="map">
        <div id="markers"></div>
    </div>
        
    <div class="container">
        <h2 class="header"> {$pagination.total_fmt} atlases {$title|escape} <span class="pipe-divider">/</span> 
        <a href="{$base_dir}/snapshots.php{if $query_without_page}?{$query_without_page|escape}{/if}">Snapshots</a></h2>
        <div class='pagination-top'>
        {include file="pagination.htmlf.tpl"}
        </div>
        <div id="columns"> 
            {foreach from=$prints item="print" name="index"}
                <div class="atlasPin"> 
                    <a href="{$base_dir}/atlas.php?id={$print.id}"><img src="{$print.preview_url}" alt="printed page" width="100%"></a> 
                    <a href="{$base_dir}/atlas.php?id={$print.id}"><strong>{if $print.title}{$print.title|escape}{else}Untitled{/if}</strong></a> 
                        {if $print.user.name}
                            by <a href="{$base_dir}/atlases.php?user={$print.user_id}"><strong>{$print.user.name}</strong></a> 
                        {else}
                            <small>&nbsp;anonymous</small>
                        {/if} 
                        <br />
                        <small>
                        {if $print.number_of_pages == 1}
                            1 page,
                        {elseif $print.number_of_pages == 2}
                            two pages,
                        {else}
                            {$print.number_of_pages} pages
                        {/if} 
                        <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a> 
                        <br />
                        {if $print.place_name} 
                            <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>, 
                            <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">{$print.region_name|nice_placename}</a>, 
                            <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a> 
                        {/if} 
                        </small>
                 </div>
            {/foreach} 
        </div>
        {include file="pagination.htmlf.tpl"}
        <div class="clearfloat"></div>

    <script>
        var prints = {$prints_json},
            print_href = "{$base_dir}/atlas.php?id=";
        {literal}
      
        function getDeepOffsetTop(elm){
            var top = 0;
            elm = elm || null;

            while(elm){
              top += elm.offsetTop || 0;
              elm = elm.offsetParent || null;
            }

            return top;
        }   
        
        function fitMapInWindow(elm){
            var mapTargetHeight = 580;
            var minMapHeight = 250;
            var bottomPadding = 20;
            var fromTop = getDeepOffsetTop(elm);
            var winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
            var maxAvailable = winHeight - (fromTop + bottomPadding);
            if(maxAvailable < mapTargetHeight){
                if(maxAvailable < minMapHeight)maxAvailable = minMapHeight;
                elm.style.height = maxAvailable + "px";
            }
        }
        var mapDom = document.getElementById('map');
        if(mapDom) fitMapInWindow(mapDom);

        var corners = [],
            markers = [];
        prints.forEach(function(print) {
            print.northwest = {lat: +print.north, lon: +print.west}; 
            print.southeast = {lat: +print.south, lon: +print.east};
            corners.push(print.northwest, print.southeast);
            var marker = document.createElement("a");
            marker.print = print;
            marker.setAttribute("href", print_href + print.id);
            var title = print.title || "Untitled";
            marker.setAttribute("title", title);
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
            var width = Math.ceil(bottom_right.x - top_left.x),
                height = Math.ceil(bottom_right.y - top_left.y);
            if (width < 20) {
                top_left.x -= Math.floor((20 - width) / 2);
                width = 20;
            }
            if (height < 20) {
                top_left.y -= Math.floor((20 - height) / 2);
                height = 20;
            }
            marker.style.left = top_left.x + "px";
            marker.style.top = top_left.y + "px";
            marker.print.area = width * height;
            marker.style.width = width + "px";
            marker.style.height = height + "px";
            marker.className = "marker"; 
        });

        markers.sort(function(a,b) {
            return b.print.area - a.print.area;
        });

        markers.forEach(function(marker) {
            marker_container.appendChild(marker); 
        });

        // ref: http://unscriptable.com/2009/03/20/debouncing-javascript-methods/ 
        var debounce = function (func, threshold, execAsap) {
 
            var timeout;
     
            return function debounced () {
                var obj = this, args = arguments;
                function delayed () {
                    if (!execAsap)
                        func.apply(obj, args);
                    timeout = null; 
                };
     
                if (timeout)
                    clearTimeout(timeout);
                else if (execAsap)
                    func.apply(obj, args);
     
                timeout = setTimeout(delayed, threshold || 100); 
            };
     
        }         
        
        function repositionMarkers(){
            markers.forEach(function(marker){
                var top_left = map.locationPoint(marker.print.northwest);
                marker.style.left = top_left.x + "px";
                marker.style.top = top_left.y + "px";
            });
        }
        // reposition markers on resize
        var repositionMarkersDebounce = debounce(repositionMarkers,50);
        map.addCallback('resized', repositionMarkersDebounce); 
 
        {/literal}
    </script>

    {include file="footer.htmlf.tpl"} 
    </div>

</body>
</html>
