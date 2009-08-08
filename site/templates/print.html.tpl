<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>{strip}
        {if $language == "de"}
            Drucken #{$print.id|escape}
        {elseif $language == "nl"}
            WRITE ME
        {else}
            Print #{$print.id|escape}
        {/if}
    {/strip} (Walking Papers)</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    <span id="print-info" style="display: none;">
        <span class="print">{$print.id|escape}</span>
        <span class="north">{$print.north|escape}</span>
        <span class="south">{$print.south|escape}</span>
        <span class="east">{$print.east|escape}</span>
        <span class="west">{$print.west|escape}</span>
    </span>

    {include file="navigation.htmlf.tpl"}
    
    <h2>{strip}
        {if $language == "de"}
            Karte drucken
        {elseif $language == "nl"}
            WRITE ME
        {else}
            Print Map
        {/if}
    {/strip}</h2>
    
    {include file="$language/print-top-paragraph.htmlf.tpl"}

    {if $print.zoom}
        <form action="{$base_dir}/compose.php" method="post" name="bounds">
            <p>
                <input name="north" type="hidden" value="{$print.north|escape}" />
                <input name="south" type="hidden" value="{$print.south|escape}" />
                <input name="east" type="hidden" value="{$print.east|escape}" />
                <input name="west" type="hidden" value="{$print.west|escape}" />
                <input name="zoom" type="hidden" value="{$print.zoom|escape}" />
        
                {if $language == "de"}
                    Ist diese Karte falsch oder veraltet?
                {elseif $language == "nl"}
                    WRITE ME
                {else}
                    Is this map wrong, or out of date?
                {/if}
				
				{if $language == "de"}
					{assign var="label" value="Aktualisieren"}
				{elseif $language == "nl"}
					{assign var="label" value="WRITE ME"}
				{else}
					{assign var="label" value="Redo"}
				{/if}
                <input class="mac-button" type="submit" name="action" value="{$label}" />
            </p>
        </form>
    {/if}
    
    <div class="sheet {$print.orientation|escape}">
        <img src="{$print.preview_url|escape}"/>
        <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div>
        <div class="dog-ear"> </div>
    </div>
    
    <p id="mini-map">
        <img class="doc" src="{$base_dir}/c-thru-doc.png" />
    </p>
    
    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[
    
        var onPlaces = new Function('res', "appendPlacename(res, document.getElementById('print-location'))");
        var flickrKey = '{$constants.FLICKR_KEY|escape}';
        var cloudmadeKey = '{$constants.CLOUDMADE_KEY|escape}';
        var lat = {$print.latitude|escape};
        var lon = {$print.longitude|escape};
        
        {if !$print.place_woeid}getPlacename(lat, lon, flickrKey, 'onPlaces');{/if}
        makeStaticMap('mini-map', lat, lon, cloudmadeKey);

    // ]]>
    </script>

    {include file="$language/print-bottom-paragraph.htmlf.tpl"}

    {include file="footer.htmlf.tpl"}
    
</body>
</html>
