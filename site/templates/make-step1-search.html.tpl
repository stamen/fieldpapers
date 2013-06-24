<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Search - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/js/make_search.js"></script>
    <script type="text/javascript">
        var base_url = {$base_dir|json_encode};
    </script>
</head>
    <body>
        {include file="navigation.htmlf.tpl"}
        <div class="container">
            <div class="smallContainer" style="text-align: center;">

                {if $error_nosearch}{* TODO: send error msg *}
                <p>Sorry, but our <strong>search isn't working at the moment.</strong></p>
        
                <p>While we work on a fix, you can still browse existing atlases around the world,<br>
                and stay in touch for updates by following the <a href="https://twitter.com/stamen">@stamen</a> Twitter account.</p>
        
                <p>Thanks.</p>
                {/if}

                <h2>Where in the world is your atlas?</h2>
                    <form id="search-form" accept-charset = "utf-8" action="{$base_dir}/make-step2-geography.php" method="post">
                        <input type="text" name="query" size="45" style="padding: 5px; color: grey;" id="location_input"
                               placeholder="Type in a location" value="{$atlas_data.atlas_location|escape}">
                        <input class='btn' style='margin-bottom: 5px;' type="submit" name="action" value="Start There">
                        
                        {if $atlas_data.atlas_provider}
                            <input name="atlas_provider" value="{$atlas_data.atlas_provider|escape}" type="hidden">
                        {/if}
                        
                        {if $atlas_data.atlas_title}
                            <input name="atlas_title" value="{$atlas_data.atlas_title|escape}" type="hidden">
                        {/if}
                        
                        {if $atlas_data.atlas_text}
                            <input name="atlas_text" value="{$atlas_data.atlas_text|escape}" type="hidden">
                        {/if}
                    </form>
                {if $user_mbtiles}
                    <h2>Or Choose your MBTiles</h2>
                    <p>
                        <form id="mbtiles_form" method="post" 
                              action="{$base_dir}/make-step2-geography.php?mbtiles_id={$user_mbtiles[0].id}&coordinates={$user_mbtiles[0].center_y_coord}/{$user_mbtiles[0].center_x_coord}/{$user_mbtiles[0].center_zoom}">
                            <select id='mbtiles_selection' name="mbtiles_id" onChange="changeFormAction(selectedIndex)">
                                {foreach from=$user_mbtiles key="index" item="user_mbtiles_file"}
                                    <h2>{$index}</h2>
                                    <option value="{$user_mbtiles[$index].id}_{$user_mbtiles[$index].center_y_coord}_{$user_mbtiles[$index].center_x_coord}_{$user_mbtiles[$index].center_zoom}">
                                    {$user_mbtiles_file.uploaded_file}
                                    </option>
                                {/foreach}
                            </select><br>
                            <input class='btn' type="submit" name="action" value="Use MBTiles">
                        </form>
                    </p>
                {/if}
                
            </div>
            {include file="footer.htmlf.tpl"}
        </div>
    </body>
</html>
