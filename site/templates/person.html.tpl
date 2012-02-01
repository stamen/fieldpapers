<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Person - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />    
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            <h1>{$user_id}</h1>
            
            <p>
                Email address
            </p>
            <div class="print" id="map"></div>
            <div class="fltlft">
                <h2>Number of Atlases</h2>
            
                {foreach from=$prints item="print" name="index"}
                    <div class="atlasPage"> 
                        <a href="page.html"><img src="{$print.preview_url}" alt="printed page" 
                        name="atlasPage" width="180" height="240" id="atlasPage" style="background-color: #000" /></a>
                        
                        <div class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">{$print.id}</a></div>
                        <div class="atlasPlace"><a href="place.html">Place</a></div>
                        <div class="atlasMeta">X pages, from <a href="time.php?date={$print.created}">{$print.created|date_format}</a></div>
                    </div>
                {/foreach}
            </div>
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
        
    <!-- end .container --></div>
</body>
</html>