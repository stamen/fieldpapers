<p>

編集を行うためには、 オープンストリートマップのアカウントをとってログインする必要があります。   
以下に進んでログインするか、
    <a href="http://www.openstreetmap.org/user/new">新規アカウントを作成してください</a>.
    <strong><i>ウォーキングペーパー（Walking Papers）</i>には、パスワードが表示されたり、保存されることはありません</strong>ので、
直接OpenStreetMapに渡すことができます。</p>
<p>
    <label for="username">電子メールアドレスまたはユーザ名</label>
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
    <label for="password">パスワード</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">パスワードを忘れましたか？</a>)
</p>
<p>
    このフォームは、あなたのスキャンした地図をガイドとして、背景に表示される編集画面に変わります。
</p>
