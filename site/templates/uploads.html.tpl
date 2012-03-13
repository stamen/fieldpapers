<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Uploads - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
</head>
<body>
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        <h2><a href="{$base_dir}/atlases.php">Atlases</a> | Uploads</h2>
        
        {foreach from=$scans item="scan" name="index"}
            <div class="atlasThumb">
                <a href="{$base_dir}/scan.php?id={$scan.id}">
                <img src="{$scan.base_url}/preview.jpg" alt="scanned page" 
                name="atlasPage" width="100%" id="atlasPage"></a>
                <span class="atlasName"><a href="{$base_dir}/scan.php?id={$scan.id}">Untitled</a></span>
                <span class="atlasOwner">by <a href="{$base_dir}/uploads.php?user={$scan.user_id}">{$scan.user_name}</a></span>,

                {if $scan.place_woeid}
                    <a href="{$base_dir}/uploads.php?place={$scan.place_woeid}">{$scan.place_name|nice_placename}</a>,
                {/if}
                {if $scan.region_woeid}
                    <a href="{$base_dir}/uploads.php?place={$scan.region_woeid}">{$scan.region_name|nice_placename}</a>,
                {/if}
                {if $scan.country_woeid}
                    <a href="{$base_dir}/uploads.php?place={$scan.country_woeid}">{$scan.country_name|nice_placename}</a>
                {else}
                    Unknown Place
                {/if}

                <span class="atlasMeta">                    
                    {if $scan.number_of_pages == 1}
                        1 page,
                    {else if $scan.number_of_pages > 1}
                        {$scan.number_of_pages} pages,
                    {/if}
                    <a href="{$base_dir}/uploads.php?month={"Y-m"|@date:$scan.created}">{$scan.age|nice_relativetime|escape}</a>
                </span>
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>