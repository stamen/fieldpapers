<p>
    Vous aurez besoin de vous identifier avec votre compte OpenStreetMap
    pour éditer quoi que ce soit ; faites ça en dessous ou bien
    <a href="http://www.openstreetmap.org/user/new">créer un nouveau compte</a>.
    <strong><i>Walking Papers</i> ne va pas voir ou garder votre mot de passe</strong>,
    il est directement envoyé à OpenStreetMap.
</p>
<p>
    <label for="username">Adresse électronique ou nom d'utilsiateur</label>
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
    <label for="password">Mot de passe</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Mot de passe perdu ?</a>)
</p>
<p>
    Ce formulaire sera remplacé par une fenêtre d'édition interactive avec votre carte scannée en image de fond en tant que guide.
</p>
