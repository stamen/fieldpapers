<p>
    Распечатка карты территории 
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
    Создано {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Скачать PDF карты для распечатки</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Скачайте карту</a> чтобы начать картировать в этом районе 
    прямо на улице. Добавляйте детали такие как офисы и организации, парки, школы, здания, дорожки, почтовые ящики, банкоматы и другие полезные объекты.
    Когда вы закончите, выгрузите  
    <a href="{$base_dir}/upload.php">отсканированную карту</a> со своими пометками и вы сможете перенести с нее информацию по своим заметкам прямо в OpenStreetMap.
</p>
