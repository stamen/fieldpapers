<h2>Kartutskrift</h2>

<p>
    Skriv ut kartan av området runt
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
    Skapad {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Hämta kartan som PDF för utskrift</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Ladda ner kartan</a> för att komma igång 
    med att kartlägga detta område ifrån marknivå. Lägg till info om saker som 
    till exempel affärer, företag, parker, skolor, byggnader, gångvägar, 
    brevlådor, uttagsautomater och andra användbara landmärken. När du är klar,
    <a href="{$base_dir}/upload.php">Ladda upp en inskanning</a> av din karta 
    med anteckningar om förändringar driekt till OpenStreetMap.
</p>
