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
        {elseif $language == "tr"}
            Son Taramalar
        {elseif $language == "ru"}
            Недавние сканы
        {elseif $language == "sv"}
            Senast inskannat
        {else}
            Recent Scans
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/scans.css" type="text/css" />
    <link rel="data" type="application/json" href="{$base_dir}{$base_href}?type=json" />
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
        {elseif $language == "tr"}
            Son Taramalar
        {elseif $language == "ru"}
            Недавние сканы
        {elseif $language == "sv"}
            Senaste inskanningarna
        {else}
            Recent Scans
        {/if}
    {/strip}</h2>
    
    {assign var="scans_count" value=$scans|@count}
    
    {if $page > 1 and $scans_count > 0}
        <p class="pagination">
            <span class="newer">← <a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            <span class="older"><a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        </p>
    {/if}
    
    {include file="scans-table.htmlf.tpl"}
    
    <p class="pagination">
        {if $scans_count > 0}
            {if $page > 1}
                <span class="newer">← <a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            {/if}
            <span class="older"><a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        {else}
            <span class="newer">← <a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page=1">Newest</a></span>
        {/if}
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
