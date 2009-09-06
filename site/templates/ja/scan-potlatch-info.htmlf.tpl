<p>
    You’ll need to log in with your OpenStreetMap account
    to do any editing; do that below or
    <a href="http://www.openstreetmap.org/user/new">create a new account</a>.
    <strong><i>Walking Papers</i> will not see or keep your password</strong>,
    it is passed directly to OpenStreetMap.
</p>
<p>
    <label for="username">Email Address or Username</label>
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
    <label for="password">Password</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Lost your password?</a>)
</p>
<p>
    This form will be replaced by an interactive editing window
    with your scanned map in the background for a guide.
</p>
