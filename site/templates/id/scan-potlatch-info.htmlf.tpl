<p>
Anda diharuskan untuk log in dengan akun OpenStreetMap anda untuk melakukan editing; lakukan di bawah ini atau    
    <a href="http://www.openstreetmap.org/user/new">buat akun baru</a>.
    <strong><i>Walking Papers</i> tidak akan melihat atau menyimpan sandi anda</strong>,
    sandi anda akan dialihkan langsung ke OpenStreetMap.
</p>
<p>
    <label for="username">Alamat email atau nama pengguna</label>
    <br />
    <input id="username-textfield" name="username" type="text" size="30" />
</p>
<script type="text/javascript">
// <![CDATA[{literal}

    if(readCookie('openstreetmap-username') && document.getElementById('username-textfield'))
        document.getElementById('username-textfield').value = readCookie('openstreetmap-username');

// {/literal}]]>
</script>
<p>
    <label for="password">Kata kunci</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Lupa kata kunci?</a>)
</p>
<p>
Form ini akan digantikan oleh jendela editing interaktif dengan peta hasil scan anda sebagai latar belakang untuk petunjuk.
</p>
