<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>{strip}
        {if $language == "de"}
            Eingescannte Karte #{$scan.id|escape}
        {elseif $language == "nl"}
            Gescande kaart #{$scan.id|escape}
        {elseif $language == "fr"}
            Carte scannée #{$scan.id|escape}
        {elseif $language == "ja"}
	    取り込んだ地図#{$scan.id|escape}
        {else}
            Scanned Map #{$scan.id|escape}
        {/if}
    {/strip} (Walking Papers)</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
	<link rel="stylesheet" href="{$base_dir}/scan.css" type="text/css" />
	{if $scan && $scan.last_step != 6 && $scan.last_step != $constants.STEP_FATAL_ERROR && $scan.last_step != $constants.STEP_FATAL_QRCODE_ERROR}
        <meta http-equiv="refresh" content="5" />
    {else}
        <script type="text/javascript" src="http://www.openstreetmap.org/javascripts/swfobject.js"></script>
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/script.js"></script>
        <script type="text/javascript" src="{$base_dir}/scan.js"></script>
    {/if}
</head>
<body>

    {if $scan && $scan.last_step == $constants.STEP_FINISHED}
        <span id="scan-info" style="display: none;">
            <span class="scan">{$scan.id|escape}</span>
            <span class="tile">http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/{literal}{z}/{x}/{y}{/literal}.jpg</span>
            <span class="minrow">{$scan.min_row|escape}</span>
            <span class="mincolumn">{$scan.min_column|escape}</span>
            <span class="minzoom">{$scan.min_zoom|escape}</span>
            <span class="maxrow">{$scan.max_row|escape}</span>
            <span class="maxcolumn">{$scan.max_column|escape}</span>
            <span class="maxzoom">{$scan.max_zoom|escape}</span>
        </span>
    
        <span id="print-info" style="display: none;">
            <span class="print">{$print.id|escape}</span>
            <span class="north">{$print.north|escape}</span>
            <span class="south">{$print.south|escape}</span>
            <span class="east">{$print.east|escape}</span>
            <span class="west">{$print.west|escape}</span>
        </span>
    {/if}

    {include file="navigation.htmlf.tpl"}
    
    {if $scan}
        {if $scan.last_step == $constants.STEP_FINISHED}
            <h2>{strip}
                {if $language == "de"}
                    Eingescannte Karte
                {elseif $language == "nl"}
                    Gescande kaart
                {elseif $language == "fr"}
                    Carte scannée
		{elseif $language == "ja"}
		    取り込んだ地図
                {else}
                    Scanned Map
                {/if}
            {/strip}</h2>
            
            {if $scan.description}
                <p style="font-style: italic;">
                    {$scan.description|escape}
                </p>
            {/if}
            
            <p>
                {if $language == "de"}
                    Umfasst diesen Bereich
                {elseif $language == "nl"}
                    Omvat het gebied rondom
                {elseif $language == "fr"}
                    Couvre la zone près de
		{elseif $language == "ja"}
		    近所をカバー
                {else}
                    Covers the area near
                {/if}

                {if $print.place_woeid}
                    <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                        {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
                    <br />
                    {$print.place_name|escape}
        
                {else}
                    <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                        {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
                {/if}
                <br/>
				{if $language == "de"}
					Hochgeladen {$scan.age|nice_relativetime|escape}.
				{elseif $language == "nl"}
					{$scan.age|nice_relativetime|escape} geupload.
				{elseif $language == "fr"}
					Envoyé le {$scan.age|nice_relativetime|escape}.
                                {elseif $language == "ja"}
                                        アップロード {$scan.age|nice_relativetime|escape}
				{else}
					Uploaded {$scan.age|nice_relativetime|escape}.
				{/if}
            </p>
            
            {if !$print.place_woeid}
                <script type="text/javascript" language="javascript1.2">
                // <![CDATA[
                
                    var onPlaces = new Function('res', "appendPlacename(res, document.getElementById('print-location'))");
                    var flickrKey = '{$constants.FLICKR_KEY|escape}';
                    var lat = {$print.latitude|escape};
                    var lon = {$print.longitude|escape};
                    
                    getPlacename(lat, lon, flickrKey, 'onPlaces');
            
                // ]]>
                </script>
            {/if}
        
            <p>
                <a href="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/large.jpg">
                    <img border="1" src="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/preview.jpg" /></a>
            </p>
        
            <p>
                {if $language == "de"}
                    Eine
                    <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">neue Version der Karte des Gebietes vom Ausdruck #{$scan.print_id|escape} herunterladen</a>.

                {elseif $language == "nl"}
                    Een
                    <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">nieuwe kaart van dit gebied</a> downloaden.
                {elseif $language == "fr"}
                    Télécharger <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">une carte récente de cette zone à partir de l'impression</a>.
		{elseif $language == "ja"}
		     <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">印刷された地図 #{$scan.print_id|escape} からこのエリアの最新地図</a>をダウンロードする
                {else}
                    Download a
                    <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">fresh map of this area from print #{$scan.print_id|escape}</a>.
                {/if}
            </p>
    
            <h2>{strip}
                {if $language == "de"}
                    Karte bearbeiten
                {elseif $language == "nl"}
                    Kaart bewerken
                {elseif $language == "fr"}
                    Modifier la carte
                {elseif $language == "ja"}
		    The Mapの編集
                {else}
                    Edit The Map
                {/if}
            {/strip}</h2>
    
            {include file="$language/scan-editor-info.htmlf.tpl"}
            
            <div id="editor">
                <form onsubmit="return editInPotlatch(this.elements);">

                    {include file="$language/scan-potlatch-info.htmlf.tpl"}

                    <p>
						{if $language == "de"}
							{assign var="label" value="Bearbeiten"}
						{elseif $language == "nl"}
						    {* nl: WRITE ME *}
							{assign var="label" value="Edit"}
						{elseif $language == "fr"}
							{assign var="label" value="Modifier"}
                                                {if $language == "ja"}
                                                        {assign var="label" value="編集"}
						{else}
							{assign var="label" value="Edit"}
						{/if}
					    <input class="mac-button" name="action" type="submit" value="{$label}" />
                        <input name="minrow" type="hidden" value="{$scan.min_row|escape}" />
                        <input name="mincolumn" type="hidden" value="{$scan.min_column|escape}" />
                        <input name="minzoom" type="hidden" value="{$scan.min_zoom|escape}" />
                        <input name="maxrow" type="hidden" value="{$scan.max_row|escape}" />
                        <input name="maxcolumn" type="hidden" value="{$scan.max_column|escape}" />
                        <input name="maxzoom" type="hidden" value="{$scan.max_zoom|escape}" />

                        <input name="bucket" type="hidden" value="{$constants.S3_BUCKET_ID|escape}" />
                        <input name="scan" type="hidden" value="{$scan.id|escape}" />
                    </p>
                </form>
            </div>
        {else}
            {if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
                <p>
                    {$step.number|step_description|escape}, giving up.
                </p>
                <p>
					{if $language == "de"}
						Versuche deinen Scan nocheinmal hochzuladen, achte auf eine
						angemessen hohe Auflösung (200+ dpi sind für ein ganzes Papier
						normal) und auf die richtige Seite. Ein leserlicher
						<a href="http://de.wikipedia.org/wiki/QR_Code">QR code</a> ist wichtig.
						Falls das nicht hilft, kannst du uns 
						<a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">kontaktieren</a>.
					{elseif $language == "nl"}
						Probeer eventueel opnieuw de scan te uploaden, zorg er daarbij voor
						dat de resolutie voldoende is (meer dan 200 dpi) en met de rechterzijde naar boven.
						Hierbij is het belangrijk dat de <a href="http://en.wikipedia.org/wiki/QR_Code">QR Code</a>
						goed leesbaar is. Wanneer dat niet helpt, 
						<a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">laat het ons weten</a>.
					{elseif $language == "fr"}
                        Vous devriez essayer d'envoyer à nouveau votre scan, en vous assurant qu'il est à une résolution assez grande 
                        (plus de 200 dpi pour une feuille entière) et le côté droit vers le haut. 
                        Un <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> bien lisible est nécessaire.
                        Si ça ne fonctionne toujours pas, <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">prévenez-nous</a>.
                                        {elseif $language == "ja"}
                                                あなたは、スキャナーしなおしてアップロードしようとすると思います。
                                                それが十分に高解像度であるか(すべてのシートに対して200DPI以上ですか）
                                                また、右が上になっているか、意識してください。最も重要な点は、
                                                <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a>が読めることです。
                                                もし、このアドバイスを守ってもうまくいかない場合は、
                                                <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">私たちにお知らせください</a>.
					{else}
						You might try uploading your scan again, making sure that
						it’s at a reasonably high resolution (200+ dpi for a full
						sheet of paper is normal) and right-side up. A legible 
						<a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> is critical.
						If this doesn’t help,
						<a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">let us know</a>.
					{/if}
                </p>
                
                {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
                    <p>
						{if $language == "de"}
							Dies ist der Teil deines Scans, in dem wir versuchten einen Code zu finden:
						{elseif $language == "nl"}
							Hier is een deel van de scan waarop ons systeem geprobeerd heeft de code te vinden:
						{elseif $language == "fr"}
							Voici la partie de votre scan où nous avons tenté de trouver un code :
						{else}
							Here’s the part of your scan where we tried to find a code:
						{/if}
                    </p>
                    <p>
                        <img width="65%" border="1" src="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/qrcode.jpg" />
                    </p>
                {/if}
                
            {else}
                <p>
					{if $language == "de"}
						Das gescannte Bild wird vearbeitet.
					{elseif $language == "nl"}
						De gescande afbeelding wordt verwerkt.
					{elseif $language == "fr"}
                        Traitement de votre image scannée.
					{else}
						Processing your scanned image.
					{/if}
                </p>
    
                <ol class="steps">
                    <li class="{if $step.number == 0}on{/if}">{0|step_description|escape}</li>
                    <li class="{if $step.number == 1}on{/if}">{1|step_description|escape}</li>
                    <li class="{if $step.number == 2}on{/if}">{2|step_description|escape}</li>
                    <li class="{if $step.number == 3}on{/if}">{3|step_description|escape}</li>
                    <li class="{if $step.number == 4}on{/if}">{4|step_description|escape}</li>
                    <li class="{if $step.number == 5}on{/if}">{5|step_description|escape}</li>
                    <li class="{if $step.number == 6}on{/if}">{6|step_description|escape}</li>
                </ol>
    
                {if $step.number >= 7}
                    <p>
                        {if $language == "de"}
							{$step.number|step_description|escape}, bitte warten.
							Wir versuchen deinen Scan bald zu verarbeiten.
						{elseif $language == "nl"}
							{$step.number|step_description|escape}, een ogenblik geduld alstublieft.
							We proberen de scan opnieuw te verwerken.
						{elseif $language == "fr"}
							{$step.number|step_description|escape}, merci de patienter.
							Nous allons essayer de traiter votre scan à nouveau dans peu de temps.
						{else}
							{$step.number|step_description|escape}, please stand by.
							We will try to process your scan again shortly.
						{/if}
                    </p>
                    
                    {if $step.number == $constants.STEP_BAD_QRCODE}
                        <p>
                            {if $language == "de"}
								Dies ist der Teil deines Scans, in dem wir versuchten einen Code zu finden:
							{elseif $language == "nl"}
								Hier is het deel van de scan waarop ons systeem geprobeerd heeft de code te vinden:
							{elseif $language == "fr"}
								Voici la partie de votre scan où nous avons tenté de trouver un code :
							{else}
								Here’s the part of your scan where we tried to find a code:
							{/if}
                        </p>
                        <p>
                            <img width="65%" border="1" src="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/qrcode.jpg" />
                        </p>
                    {/if}
                    
                {else}
                    <p>
						{if $language == "de"}
							Dies kann einige Minuten dauern.
							Du musst das Browserfenster nicht geöffnet halten.
							Setze ein Lesezeichen für diese <a href="{$base_dir}/scan.php?id={$scan.id|escape}">Seite</a>
							und schaue später nocheinmal vorbei.
						{elseif $language == "nl"}
							Het kan even duren, meestal een paar minuten.
							Het is niet nodig deze pagina open te houden, je kunt ook een 
							<a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark</a> van deze pagina
							maken en later terugkomen.
						{elseif $language == "fr"}
                            Ça peut prendre un peu de temps, en général quelques minutes.
                            Vous n'êtes pas obligé de laisser la fenêtre de votre navigateur ouverte.
                            Vous pouvez ajouter <a href="{$base_dir}/scan.php?id={$scan.id|escape}">cette page</a>
                            à vos favoris, et revenir plus tard.
						{else}
							This may take a little while, generally a few minutes.
							You don’t need to keep this browser window open—you can
							<a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark this page</a>
							and come back later.
						{/if}
                    </p>
                {/if}
            {/if}
        {/if}
    {/if}
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
