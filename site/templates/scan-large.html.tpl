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
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
    <script type="text/javascript" src="{$base_dir}/scan.js"></script>
    
    {if $scan.has_geojpeg == 'yes'}
        {* See templates/scan-large-notes.htmlf.tpl *}

        <link rel="stylesheet" href="{$base_dir}/scan-large.css" type="text/css" />
        <script type="text/javascript" src="http://yui.yahooapis.com/combo?3.3.0/build/yui/yui-min.js&3.3.0/build/oop/oop-min.js&3.3.0/build/dom/dom-base-min.js&3.3.0/build/dom/selector-native-min.js&3.3.0/build/dom/selector-css2-min.js&3.3.0/build/event-custom/event-custom-min.js&3.3.0/build/event/event-base-min.js&3.3.0/build/pluginhost/pluginhost-min.js&3.3.0/build/dom/dom-style-min.js&3.3.0/build/dom/dom-style-ie-min.js&3.3.0/build/dom/dom-screen-min.js&3.3.0/build/node/node-min.js&3.3.0/build/event/event-base-ie-min.js&3.3.0/build/event/event-delegate-min.js&3.3.0/build/attribute/attribute-base-min.js&3.3.0/build/base/base-min.js&3.3.0/build/classnamemanager/classnamemanager-min.js&3.3.0/build/dd/dd-ddm-base-min.js&3.3.0/build/dd/dd-drag-min.js&3.3.0/build/dd/dd-gestures-min.js&3.3.0/build/dd/dd-constrain-min.js"></script>
        <script type="text/javascript" src="{$base_dir}/scan-large.js"></script>

        <script type="text/javascript">
        // <![CDATA[{literal}
        
            window.onload = function()
            {
                YUI().use('dd-constrain', setup_dragboxes);
            };
        
        // {/literal}]]>
        </script>
    {/if}
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    {if $scan}
        {if $scan.last_step == $constants.STEP_FINISHED}
            {include file="$language/scan-large-info.htmlf.tpl"}
        {/if}
    {/if}
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
