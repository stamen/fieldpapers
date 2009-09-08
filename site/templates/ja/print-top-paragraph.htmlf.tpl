<p>
  この周囲の地図を印刷
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
    {$print.age|nice_relativetime|escape}を作成。
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        印刷用の地図をPDFフォーマットでダウンロード</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">地図のダウンロードから、</a>この領域の道路だけのマッピングを始める地図が入手できます。商用の情報や、公園、学校、ビル、遊歩道、郵便ポスト、キャッシュディスペンサー、あるいはほかのランドマークなどの詳細を追加することができます。
作業がおわったら、あなたの手書きでの変更や備考を直接OpenStreetMapに入れるために、
  メモを入れた地図を  <a href="{$base_dir}/upload.php">スキャンし投稿します</a>
</p>
