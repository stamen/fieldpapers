<h2>取り込んだ地図</h2>
            
{if $scan.description}
    <p style="font-style: italic;">
        {$scan.description|escape}
    </p>
{/if}

<p>
    近所をカバー

    {if $print.place_woeid}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
        <br />
        {$print.place_name|escape}

    {else}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
    {/if}
    <br/>
    アップロード {$scan.age|nice_relativetime|escape}
</p>

{if !$print.place_woeid}
    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[
    
        var onPlaces = new Function('res', "appendPlacename(res, document.getElementById('print-location'))");
        var flickrKey = '{$constants.FLICKR_KEY|escape}';
        var lat = {$print.latitude|escape};
        var lon = {$print.longitude|escape};
        
        getPlacename(lat, lon, flickrKey, 'onPlaces');

    // ]]>
    </script>
{/if}

<p>
    <a href="{$scan.base_url}/large.jpg">
        <img border="1" src="{$scan.base_url}/preview.jpg" /></a>
</p>

<p>
    <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">印刷された地図 #{$scan.print_id|escape} からこのエリアの最新地図</a>をダウンロードする
</p>
