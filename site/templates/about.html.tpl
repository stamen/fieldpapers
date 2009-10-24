<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Über
        {elseif $language == "nl"}
            Over
        {elseif $language == "es"}
            Acerca de    
        {elseif $language == "fr"}
            À propos
          {elseif $language == "ja"}
            情報
        {elseif $language == "it"}
            Di cosa si tratta  
        {else}
            About
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/index.css" type="text/css" />
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    {include file="$language/about.htmlf.tpl"}

    {include file="footer.htmlf.tpl"}
    
</body>
</html>
