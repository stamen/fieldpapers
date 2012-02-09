{if $print.composed}
    <script>
        {literal}
            $(document).ready(function() { 
                var MM = com.modestmaps;
                
                var overview_provider = 'http://tiles.teczno.com/bing-lite/{Z}/{X}/{Y}.jpg';
                var provider = 'http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png';
                
                // Map 1
                var overview_map = new MM.Map("overview_map", new MM.TemplatedMapProvider(overview_provider),null,[]);
                
                
                // Map 2
                var map = new MM.Map("map", new MM.TemplatedMapProvider(provider),null,[]);
                
                var north = '{/literal}{$print.north}{literal}';
                var west = '{/literal}{$print.west}{literal}';
                var south = '{/literal}{$print.south}{literal}';
                var east = '{/literal}{$print.east}{literal}';
                
                var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                
                overview_map.setExtent(extents);
                map.setExtent(extents);
            });
        {/literal}
    </script>
    
    <h1>Title: {$print.id}</h1>
    <p>
        Created by {$user_name} on <a href="{$base_dir}/time.php?date={$print.created}">
        {$print.created|date_format}</a>. <a href="{$print.pdf_url}">Download</a> this print as a PDF.
    </p>
    <div class="overview_print" id="overview_map"></div>
    <div class="print" id="map"></div>
    <div class="fltlft">
        <h2>Pages</h2>
    
        {foreach from=$pages item="page" name="index"}
            <div class="atlasPage"> 
                <img src="{$page.preview_url}" alt="printed page" 
                name="atlasPage" width="180" height="240" id="atlasPage" style="background-color: #000" />
                <br />
                <span class="atlasPageNumber">{$page.page_number}</span>
            </div>
        {/foreach}
    </div>
{else}
    <p>Preparing your print.</p>
    <p>
        This may take a while, generally a few minutes. You don't need to keep this
        window open; you can <a href="{$base_dir}/print.php?id={$print.id|escape}">bookmark 
        this page</a> and come back later.
    </p>
{/if}