<p>
    Necesitas entrar con tu cuenta de OpenStreetMap para hacer modificaciones; hazlo aquí debajo o
    
    <a href="http://www.openstreetmap.org/user/new">crea una nueva cuenta</a>.
    <strong><i>Walking Papers</i> no tendrá acceso o guardará tu contraseña</strong>,
    ésta es pasada directamente a OpenStreetMap.
</p>
<p>
    <label for="username">Email o nombre de usuario</label>
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
    <label for="password">Contraseña</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">¿Has perdido tu contraseña?</a>)
</p>


<p>
  Este formulario se reemplazará por una ventana de edición interactiva con tu mapa escaneado como fondo para servir de guía.
</p>