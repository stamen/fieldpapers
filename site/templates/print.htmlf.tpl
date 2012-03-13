{if $print.composed}
    <script>
    {literal}
        function loadMaps() {
        var map = null;
            var MM = com.modestmaps;
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
            var atlas_shape = null;
            var atlas_locations = [];
            
            var fillStyle = "rgba(5,5,5,0)";
            var lineWidth = 3;
            var lineJoin = 'round';

            var atlasStrokeStyle = 'rgba(255,255,255,1)';                
            
            atlas_locations.push({'lat': north, 'lon': west});
            atlas_locations.push({'lat': north, 'lon': east});
            atlas_locations.push({'lat': south, 'lon': east});
            atlas_locations.push({'lat': south, 'lon': west});
            
            atlas_shape = new MM.PolygonMarker(map, atlas_locations, fillStyle, atlasStrokeStyle, lineWidth, lineJoin);
            
            ////
            // Draw individual pages
            ////
            {/literal}{if $print.selected_page}{literal}
                var page_shape = null;
                var page_locations = [];
                
                var pageStrokeStyle = 'rgba(5,5,5,1)';
                var pageFillStyle = "rgba(5,5,5,0)";
                
                var north_page = '{/literal}{$pages[0].north}{literal}';
                var west_page = '{/literal}{$pages[0].west}{literal}';
                var south_page = '{/literal}{$pages[0].south}{literal}';
                var east_page = '{/literal}{$pages[0].east}{literal}';
                
                page_locations.push({'lat': north_page, 'lon': west_page});
                page_locations.push({'lat': north_page, 'lon': east_page});
                page_locations.push({'lat': south_page, 'lon': east_page});
                page_locations.push({'lat': south_page, 'lon': west_page});
                
                page_shape = new MM.PolygonMarker(map, page_locations, pageFillStyle, pageStrokeStyle, lineWidth, lineJoin);
            {/literal}{/if}{literal}
            };
    {/literal}
    </script>
    
    {if $print.selected_page}
        <div class="overview_print" id="overview_map"></div>
        <h1>
            Untitled {$pages.west}
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
            
            Created by <a href='{$base_dir}/atlases.php?user={$print.user_id}'>{$user_name}</a>, 
            <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a>
        </p>
        <ul><li><a href="{$print.pdf_url}"><b>Download PDF</b></a></li></ul>
        
        <div class="print" id="map"></div>
        
        <div class="clearfloat"></div>
        <br  clear="all">
        
        <h2>
            Page {$print.selected_page.page_number}
        </h2>
        
        <div class="atlasPage"> 
            <img src="{$print.selected_page.preview_url}" alt="printed page" name="atlasPage" id="atlasPage">
            <br>
            <span class="atlasPageNumber">{$print.selected_page.page_number}</span>
        </div>
    {else}
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
            
            Created by <a href='{$base_dir}/atlases.php?user={$print.user_id}'>{$user_name}</a>, 
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
        
        <div class="print" id="map"></div>
        
        <div class="clearfloat"></div>
        
            <h2 class="pageCount">
                {$pages|@count}
                {if $pages|@count == 1}
                    page
                {else}
                    pages
                {/if}
            </h2>
        
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