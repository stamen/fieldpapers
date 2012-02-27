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
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h1>{$user_name}</h1>
        
        {if $user_email}
            <p>
                {$user_email}
            </p>
        {/if}
        <div class="fltlft">
            <h2>
                <a href="{$base_dir}/person.php?id={$user_id}">Atlases</a> | 
                {if $scans|@count == 1}
                    1 Upload
                {else if $scans|@count >= 1}
                    {$scans|@count} Uploads
                {/if}
            </h2>
            {foreach from=$scans item="scan"}
                <div class="atlasThumb"> 
                    <a href="scan.php?id={$scan.id}"><img src="{$scan.base_url}/preview.jpg" alt="scan page" 
                    name="atlasPage" width="100%" id="atlasPage" /></a>
                    
                    <div class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">Untitled</a></div>
                    <div class="atlasPlace"><a href="place.php">Place</a></div>
                    <div class="atlasMeta">
                    Created<a href="time.php?date={$print.created}">{$scan.age|nice_relativetime|escape}</a></div>
                </div>
            {/foreach}
        </div>
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>