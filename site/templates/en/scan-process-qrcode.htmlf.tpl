{*
    
*}
<p>
    All is not lost. Fill this:
</p>
<p>
    <img border="1" src="{$base_dir}/img/sample-print-top.png" />
</p>
<p>
    ...in here:
</p>
<form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post">
    <input name="qrcode_contents" type="text" size="48" />
    <input name="action" type="hidden" value="override QR code" />
    <input class="mac-button" type="submit" value="Save" />
</form>
