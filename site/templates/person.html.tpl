<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{$user_name} - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />    
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
                {if $prints|@count == 1}
                    1 Atlas
                {else if $print|@count >= 1}
                    {$prints|@count} Atlases
                {/if}
                | <a href="{$base_dir}/person-scans.php?id={$user_id}">Uploads</a></h2>
            </h2>
            {foreach from=$prints item="print" name="index"}
                <div class="atlasThumb"> 
                    <a href="print.php?id={$print.id}"><img src="{$print.preview_url}" alt="printed page" 
                    name="atlasPage" width="100%" id="atlasPage" /></a>
                    
                    <div class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">Untitled</a></div>
                    <div class="atlasPlace">
                        {if $print.city_name && $print.country_name}
                            <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">
                                {$print.city_name}
                            </a>,
                            <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">
                                {if $print.country_name}
                                    {$print.country_name}
                                {else}
                                    Unknown Place
                                {/if}
                            </a>
                        {/if}
                    </div>
                    <div class="atlasMeta">
                    {if $print.number_of_pages == 1}
                        1 page,
                    {else if $print.number_of_pages > 1}
                        {$print.number_of_pages} pages,
                    {/if}
                    from <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a></div>
                </div>
            {/foreach}
        </div>
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>