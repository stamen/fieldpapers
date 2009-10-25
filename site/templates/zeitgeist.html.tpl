<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language}default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Statistik
        {elseif $language == "nl"}
            Statistieken
        {elseif $language == "es"}
            Estadísticas    
        {elseif $language == "fr"}
            Statistiques
        {elseif $language == "ja"}
            統計
        {elseif $language == "it"}
            Statistiche
        {else}
            Zeitgeist
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>{strip}
        {if $language == "de"}
            Statistik
        {elseif $language == "nl"}
            Statistieken
        {elseif $language == "es"}
            Estadísticas    
        {elseif $language == "fr"}
            Statistiques
        {elseif $language == "ja"}
            統計
        {elseif $language == "it"}
            Statistiche
        {else}
            Zeitgeist
        {/if}
    {/strip}</h2>
    
    {include file="$language/zeitgeist-countries.htmlf.tpl"}
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chd=t:{"urlencode"|@array_map:$country_percents|@join:","|escape}&amp;chs=408x180&amp;chl={"urlencode"|@array_map:$country_names|@join:"|"|escape}">
    </p>
    
    {include file="$language/zeitgeist-orientation.htmlf.tpl"}
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chd=t:{$orientation_percent.portrait|escape},{$orientation_percent.landscape|escape}&amp;chs=408x120&amp;chl=Portrait|Landscape">
    </p>
    
    {include file="$language/zeitgeist-numbers.htmlf.tpl"}
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chd=t:{$print_percent|escape},{$scan_percent|escape}&amp;chs=408x120&amp;chl=Prints|Scans">
    </p>
    
    {include file="$language/zeitgeist-numbers-paragraph.htmlf.tpl"}
    
    {include file="$language/zeitgeist-scans.htmlf.tpl"}
    
    <p>
        {if $scan_states.progress}
            <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=2.8274&amp;chd=t:{$scan_states.progress|escape},{$scan_states.finished|escape},{$scan_states.failed|escape}&amp;chs=408x120&amp;chl=In+Progress|Finished|Failed">

        {else}
            <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=2.8274&amp;chd=t:{$scan_states.finished|escape},{$scan_states.failed|escape}&amp;chs=408x120&amp;chl=Finished|Failed">
        {/if}
    </p>
    
    {include file="$language/zeitgeist-scans-paragraph.htmlf.tpl"}
    
    {include file="$language/zeitgeist-zoomlevels.htmlf.tpl"}
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=bvs&amp;chbh=a&amp;chs=408x120&amp;chxt=r&amp;chxr=0,0,{$zooms|@max}&amp;chds=0,{$zooms|@max}&amp;chl=0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18&amp;chd=t:{$zooms.0|escape},{$zooms.1|escape},{$zooms.2|escape},{$zooms.3|escape},{$zooms.4|escape},{$zooms.5|escape},{$zooms.6|escape},{$zooms.7|escape},{$zooms.8|escape},{$zooms.9|escape},{$zooms.10|escape},{$zooms.11|escape},{$zooms.12|escape},{$zooms.13|escape},{$zooms.14|escape},{$zooms.15|escape},{$zooms.16|escape},{$zooms.17|escape},{$zooms.18|escape}" />
    </p>
    
    {include file="$language/zeitgeist-hemispheres.htmlf.tpl"}

    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=1.2566&amp;chd=t:{$hemisphere_percent.western|escape},{$hemisphere_percent.eastern|escape}&amp;chs=408x120&amp;chl=Western|Eastern">
    </p>
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=2.8274&amp;chd=t:{$hemisphere_percent.northern|escape},{$hemisphere_percent.southern|escape}&amp;chs=408x120&amp;chl=Northern|Southern">
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
