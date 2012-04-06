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
        <h1>Snapshots {$title|escape}</h1>
        <h2><a href="{$base_dir}/atlases.php">Atlases</a> | Uploads</h2>
        
        {foreach from=$scans item="scan" name="index"}
            <div class="atlasThumb">
                <a href="{$base_dir}/snapshot.php?id={$scan.id}"><img src="{$scan.base_url}/preview.jpg" alt="scanned page" width="100%"></a>
                
                {capture assign="scan_title"}
                    {if $scan.print && $scan.print.title && $scan.print_page_number}
                        Page {$scan.print_page_number} of {$scan.print.title|escape}
                    {elseif $scan.print && $scan.print.title}
                        {$scan.print.title|escape}
                    {elseif $scan.print_page_number}
                        Page {$scan.print_page_number} of untitled atlas
                    {else}
                        Untitled atlas
                    {/if}
                {/capture}

                <a href="{$base_dir}/snapshot.php?id={$scan.id}">{$scan_title|@trim|escape}</a>

                {if $scan.user.name}
                    by <a href="{$base_dir}/uploads.php?user={$scan.user_id}">{$scan.user.name}</a>,
                {else}
                    by Anonymous,
                {/if}

                {if $scan.place_name}
                    <a href="{$base_dir}/uploads.php?place={$scan.place_woeid}">{$scan.place_name|nice_placename}</a>, 
                    <a href="{$base_dir}/uploads.php?place={$scan.region_woeid}">{$scan.region_name|nice_placename}</a>, 
                    <a href="{$base_dir}/uploads.php?place={$scan.country_woeid}">{$scan.country_name|nice_placename}</a>
                {/if}

                <a href="{$base_dir}/uploads.php?month={"Y-m"|@date:$scan.created}">{$scan.age|nice_relativetime|escape}</a>.
            </div>
        {/foreach}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>