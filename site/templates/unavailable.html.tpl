<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Site Unavailable
        {elseif $language == "nl"}
            Site Unavailable
        {elseif $language == "es"}
            Site Unavailable
        {elseif $language == "fr"}
            Site Unavailable
        {elseif $language == "ja"}
            Site Unavailable
        {elseif $language == "it"}
            Site Unavailable
        {elseif $language == "tr"}
            Site Unavailable
        {elseif $language == "ru"}
            Site Unavailable
        {elseif $language == "sv"}
            Site Unavailable
        {elseif $language == "id"}
						Situs Tidak Tersedia
        {else}
            Site Unavailable
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>Site Unavailable</h2>
    
    <p>
        Walking Papers is currently unavailable. Please try back in a few minutes!
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
