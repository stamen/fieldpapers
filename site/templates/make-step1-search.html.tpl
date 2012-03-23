<!DOCTYPE html>
<html>
<head>
    <title>Search - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript">
        {literal}            
            function changeFormAction(index)
            {
                var mbtiles_info = document.getElementById('mbtiles_selection').options[index].value;
                
                var mbtiles_info = mbtiles_info.split('_');
            
                var id = mbtiles_info[0];
                var y = mbtiles_info[1];
                var x = mbtiles_info[2];
                var z = mbtiles_info[3];

                document.getElementById('mbtiles_form').action = '{/literal}{$base_dir}{literal}/make-step2-geography.php?\mbtiles_id=' + id + '&coordinates=' + y + '/' + x + '/' + z;
            }
        {/literal}
    </script>
</head>
    <body>
        {include file="navigation.htmlf.tpl"}
        <div class="container">
            <div class="smallContainer" style="text-align: center;">
                <h2>Where in the world is your atlas?</h2>
                <p>                                            
                    <form id="search-form" action="{$base_dir}/make-step2-geography.php" method="post">
                        <input type="text" name="query" size="50" style="padding: 5px; color: grey;" id="location_input"
                               placeholder="Type in a location">
                        {if $error}
                            <p style="color: #C33;">We could not find that place. Please try again.</p>
                        {/if}
                        <input type="submit" name="action" value="Start There">
                        
                        {if $atlas_data.atlas_title}
                            <input name="atlas_title" value="{$atlas_data.atlas_title|escape:hexentity}" type="hidden">
                        {/if}
                    </form>
                </p>
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
                            <input type="submit" name="action" value="Use MBTiles">
                        </form>
                    </p>
                {/if}
                </div>
            {include file="footer.htmlf.tpl"}
        </div>
    </body>
</html>