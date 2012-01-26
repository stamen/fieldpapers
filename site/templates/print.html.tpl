<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Print #{$print.id|escape} (Field Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    {if $print.page}
        <link rel="data" type="application/paperwalking+xml" href="{$base_dir}{$base_href}?id={$print.id|escape}/{$print.page.page_number|escape}&amp;type=xml" />
    {else}
        <link rel="data" type="application/paperwalking+xml" href="{$base_dir}{$base_href}?id={$print.id|escape}&amp;type=xml" />
    {/if}
    {if $print && !$print.composed}
        <meta http-equiv="refresh" content="5" />
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/script.js"></script>
    {/if}
</head>
<body>

    <span id="print-info" style="display: none;">
        {if $print.page}
            <span class="print">{$print.id|escape}/{$print.page.page_number|escape}</span>
            <span class="north">{$print.page.north|escape}</span>
            <span class="south">{$print.page.south|escape}</span>
            <span class="east">{$print.page.east|escape}</span>
            <span class="west">{$print.page.west|escape}</span>
        {else}
            <span class="print">{$print.id|escape}</span>
            <span class="north">{$print.north|escape}</span>
            <span class="south">{$print.south|escape}</span>
            <span class="east">{$print.east|escape}</span>
            <span class="west">{$print.west|escape}</span>
        {/if}
        <span class="paper-size">{$print.paper_size|escape}</span>
        <span class="orientation">{$print.orientation|escape}</span>
    </span>

    {include file="header.htmlf.tpl"}
    
    {include file="navigation.htmlf.tpl"}
    
    {if $print}
        {if $print.composed}

            {include file="$language/print-info.htmlf.tpl"}
        
            {if $print.zoom && !$print.geotiff_url}
                <form action="{$base_dir}/compose-print-old.php" method="post" name="bounds">
                    <p>
                        <input name="north" type="hidden" value="{$print.north|escape}" />
                        <input name="south" type="hidden" value="{$print.south|escape}" />
                        <input name="east" type="hidden" value="{$print.east|escape}" />
                        <input name="west" type="hidden" value="{$print.west|escape}" />
                        <input name="zoom" type="hidden" value="{$print.zoom|escape}" />
                        <input name="paper" type="hidden" value="{$print.orientation|escape}-{$print.paper_size|escape}" />
                        <input name="provider" type="hidden" value="{$print.provider|escape}" />
                        <input name="layout" type="hidden" value="{$print.layout|escape}" />
                
                        Is this map wrong, or out of date?
                        
                        <input class="mac-button" type="submit" name="action" value="Redo" />
                        <input type="hidden" name="source" value="bounds" />
                    </p>
                </form>
            {/if}
            
            <div class="sheet {$print.paper_size|escape} {$print.orientation|escape}">
                {if $print.page}
                    <img src="{$print.page.preview_url|escape}"/>
                {else}
                    <img src="{$print.preview_url|escape}"/>
                {/if}
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
                var lat = {$print.latitude|escape};
                var lon = {$print.longitude|escape};
                
                {if !$print.place_woeid}getPlacename(lat, lon, flickrKey, 'onPlaces');{/if}
                makeStaticMap('mini-map', lat, lon);
        
            // ]]>
            </script>
        
            {include file="$language/print-mail-info.htmlf.tpl"}
        {else}

            {* include file="$language/print-process-info.htmlf.tpl" *}
            <p>Preparing your print.</p>

            <p>
                This may take a little while, generally a few minutes.
                You don’t need to keep this browser window open—you can
                <a href="{$base_dir}/print.php?id={$print.id|escape}">bookmark this page</a>
                and come back later.
            </p>

        {/if}
    {/if}

    {include file="footer.htmlf.tpl"}
    
</body>
</html>
