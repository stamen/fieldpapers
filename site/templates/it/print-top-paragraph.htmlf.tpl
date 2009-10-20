<p>
    Print map of the area surrounding
    {if $print.place_woeid}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
        <br />
        {$print.place_name|escape}

    {else}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
    {/if}
    <br />
    Created {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Download map PDF for print</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Download a map</a> to get started mapping this area
    from street level. Add details like businesses, parks, schools, buildings, paths,
    post boxes, cash machines and other useful landmarks. When you’re finished,
    <a href="{$base_dir}/upload.php">post a scan</a> of your annotated map
    to trace your handwritten changes and notes directly into OpenStreetMap.
</p>
