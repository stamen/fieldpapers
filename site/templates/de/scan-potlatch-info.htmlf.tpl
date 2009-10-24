<p>
    Zuerst musst du dich mit deinem OpenStreetMap Benutzerkonto einloggen, um zu editieren; logge dich unten ein oder 
    <a href="http://www.openstreetmap.org/user/new">erstelle ein neues Account</a>.
    <strong><i>Walking Papers</i> wird dein Passwort nicht sehen bzw. speichern</strong>,
    es wird direkt zu OpenStreetMap weitergeleitet.
</p>
<p>
    <label for="username">E-Mail-Adresse oder Benutzername</label>
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
    <label for="password">Passwort</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Passwort vergessen?</a>)
</p>
<p>
    Dieses Eingabefeld wird anschließend durch ein interaktives Bearbeitungsfenster
    mit deiner eingescannten Karte als Hintergrund zur Orientierung ersetzt.
</p>
