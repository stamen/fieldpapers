<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Home - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
    <script type="text/javascript" src="{$base_dir}/index.js"></script>
    
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript" src="{$base_dir}/map.js"></script>
    <script>
        {literal}
        $(document).ready(function() {
            initMap('{/literal}{$providers}{literal}');
        });
        {/literal}
    </script>
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            {include file="title.htmlf.tpl"}
            
            {include file="hotspots.htmlf.tpl"}
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
    <!-- end .container --></div>
</body>
</html>