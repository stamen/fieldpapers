<p>
   Jika gambar di atas terlihat seperti
    <a href="http://en.wikipedia.org/w/index.php?title=QR_Code&amp;oldid=405297309">QR code</a>,
    Maka terdapat kemungkinan bahwa sebuah href="http://code.google.com/p/zxing/">library yang kita gunakan untuk membaca kode</a>
    memiliki kesulitan untuk memahaminya. Hal ini dapat terjadi karena noda, buram, atau terkadang beberapa hal yang tidak dapat kami perkirakan.
</p>
<p>
    Mohon lengkapi langkah ini dengan memasukan teks dari pojok kanan atas hasil scan anda :
</p>
<form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post">
    <input name="qrcode_contents" type="text" size="48" placeholder="http://{$domain}{$base_dir}/print.php?id=0000" />
    <input name="action" type="hidden" value="override QR code" />
    <input class="mac-button" type="submit" value="Save" />
</form>
<p>
    Berikut sebuah contoh:
</p>
<p>
    <img border="1" src="{$base_dir}/img/sample-print-top.png" />
</p>
