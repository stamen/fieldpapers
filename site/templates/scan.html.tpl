<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>{strip}
        {if $language == "de"}
            Gescannte Karte #{$scan.id|escape}
        {elseif $language == "nl"}
            WRITE ME
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
                    Gescannte Karte
                {elseif $language == "nl"}
                    WRITE ME
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
                    WRITE ME
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
					WRITE ME
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
                    WRITE ME
                    <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">LINK</a>

                {else}
                    Download a
                    <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">fresh map of this area from print #{$scan.print_id|escape}</a>.
                {/if}
            </p>
    
            <h2>{strip}
                {if $language == "de"}
                    Karte bearbeiten
                {elseif $language == "nl"}
                    WRITE ME
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
							{assign var="label" value="WRITE ME"}
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
						WRITE ME
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
							WRITE ME
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
						WRITE ME
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
							WRITE ME
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
								WRITE ME
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
							WRITE ME
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
