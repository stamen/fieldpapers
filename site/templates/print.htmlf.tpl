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
                var overview_map = new MM.Map("overview_map", overview_map_layers, null, []);
                
                
                // Map 2
                var map = new MM.Map("map", main_map_layers, null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
                
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
                
                canvas = Raphael("canvas"); // Use this for both the print and page extents
                
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
                <a href="snapshot.php?id={$scan.id|escape}">Scan {$scan.id|escape}</a>, {$scan.age|nice_relativetime|escape}
            </li>
        {/foreach}
    </ul>
    
    <h2>Notes</h2>

    <ul>
        {foreach from=$notes item="note"}
            <li>
                <i>{$note.note|escape}</i> on <a href="snapshot.php?id={$note.scan_id|escape}">scan {$note.scan_id|escape}</a>
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