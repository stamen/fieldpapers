<p>
    Imprimer une carte aux alentours de la zone
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
    Créée {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Télécharger la carte au format PDF pour l'impression</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Téléchargez une carte</a> pour commencer à cartographier cette zone au niveau du quartier. 
    Ajoutez des détails comme des sociétés, parcs, écoles, bâtiments, chemins, boites à lettres, distributeurs automatiques, et d'autres informations utiles.
    Lorsque vous avez terminé, 
    <a href="{$base_dir}/upload.php">envoyez un scan</a> de votre carte annotée pour tracer vos changements faits à la main, ainsi que vos notes dans OpenStreetMap.
</p>
