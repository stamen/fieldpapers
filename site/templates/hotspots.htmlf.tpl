    {foreach from=$prints item="print" name="index"}
            <div class="hotSpot">
                <div class="atlas" id="map{$print.index}"></div>
                <!--<a href="atlas.html"><img src="" alt="hotspot" name="map" width="100%" height="300"
                style="background-image:url(osm-placeholder.jpg); background-position:right" /></a>-->
                
                <!-- <div><a href="atlas.html">Wine Bars</a> in <a href="place.html">{$print.place_name}</a><a href="atlas.html"></a>, by 
                <a href="person.html">{$print.user_id}</a></div>-->
                
                <div>Print ID: <a href="print.php?id={$print.id}">{$print.id}</a> in <a href="place.html">Null</a><a href="print.php{$print.id}"></a>, by 
                <a href="person.html">{$print.user_id}</a></div>
            </div>
    {/foreach}