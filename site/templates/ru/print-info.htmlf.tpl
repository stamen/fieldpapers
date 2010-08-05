<h2>Напечатать карту</h2>

<p>
    Напечатать карту территории вокруг
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
        Загрузить PDF карты для печати</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Загрузите карту</a> чтобы начать картировать. 
    Добавляйте детали, такие как офисы, парки, школы, здания, дорожки, почтовые ящики,
    банкоматы и другие полезности. Когда вы закончили,
    <a href="{$base_dir}/upload.php">отправьте скан</a> карты с пометками
    чтобы начать переносить их в цифровую форму прямо в OpenStreetMap.
</p>
