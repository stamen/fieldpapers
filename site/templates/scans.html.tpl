<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Recent Scans - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <link rel="data" type="application/json" href="{$base_dir}{$base_href}?type=json" />
    {if $link_prev}
        <link rel="Prev" href="{$link_prev|escape}" />
        <link rel="Start" href="{$link_start|escape}" />
    {/if}
    <link rel="Next" href="{$link_next|escape}" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>
    {include file="header.htmlf.tpl"}

    {include file="navigation.htmlf.tpl"}
    
    <p><img src="" alt="map selection area" name="map" width="100%" height="600" 
    id="map" style="background-image:url(big-satellite-placeholder.jpg); 
    background-position:center" /></p>
    
    <h2>Recent Scans</h2>
    
    {foreach from=$scans item="scan" name="index"}
        <div class="atlasThumb"> 
            <a href="scan.php?id={$scan.id}"><img src="{$scan.base_url}/preview.jpg" alt="scanned page" 
            name="atlasPage" width="180" height="240" id="atlasPage" style="background-color: #000" /></a>
            <div class="atlasName"><a href="{$base_dir}/scan.php?id={$scan.id}">{$print.id}</a></div>
            <div class="atlasOwner">by <a href="person.html">{$scan.user_id}</a></div>
            <div class="atlasPlace"><a href="place.html">Place</a></div>
            <div class="atlasMeta">X pages, from <a href="time.php?date={$scan.created}">{$scan.created|date_format}</a></div>
        </div>
    {/foreach}
    
    <!--
    {assign var="scans_count" value=$scans|@count}
    
    {if $link_prev and $link_next}
        <p class="pagination">
            <span class="newer">← <a href="{$link_prev|escape}">Newer</a></span>
            <span class="older"><a href="{$link_next|escape}">Older</a> →</span>
        </p>
    {/if}
    
    {include file="scans-table.htmlf.tpl"}
    
    <p class="pagination">
        {if $scans_count > 0}
            {if $link_prev}
                <span class="newer">← <a href="{$link_prev|escape}">Newer</a></span>
            {/if}
            <span class="older"><a href="{$link_next|escape}">Older</a> →</span>
        {else}
            <span class="newer">← <a href="{$link_start|escape}">Newest</a></span>
        {/if}
    </p>
    -->
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
