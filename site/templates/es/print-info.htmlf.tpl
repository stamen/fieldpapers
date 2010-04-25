<p>
    Imprimir mapa del área circundante
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
    Creado {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Descargar PDF del mapa para imprimir</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Descargar mapa</a> para empezar a mapear este área a nivel de calle. 
    Añade detalles como negocios, parques, escuelas, edificios, caminos, buzones, cajeros automáticos y otros lugares útiles.
    Cuando hayas terminado, 
    <a href="{$base_dir}/upload.php">sube un scan</a> de tu mapa anotado 
    para importar tus cambios y notas manuscritas directamente a OpenStreetMap.
</p>
