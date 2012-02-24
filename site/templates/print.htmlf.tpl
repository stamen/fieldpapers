{if $print.composed}
    <script>
        var map = null;
        {literal}
            $(document).ready(function() { 
                var MM = com.modestmaps;
                
                var overview_provider = 'http://tiles.teczno.com/bing-lite/{Z}/{X}/{Y}.jpg';
                var provider = 'http://spaceclaw.stamen.com/toner/{Z}/{X}/{Y}.png';
                
                // Map 1
                var overview_map = new MM.Map("overview_map", new MM.TemplatedMapProvider(provider),null,[]);
                
                
                // Map 2
                var map = new MM.Map("map", new MM.TemplatedMapProvider(provider),null,[]);
                
                var north = '{/literal}{$print.north}{literal}';
                var west = '{/literal}{$print.west}{literal}';
                var south = '{/literal}{$print.south}{literal}';
                var east = '{/literal}{$print.east}{literal}';
                
                var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                
                //overview_map.setExtent(extents);
                map.setExtent(extents);
                overview_map.setCenterZoom(map.getCenter(),5);
            });
        {/literal}
    </script>

    <div class="overview_print" id="overview_map"></div>

    <h1>
        Untitled
    </h1>
    <p>
        <b>City, Country</b><br />
        Created by <a href='{$base_dir}/person.php?id={$print.user_id}'>{$user_name}</a>, 
        <a href="{$base_dir}/time.php?date={$print.created}">{$print.age|nice_relativetime|escape}</a>
        <br />
        {$pages|@count} page(s)
        <br />
        <a href="{$print.pdf_url}"><b>Download PDF</b></a>
    </p>
    <div class="print" id="map"></div>
    
    
        <h2>{$pages|@count} pages</h2>
    
        {foreach from=$pages item="page" name="index"}
            <div class="atlasPage"> 
                <img src="{$page.preview_url}" alt="printed page" name="atlasPage" id="atlasPage" />
                <br />
                <span class="atlasPageNumber">{$page.page_number}</span>
            </div>
        {/foreach}

{else}
    <p>Preparing your atlas... ({$print.progress*100|string_format:"%d"}% complete)</p>
    <div class="progressBarCase">
        <div class="progressBar" style="width: {$print.progress*100}%;"></div>
    </div>
    <p>
        This may take a while, generally a few minutes. You don't need to keep this
        window open; you can <a href="{$base_dir}/print.php?id={$print.id|escape}">bookmark 
        this page</a> and come back later.
    </p>
{/if}