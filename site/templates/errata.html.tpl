<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Fehlerverzeichnis
        {elseif $language == "nl"}
            Foutenlijst
        {elseif $language == "es"}
            Fe de erratas    
        {elseif $language == "fr"}
            Erreurs
        {elseif $language == "ja"}
            訂正
        {else}
            Errata
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>
        {if $language == "de"}
            Fehlerverzeichnis
        {elseif $language == "nl"}
            Foutenlijst
        {elseif $language == "es"}
            Fe de erratas
        {elseif $language == "fr"}
            Erreurs
        {else}
            Errata
        {/if}
    </h2>
    
    <p>
        {if $language == "de"}
            
        {elseif $language == "nl"}
            I have been informed that “Errata” does not mean what I thought it meant:
            <i><a href="http://dictionary.reference.com/search?q=errata">Errata</a> -
            a list of errors and their corrections inserted, usually on a separate
            page or slip of paper, in a book or other publication.</i>
        {elseif $language = "ja"}
            "訂正"ページを提供しているけれども、間違いとその訂正が一覧になっている本などによく入っている、いわゆる正誤表とはちがいます。 
        {else}
            I have been informed that “Errata” does not mean what I thought it meant:
            <i><a href="http://dictionary.reference.com/search?q=errata">Errata</a> -
            a list of errors and their corrections inserted, usually on a separate
            page or slip of paper, in a book or other publication.</i>
    </p>
   
    <p>
        {if $language == "de"}
            Diese Seite wurde zu <a href="{$base_dir}/zeitgeist.php">Statistik</a> verschoben.
        {if $language == "es"}
            Esta página se ha trasladado a <a href="{$base_dir}/zeitgeist.php">Estadísticas</a>.      
        {elseif $language == "nl"}
            I thought it was more like a list of random, “erratic” stuff that didn’t fit anyplace else.
            So, this page has <a href="{$base_dir}/zeitgeist.php">moved to “zeitgeist”</a>.
        {elseif $language == "ja"}
            このページは、<a href="{$base_dir}/zeitgeist.php">moved to “zeitgeist”</a>に移動しました。
        {else}
            I thought it was more like a list of random, “erratic” stuff that didn’t fit anyplace else.
            So, this page has <a href="{$base_dir}/zeitgeist.php">moved to “zeitgeist”</a>.
        {/if}
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
