<print id="{$print.id|escape}{if $print.atlas_page}/{$print.atlas_page.part|escape}{/if}" user="{$print.user_id|escape}" href="http://{$domain}{$base_dir}/print.php?id={$print.id|escape:"url"}{if $print.atlas_page}/{$print.atlas_page.part|escape:"url"}{/if}">
    <paper size="{$print.paper_size|escape}" orientation="{$print.orientation|escape}" />
    <provider>{$print.provider|escape}</provider>
    <preview href="{if $print.atlas_page}/{$print.atlas_page.preview_href|escape}{else}{$print.preview_url|escape}{/if}" />
    <pdf href="{$print.pdf_url|escape}" />
    <bounds>
        {if $print.atlas_page}
            <north>{$print.atlas_page.bounds.north|escape}</north>
            <south>{$print.atlas_page.bounds.south|escape}</south>
            <east>{$print.atlas_page.bounds.east|escape}</east>
            <west>{$print.atlas_page.bounds.west|escape}</west>
        {else}
            <north>{$print.north|escape}</north>
            <south>{$print.south|escape}</south>
            <east>{$print.east|escape}</east>
            <west>{$print.west|escape}</west>
        {/if}
    </bounds>
    <center>
        <latitude>{$print.latitude|escape}</latitude>
        <longitude>{$print.longitude|escape}</longitude>
        <zoom>{$print.zoom|escape}</zoom>
    </center>
    <country woeid="{$print.country_woeid|escape}">{$print.country_name|escape}</country>
    <region woeid="{$print.region_woeid|escape}">{$print.region_name|escape}</region>
    <place woeid="{$print.place_woeid|escape}">{$print.place_name|escape}</place>
</print>
