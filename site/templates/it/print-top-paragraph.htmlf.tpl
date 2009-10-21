<p>
    Stampa una mappa dell'area intorno a
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
    Creata {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Scarica il PDF della mappa per stamparlo</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Scarica una mappa</a> per iniziare a mappare quest'area a livello stradale.
     Aggiungi dettagli come negozi, parchi, scuole, edifici, sentieri e percorsi, cassette postali,
    bancomat e altri punti di interesse utili. Quando hai finito,
    <a href="{$base_dir}/upload.php">invia la scansione</a> della tua mappa annotata
    in modo da tracciare le tue modifiche scritte a mano e le annotazioni direttamente in OpenStreetMap.
</p>
