<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Atlas - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">    
    {if $print && !$print.composed}
        <meta http-equiv="refresh" content="5">
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/polygonmarker-canvas.js"></script>
    {/if}
</head>
<body onload="loadMaps()">
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        {include file="print.htmlf.tpl"}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>