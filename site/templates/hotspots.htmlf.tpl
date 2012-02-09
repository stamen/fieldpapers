    {foreach from=$prints key="k" item="print" name="index"}
        <script>
            {literal}
                $(document).ready(function() { 
                    var MM = com.modestmaps;
            
                    var provider = '{/literal}{$print.provider}{literal}';
                    
                    var map = new MM.Map("map{/literal}{$k}{literal}", new MM.TemplatedMapProvider(provider),null,[]);
                    
                    var north = '{/literal}{$print.north}{literal}';
                    var west = '{/literal}{$print.west}{literal}';
                    var south = '{/literal}{$print.south}{literal}';
                    var east = '{/literal}{$print.east}{literal}';
                    
                    var extents = [new MM.Location(north, west), new MM.Location(south, east)];
                
                    map.setExtent(extents);
                });
            {/literal}
        </script>
        
        <div class="hotSpot">
            <div class="atlas" id="map{$k}"></div>
            
            <div>
            <a href="{$base_dir}/print.php?id={$print.id}">Untitled</a> in <a href="{$base_dir}/place.php">
            Place</a>, by <a href="{$base_dir}/person.php?id={$print.user_id}">{$print.user_name}</a>
            </div>
        </div>
    {/foreach}