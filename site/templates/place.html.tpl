<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Place - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />    
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h1>
            {if $place_name && $country_name}
                {$place_name}, {$country_name}
            {else if $country_name}
                {$country_name}
            {/if}
        </h1>
        <h2>Atlases</h2>
        {foreach from=$prints item="print" name="index"}
            <div class="atlasThumb">
                <a href="{$base_dir}/print.php?id={$print.id}">
                <img src="{$print.preview_url}" alt="printed page" 
                name="atlasPage" width="100%" id="atlasPage" /></a>
                <span class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">Untitled</a></span>
                <span class="atlasOwner">by <a href="{$base_dir}/person.php?id={$print.user_id}">{$print.user_name}</a></span>,
                <br />
                <span class="atlasMeta">                    
                    {if $print.number_of_pages == 1}
                        1 page,
                    {else if $print.number_of_pages > 1}
                        {$print.number_of_pages} pages,
                    {/if}
                    <a href="{$base_dir}/time.php?date={$print.created}">{$print.age|nice_relativetime|escape}</a>
                </span>
            </div>
        {/foreach}
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>