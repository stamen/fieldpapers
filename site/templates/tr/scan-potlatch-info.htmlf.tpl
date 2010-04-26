<p>
	OSM Haritasına değişmek için aşağıdaki formu doldurarak
	OpenStreetMap hezabına girmen lazım veya
    <a href="http://www.openstreetmap.org/user/new">yeni hesabı oluştur</a>.
    <strong><i>Walking Papers</i>, senin şifreni ne görecek ne kaydedecektir.</strong>
    OpenStreetMap'a direkt veriliyor.
</p>
<p>
    <label for="username">Kullanıcı Adı veya Email Adres</label>
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
    <label for="password">Şifre</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Şifreni kaybettin mi?</a>)
</p>
<p>
    This form will be replaced by an interactive editing window
    with your scanned map in the background for a guide.
</p>
