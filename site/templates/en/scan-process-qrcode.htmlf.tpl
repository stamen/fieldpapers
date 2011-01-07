<p>
    If the image above looks like a
    <a href="http://en.wikipedia.org/w/index.php?title=QR_Code&amp;oldid=405297309">QR code</a>,
    then it’s possible that the <a href="http://code.google.com/p/zxing/">library we use to read codes</a>
    had some difficulty understanding it. This can happen because of smudges, bluriness,
    or sometimes reasons we can’t figure out.
</p>
<p>
    Help complete this step by entering the text from the top-right corner of your scan:
</p>
<form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post">
    <input name="qrcode_contents" type="text" size="48" placeholder="http://{$domain}{$base_dir}/print.php?id=0000" />
    <input name="action" type="hidden" value="override QR code" />
    <input class="mac-button" type="submit" value="Save" />
</form>
<p>
    Here’s an example:
</p>
<p>
    <img border="1" src="{$base_dir}/img/sample-print-top.png" />
</p>
