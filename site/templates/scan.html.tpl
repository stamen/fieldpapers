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
        {elseif $language == "es"}
            Mapa escaneado #{$scan.id|escape}
        {elseif $language == "fr"}
            Carte scannée #{$scan.id|escape}
        {elseif $language == "ja"}
            取り込んだ地図#{$scan.id|escape}
        {elseif $language == "it"}
            Mappa scansionata #{$scan.id|escape}
        {elseif $language == "tr"}
            #{$scan.id|escape} Taramış Harita
        {elseif $language == "ru"}
            Отсканированная карта #{$scan.id|escape}
        {elseif $language == "sv"}
            Skannad Karta #{$scan.id|escape}
        {else}
            Scanned Map #{$scan.id|escape}
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/scan.css" type="text/css" />
    <link rel="data" type="application/xml" href="{$base_dir}{$base_href}?id={$scan.id|escape:"url"}&amp;type=xml" />
    <link rel="data" type="application/json" href="{$base_dir}{$base_href}?id={$scan.id|escape:"url"}&amp;type=json" />
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
            <span class="tile">{$scan.base_url}/{$scan.id|escape}/{literal}{z}/{x}/{y}{/literal}.jpg</span>
            <span class="minrow">{$scan.min_row|escape}</span>
            <span class="mincolumn">{$scan.min_column|escape}</span>
            <span class="minzoom">{$scan.min_zoom|escape}</span>
            <span class="maxrow">{$scan.max_row|escape}</span>
            <span class="maxcolumn">{$scan.max_column|escape}</span>
            <span class="maxzoom">{$scan.max_zoom|escape}</span>
            {if $scan.description}<span class="description">{$scan.description|escape}</span>{/if}
        </span>
    
        <span id="print-info" style="display: none;">
            {if $print.atlas_page}
                <span class="print">{$print.id|escape}/{$print.atlas_page.part|escape}</span>
                <span class="north">{$print.atlas_page.bounds.north|escape}</span>
                <span class="south">{$print.atlas_page.bounds.south|escape}</span>
                <span class="east">{$print.atlas_page.bounds.east|escape}</span>
                <span class="west">{$print.atlas_page.bounds.west|escape}</span>
            {else}
                <span class="print">{$print.id|escape}</span>
                <span class="north">{$print.north|escape}</span>
                <span class="south">{$print.south|escape}</span>
                <span class="east">{$print.east|escape}</span>
                <span class="west">{$print.west|escape}</span>
            {/if}
        </span>
    {/if}

    {include file="navigation.htmlf.tpl"}
    
    {if $scan}
        {if $scan.last_step == $constants.STEP_FINISHED}

            {include file="$language/scan-info.htmlf.tpl"}
            
            <ul>
                {if $scan.has_geotiff == "yes"}
                    <li>GeoTIFF: <a href="{$scan.base_url|escape}/walking-paper-{$scan.id|escape}.tif">walking-paper-{$scan.id|escape}.tif</a></li>
                {/if}
                {if $scan.has_stickers == "yes"}
                    <li>Stickers: <a href="{$scan.base_url|escape}/stickers.csv">stickers.csv</a></li>
                {/if}
            </ul>
            
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
                        {elseif $language == "es"}
                            {assign var="label" value="Editar"}
                        {elseif $language == "fr"}
                            {assign var="label" value="Modifier"}
                        {elseif $language == "ja"}
                            {assign var="label" value="編集"}
                        {elseif $language == "it"}
                            {assign var="label" value="Modifica"}
                        {elseif $language == "tr"}
                            {assign var="label" value="Değiştir"}
                        {elseif $language == "ru"}
                            {assign var="label" value="Редактировать"}
                        {elseif $language == "sv"}
                            {assign var="label" value="Redigera"}
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
                        <input name="base_url" type="hidden" value="{$scan.base_url|escape}" />
                    </p>
                </form>
            </div>
        {else}

            {include file="$language/scan-process-info.htmlf.tpl"}

        {/if}
    {/if}
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
