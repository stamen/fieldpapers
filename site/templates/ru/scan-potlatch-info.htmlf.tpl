<p>
    Вам нужно будет зайти под своей учетной записью OpenStreetMap 
    чтбы начать редактирование; вы можете войти используя форму ниже или 
    <a href="http://www.openstreetmap.org/user/new">создайте новую учетную запись</a>.
    <strong><i>Обходной лист</i> не увидит и не будет хранить ваш пароль</strong>,
    он передается напрямую в OpenStreetMap.
</p>
<p>
    <label for="username">Адрес электронной почты или имя пользователя</label>
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
    <label for="password">Пароль</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Потеряли пароль?</a>)
</p>
<p>
    Эта форма заменится окном редактора 
    с вашей отсканированной картой с подложкой.
</p>
