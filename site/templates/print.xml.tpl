<print id="{$print.id|escape}{if $print.selected_page}/{$print.selected_page.page_number|escape}{/if}" user="{$print.user_id|escape}" href="http://{$domain}{$base_dir}/print.php?id={$print.id|escape:"url"}{if $print.selected_page}/{$print.selected_page.page_number|escape:"url"}{/if}">
    <paper size="{$print.paper_size|escape}" orientation="{$print.orientation|escape}" layout="{if $print.selected_page}{$print.selected_page.layout|escape}{else}{$print.layout|escape}{/if}" />
    <provider>{$print.provider|escape}</provider>
    <preview href="{if $print.selected_page}{$print.selected_page.preview_url|escape}{else}{$print.preview_url|escape}{/if}" />
    <pdf href="{$print.pdf_url|escape}" />
    <bounds>
        {if $print.selected_page}
            <north>{$print.selected_page.north|escape}</north>
            <south>{$print.selected_page.south|escape}</south>
            <east>{$print.selected_page.east|escape}</east>
            <west>{$print.selected_page.west|escape}</west>
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
