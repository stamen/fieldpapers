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
        Карта в формате PDF для печати</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Скачайте карту</a> чтобы начать редактировать. 
    Добавляйте на карту детали, такие как дороги, парки, школы, здания, почтовые отделения, 
    банкоматы и другие полезные объекты. Когда вы закончите, отсканируйте карту с пометками и
    <a href="{$base_dir}/upload.php">загрузите изображение на наш сайт,</a> чтобы ваши правки
    можно было затем перенести в OpenStreetMap..
</p>
