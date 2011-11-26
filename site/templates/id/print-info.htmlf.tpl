<h2>Cetak Peta</h2>

<p>
    Cetak peta pada area sekeliling    {if $print.place_woeid}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
        <br />
        {$print.place_name|escape}

    {else}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
    {/if}
    <br />
    Dibuat{$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        Unduh peta PDF untuk dicetak</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">Unduh Peta</a> untuk dapat memulai pemetaan di wilayah ini. Tambahkan detail seperti bisnis, taman, sekolah, bangunan, jalur, PO BOX, ATM, dan landmark lainnya yang berguna. Jika telah selesai ,
    <a href="{$base_dir}/upload.php">kirimkan hasil scan</a> dari peta yang telah anda anotasikan untuk melacak perubahan dan catatan melalui tulisan tangan anda langsung melalui OpenStreetMap.
 </p>
