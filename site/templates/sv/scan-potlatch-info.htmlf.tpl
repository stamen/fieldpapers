<p>
    Du måste logga in med ditt OpenStreetMap-konto för att kunna 
    redigera något; Logga in nedan eller 
    <a href="http://www.openstreetmap.org/user/new">skapa ett nytt konto</a>.
    <strong><em>Walking Papers</em> kommer inte att få reda på eller lagra
    ditt lösenord</strong>, utan det skickas direkt till OpenStreetMap.
</p>
<p>
    {* I don't know if my browser is wrong about this, but it does only act
       correctly if label attribute "for" equals to the id of the input
       field (Ie. Input is selected when label text is clicked).
       
       Browser is Google Chrome, Placeholders are nice too --Frank M. E. *}
    <label for="username-textfield">E-postadress eller Användarnamn</label>
    <br />
    <input id="username-textfield" name="username" type="text" size="30"
    placeholder="Logintoken" />
</p>
<script type="text/javascript">
// <![CDATA[{literal}

    if(readCookie('openstreetmap-username') && document.getElementById('username-textfield'))
        document.getElementById('username-textfield').value = readCookie('openstreetmap-username');

// {/literal}]]>
</script>
<p>
    <label for="password">Lösenord</label>
    <br />
    <input id="password" name="password" type="password" size="30" 
    placeholder="Lösenord" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Glömt ditt lösenord?</a>)
</p>
<p>
    Detta loginformulär kommer att ersättas med en interaktiv 
    kartredigerare med din inskannade karta som underlag.
</p>
