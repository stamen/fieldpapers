<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Recent Prints - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>
    {include file="header.htmlf.tpl"}

    {include file="navigation.htmlf.tpl"}
    
    <h2>Recent Prints</h2>
    
    {foreach from=$prints item="print" name="index"}
        <div class="atlasThumb"> 
            <a href="print.php?id={$print.id}"><img src="{$print.preview_url}" alt="scanned page" 
            name="atlasPage" width="180" height="240" id="atlasPage" style="background-color: #000" /></a>
            <div class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">{$print.id}</a></div>
            <div class="atlasOwner">by <a href="person.php?id={$print.user_id}">{$print.user_name}</a></div>
            <div class="atlasPlace"><a href="place.html">Place</a></div>
            <div class="atlasMeta">From <a href="time.php?date={$print.created}">{$print.created|date_format}</a></div>
        </div>
    {/foreach}
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
