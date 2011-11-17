<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Recent Scans (Field Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/scans.css" type="text/css" />
    <link rel="data" type="application/json" href="{$base_dir}{$base_href}?type=json" />
    {if $link_prev}
        <link rel="Prev" href="{$link_prev|escape}" />
        <link rel="Start" href="{$link_start|escape}" />
    {/if}
    <link rel="Next" href="{$link_next|escape}" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>Recent Scans</h2>
    
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
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
