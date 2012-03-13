<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Atlases - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h2>Atlases | <a href="{$base_dir}/uploads.php">Uploads</a></h2>
        
        {foreach from=$prints item="print" name="index"}
            <div class="atlasThumb">
                <a href="{$base_dir}/print.php?id={$print.id}">
                <img src="{$print.preview_url}" alt="printed page" 
                name="atlasPage" width="100%" id="atlasPage"></a>
                <span class="atlasName"><a href="{$base_dir}/print.php?id={$print.id}">Untitled</a></span>
                <span class="atlasOwner">by <a href="{$base_dir}/atlases.php?user={$print.user_id}">{$print.user_name}</a></span>,

                {if $print.place_name}
                    <span class="atlasPlace">
                    <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">
                    {$print.place_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">
                    {$print.region_name|nice_placename}</a>, 
                    <span class="atlasPlace"><a href="{$base_dir}/atlases.php?place={$print.country_woeid}">
                    {$print.country_name|nice_placename}</a>
                {else}
                    Unknown Place
                {/if}

                <span class="atlasMeta">                    
                    {if $print.number_of_pages == 1}
                        1 page,
                    {else if $print.number_of_pages > 1}
                        {$print.number_of_pages} pages,
                    {/if}
                    <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a>
                </span>
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>