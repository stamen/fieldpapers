{if $print.composed}
    <script>
        var map = null;
        {literal}            
            $(document).ready(function() { 
                var MM = com.modestmaps;
                
                {/literal}
                {if $print.selected_page}
                {literal}
                    var overview_provider = '{/literal}{$print.selected_page.provider}{literal}';
                    var main_provider = '{/literal}{$print.selected_page.provider}{literal}';
                {/literal}
                {else}
                {literal}
                    var overview_provider = '{/literal}{$pages[0].provider}{literal}';
                    var main_provider = '{/literal}{$pages[0].provider}{literal}';
                {/literal}
                {/if}
                {literal}
                
                // Map 1
                var overview_map = new MM.Map("overview_map", new MM.TemplatedMapProvider(overview_provider),null,[]);
                
                
                // Map 2
                var map = new MM.Map("map", new MM.TemplatedMapProvider(main_provider),null,[]);
                
                var north = '{/literal}{$print.north}{literal}';
                var west = '{/literal}{$print.west}{literal}';
                var south = '{/literal}{$print.south}{literal}';
                var east = '{/literal}{$print.east}{literal}';
                
                var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                
                map.setExtent(extents);
                overview_map.setCenterZoom(map.getCenter(),5);
            });
        {/literal}
    </script>
    
    {if $print.selected_page}
        <div class="overview_print" id="overview_map"></div>
        <h1>
            Untitled
        </h1>
        <p>
            {if $print.place_woeid && $print.country_name}
                <b><a href='{$base_dir}/place.php?place_id={$print.place_woeid}'>{$print.place_name}</a>, 
                <a href='{$base_dir}/place.php?country_id={$print.country_woeid}'>{$print.country_name}</a></b><br />
            {/if}
            Created by <a href='{$base_dir}/person.php?id={$print.user_id}'>{$user_name}</a>, 
            <a href="{$base_dir}/time.php?date={$print.created}">{$print.age|nice_relativetime|escape}</a>
        </p>
        <ul><li><a href="{$print.pdf_url}"><b>Download PDF</b></a></li></ul>
        
        <div class="print" id="map"></div>
        
        <div class="clearfloat"></div>
        
        <h2>Individual Page</h2>
        
        <div class="atlasPage"> 
            <img src="{$print.selected_page.preview_url}" alt="printed page" name="atlasPage" id="atlasPage" />
            <br />
            <span class="atlasPageNumber">{$print.selected_page.page_number}</span>
        </div>
    {else}
        <div class="overview_print" id="overview_map"></div>
        <h1>
            Untitled
        </h1>
        <p>
            {if $print.place_woeid && $print.country_name}
                <b><a href='{$base_dir}/place.php?place_id={$print.place_woeid}'>{$print.place_name}</a>, 
                <a href='{$base_dir}/place.php?country_id={$print.country_woeid}'>{$print.country_name}</a></b><br />
            {/if}
            Created by <a href='{$base_dir}/person.php?id={$print.user_id}'>{$user_name}</a>, 
            <a href="{$base_dir}/time.php?date={$print.created}">{$print.age|nice_relativetime|escape}</a>
            <br />
            {$pages|@count} page(s)
        </p>
        <ul><li><a href="{$print.pdf_url}"><b>Download PDF</b></a></li></ul>
        
        <div class="print" id="map"></div>
        
        <div class="clearfloat"></div>
        
            <h2>{$pages|@count} pages</h2>
        
            {foreach from=$pages item="page" name="index"}
                <div class="atlasPage"> 
                    <img src="{$page.preview_url}" alt="printed page" name="atlasPage" id="atlasPage" />
                    <br />
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
            This may take a while, generally a few minutes. <br /><br />
			You don't need to keep this window open; you can <a href="{$base_dir}/print.php?id={$print.id|escape}">bookmark 
            this page</a> and come back later.
        </p>
	</div>
{/if}