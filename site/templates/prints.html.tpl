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
        <h2>New Atlases</h2>
        
        {foreach from=$prints item="print" name="index"}
            <div class="atlasThumb"> 
                <a href="{$base_dir}/print.php?id={$print.id}"><img src="{$print.preview_url}" alt="scanned page" 
                name="atlasPage" width="100%" id="atlasPage" /></a>
                <span class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">Untitled</a></span> 
                <span class="atlasOwner">by <a href="{$base_dir}/person.php?id={$print.user_id}">{$print.user_name}</a></span>, 
                in <span class="atlasPlace"><a href="{$base_dir}/atlases.php?place={$print.country_woeid}">Place</a></span>
                <span class="atlasMeta">on <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.created|date_format}</a></span>
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
