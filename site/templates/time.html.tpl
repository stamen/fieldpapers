<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Time - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
    <script type="text/javascript" src="{$base_dir}/index.js"></script>
    <script>

    </script>
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            <h1>{$date.month}, {$date.year}</h1>
            
            <p><img src="" alt="map selection area" name="map" width="100%" height="600" 
            id="map" style="background-image:url(big-satellite-placeholder.jpg); 
            background-position:center" /></p>
            
            {foreach from=$prints item="print" name="index"}
                <div class="atlasThumb"> 
                    <a href="page.html"><img src="{$print.preview_url}" alt="printed page" 
                    name="atlasPage" width="180" height="240" id="atlasPage" style="background-color: #000" /></a>
                    <div class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">{$print.id}</a></div>
                    <div class="atlasOwner">by <a href="{$base_dir}/person.php?id={$print.user_id}">{$print.user_name}</a></div>
                    <div class="atlasPlace"><a href="place.html">Place</a></div>
                    <div class="atlasMeta">X pages, from <a href="time.php?date={$print.created}">{$print.created|date_format}</a></div>
                </div>
            {/foreach}
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
    <!-- end .container --></div>
</body>
</html>