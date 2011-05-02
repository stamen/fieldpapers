<p class="wide">
    {if $scan.has_geojpeg == 'yes'}
        <a href="{$scan.base_url}/{$scan.uploaded_file}" id="geo-jpeg">
            <img border="1" src="{$scan.base_url}/walking-paper-{$scan.id}.jpg" /></a>
    {else}
        <a href="{$scan.base_url}/{$scan.uploaded_file}">
            <img border="1" src="{$scan.base_url}/large.jpg" /></a>
    {/if}
</p>
