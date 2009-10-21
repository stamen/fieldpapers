<p>
    Per poter fare qualsiasi modifica devi fare il login con il tuo
		account di OpenStreetMap; puoi farlo qui sotto oppure puoi  
    <a href="http://www.openstreetmap.org/user/new">creare un nuovo account</a>.
    <strong><i>Walking Papers</i> non conserverà né sarà mai a conoscenza della tua password</strong>,
    essa viene passata direttamante a OpenStreetMap.
</p>
<p>
    <label for="username">Indirizzo email o Nome utente</label>
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
		Questa form verrà sostituita da una finestra di editing interattiva
		dove la tua mappa scannerizzata sarà usata come sfondo per poterti essere da guida.
</p>
