<p>
    Om Potlatch te kunnen gebruiken heb je een OpenStreetMap account
    nodig. <a href="http://www.openstreetmap.org/user/new">OpenStreetMap account aanmaken (gratis)</a>.
    <strong><i>Walking Papers</i> gebruikt je OpenStreetMap gegevens niet, </strong>je log in wordt door de OpenStreetMap server afgehandeld.
</p>
<p>
    <label for="username">E-mail adres of Gebruikersnaam</label>
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
    <label for="password">Wachtwoord</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Wachtwoord vergeten?</a>)
</p>
<p>
    Zodra het aanmelden bij de OpenStreetMap server is gelukt zal hier de potlatch editor verschijnen met de gescande afdruk als achtergrond.
</p>