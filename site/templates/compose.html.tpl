<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Zusammenstellen
        {elseif $language == "nl"}
            Samenstellen
        {elseif $language == "es"}
            Componer
        {elseif $language == "fr"}
            Composer
        {elseif $language == "ja"}
            作成
        {elseif $language == "it"}
            Compositore
        {else}
            Componer
        {/if}
    {/strip} (Walking Papers)</title>
</head>
<body>

    <img src="{$url|escape}" width="{$width|escape}" height="{$height|escape}" border="1" />
    
</body>
</html>
