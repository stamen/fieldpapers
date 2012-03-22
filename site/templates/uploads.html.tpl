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
                <a href="{$base_dir}/snapshot.php?id={$scan.id}"><img src="{$scan.base_url}/preview.jpg" alt="scanned page" width="100%"></a>

                {if $scan.user.name}
                    <a href="{$base_dir}/snapshot.php?id={$scan.id}">{if $scan.title}{$scan.title|escape}{else}Untitled{/if}</a>
                    by <a href="{$base_dir}/atlases.php?user={$scan.user_id}">{$scan.user.name}</a>,

                {else}
                    <a href="{$base_dir}/snapshot.php?id={$scan.id}">{if $scan.title}{$scan.title|escape}{else}Untitled{/if}</a>,
                {/if}

                {if $scan.place_name}
                    <a href="{$base_dir}/atlases.php?place={$scan.place_woeid}">{$scan.place_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$scan.region_woeid}">{$scan.region_name|nice_placename}</a>, 
                    <a href="{$base_dir}/atlases.php?place={$scan.country_woeid}">{$scan.country_name|nice_placename}</a>
                {/if}

                <a href="{$base_dir}/atlases.php?month={"Y-m"|@date:$scan.created}">{$scan.age|nice_relativetime|escape}</a>.
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>