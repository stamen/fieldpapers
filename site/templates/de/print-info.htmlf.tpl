<p>
    Karte von dem diesem Bereich drucken
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
        Karten-PDF zum Ausdrucken herunterladen</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Eine Karte herunterladen</a>, um dieses Gebiet auf Straßenebene
    zu erfassen. Füge Details wie Geschäfte, Parks, Schulen, Gebäude, Wege,
    Briefkästen, Bankautomaten und andere nützliche Informationen hinzu. Anschließend lädst du,
    <a href="{$base_dir}/upload.php">einen Scan</a> deiner beschrifteten Karte hoch, um deine
    handgeschriebenen Informationen direkt zu OpenStreetMap hinzuzufügen.
</p>
