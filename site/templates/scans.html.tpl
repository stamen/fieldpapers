<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Zuletzt gescannt
        {elseif $language == "nl"}
            Recente scans
        {elseif $language == "es"}
            Últimos scans    
        {elseif $language == "fr"}
            Scans récents
        {elseif $language == "ja"}
            最近の取込データ
        {elseif $language == "it"}
            Scansioni recenti
        {else}
            Recent Scans
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>{strip}
        {if $language == "de"}
            Zuletzt gescannt
        {elseif $language == "nl"}
            Recente scans
        {elseif $language == "es"}
          Últimos scans
        {elseif $language == "fr"}
            Scans récents
        {elseif $language == "ja"}
            最近の取込データ
        {elseif $language == "it"}
            Scansioni recenti
        {else}
            Recent Scans
        {/if}
    {/strip}</h2>
    
    <ol>
        {foreach from=$scans item="scan"}
            <li>
                {if $scan.print_place_woeid}
                    <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                        <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                            {if $scan.will_edit == 'no'}✻{/if}</b>
                        <br />
                        {$scan.print_place_name|escape}</a>

                {else}
                    <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                        <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                            {if $scan.will_edit == 'no'}✻{/if}</b></a>
    
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                    
                        var onPlaces_{$scan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$scan.id|escape}'))");
                        getPlacename({$scan.print_latitude|escape}, {$scan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$scan.id|escape}');
                
                    // ]]>
                    </script>
                {/if}

                {if $scan.description}
                    <br />
                    {$scan.description|escape}
                {/if}
            </li>
        {/foreach}
    </ol>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
