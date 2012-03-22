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
                <a href="{$base_dir}/print.php?id={$print.id}"><img src="{$print.preview_url}" alt="printed page" width="100%"></a>

                {if $print.user.name}
                    <a href="{$base_dir}/print.php?id={$print.id}">{if $print.title}{$print.title|escape}{else}Untitled{/if}</a>
                    by <a href="{$base_dir}/atlases.php?user={$print.user_id}">{$print.user.name}</a>,

                {else}
                    <a href="{$base_dir}/print.php?id={$print.id}">{if $print.title}{$print.title|escape}{else}Untitled{/if}</a>,
                {/if}

                {if $print.place_name}
                    <a href="{$base_dir}/atlases.php?place={$print.place_woeid}">{$print.place_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.region_woeid}">{$print.region_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$print.country_woeid}">{$print.country_name|nice_placename}</a>
                {/if}

                {if $print.number_of_pages == 1}
                    1 page,
                {elseif $print.number_of_pages == 2}
                    two pages,
                {else}
                    {$print.number_of_pages} pages,
                {/if}

                <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$print.created}">{$print.age|nice_relativetime|escape}</a>.
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>