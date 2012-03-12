<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>New Atlases - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h2>Atlases | <a href="{$base_dir}/scans.php">Uploads</a></h2>
        
        {foreach from=$prints item="print"}
            <div class="atlasThumb"> 
                <a href="{$base_dir}/print.php?id={$print.id}"><img src="{$print.preview_url}" alt="scanned page" 
                name="atlasPage" width="100%" id="atlasPage" /></a>
                <span class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">Untitled</a></span> 
                <span class="atlasOwner">by <a href="{$base_dir}/person.php?id={$print.user_id}">{$print.user_name}</a></span> in
                {if $print.city_name && $print.country_name}
                    <span class="atlasPlace">
                    <a href="{$base_dir}/place.php?place_id={$print.place_woeid}">
                    {$print.city_name}</a>, 
                    <span class="atlasPlace"><a href="{$base_dir}/place.php?country_id={$print.country_woeid}">
                    {$print.country_name}</a>
                {else}
                    Unknown Place
                {/if}
                </a></span>
                <span class="atlasMeta">on <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.created|date_format}</a>,
                {$print.page_count}
                {if $print.page_count == 1}
                    Page
                {else}
                    Pages
                {/if}</span>
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
