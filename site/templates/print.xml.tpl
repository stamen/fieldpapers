<print id="{$print.id|escape}" user="{$print.user_id|escape}" href="http://{$domain}{$base_dir}{$base_href}?id={$print.id|escape:"url"}">
    <paper size="{$print.paper_size|escape}" orientation="{$print.orientation|escape}" />
    <provider>{$print.provider|escape}"</provider>
    <preview href="{$print.preview_url|escape}" />
    <pdf href="{$print.pdf_url|escape}" />
    <bounds>
        <north>{$print.north|escape}</north>
        <south>{$print.south|escape}</south>
        <east>{$print.east|escape}</east>
        <west>{$print.west|escape}</west>
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
