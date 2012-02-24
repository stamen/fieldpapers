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
    {include file="navigation.htmlf.tpl"}
    
    <div class="container">    
    <h2><a href="{$base_dir}/watch.php">Atlases</a> | Uploads</h2>
    
        {foreach from=$scans item="scan" name="index"}
            <div class="atlasThumb"> 
                <a href="{$base_dir}/scan.php?id={$scan.id}"><img src="{$scan.base_url}/preview.jpg" alt="scanned page" 
                name="atlasPage" width="100%" id="atlasPage" /></a>
                Page x of Y Atlas, 
                uploaded by <a href="{$base_dir}/person.php?id={$scan.user_id}">{$scan.user_name}</a>,
                <a href="{$base_dir}/time.php?date={$scan.created}">{$scan.age|nice_relativetime|escape}</a>
                
<!--                <span class="atlasName"><a href="{$base_dir}/scan.php?id={$scan.id}">{$print.id}</a></span>
                <span class="atlasOwner">by <a href="{$base_dir}/person.php?id={$scan.user_id}">{$scan.user_name}</a></span>
                <span class="atlasPlace"><a href="{$base_dir}/place.php">Place</a></span>
                <span class="atlasMeta">uploaded <a href="{$base_dir}/time.php?date={$scan.created}">{$scan.age|nice_relativetime|escape}</a></span>
 -->
             </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
