<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Make - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/raphael.js"></script>
    <script type="text/javascript">
        var base_url = {$base_dir|json_encode};
        var zoom_in_active = base_url + '/img/button-zoom-in-on.png',
            zoom_in_inactive = base_url + '/img/button-zoom-in-off.png',
            zoom_out_active = base_url + '/img/button-zoom-out-on.png',
            zoom_out_inactive = base_url + '/img/button-zoom-out-off.png',
            zoom_return_active = base_url + "/img/button-return-on.png",
            zoom_return_inactive = base_url + "/img/button-return-off.png",
            button_remove_row_active = base_url + "/img/button-remove-row-on.png",
            button_remove_row_inactive = base_url + "/img/button-remove-row-off.png",
            button_remove_column_active = base_url + "/img/button-remove-column-on.png",
            button_remove_column_inactive = base_url + "/img/button-remove-column-off.png",
            button_add_active = base_url + "/img/button-add-on.png",
            button_add_inactive = base_url + "/img/button-add-off.png",
            button_scale_active = base_url + "/img/button-scale-atlas-on.png",
            button_scale_inactive = base_url + "/img/button-scale-atlas-off.png",
            button_drag_active = base_url + "/img/button-move-atlas-on.png",
            button_drag_inactive = base_url + "/img/button-move-atlas-off.png";
        
        var mbtiles_data = {$mbtiles_data|@json_encode} || null,
            center = {$center|json_encode} || null,
            zoom = {$zoom|json_encode} || null,
            zoom = {$zoom|json_encode} || null,
            user_mbtiles = {$user_mbtiles|@json_encode} || null;

    </script>
    <script type="text/javascript" src="{$base_dir}/js/make_geography.js"></script>
    <style type="text/css">
        {literal}
        h1 {
           margin-left: 20px;
        }
        
        body {
           background: #fff;
           color: #000;
           font-family: Helvetica, sans-serif;
           margin: 0;
           padding: 0px;
           border: 0;
        }
        #map {
           width: 100%;
           position: absolute;
           overflow: hidden;
           z-index: 1;
        }
        
        #canvas {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 3;
        }
        
        #zoom-container {
            width: 46px;
            height: 92px;
            position: absolute;
            padding: 8px 0px 0px 20px;
            line-height: 0;
            z-index: 2;
        }
        
        #zoom-in,
        #zoom-out,
        #zoom-return {
            cursor: pointer;
        }
        
        #atlas_inputs_container {
            height: 0px;
            position: absolute;
            z-index: 2;
            width: 100%;
            top:0;
            text-align: center;
        }
        
        .atlas_inputs {
            font-size: 13px;
            padding: 10px 10px 0px 0px;
            margin: -25px auto 0 auto;
            background-color: #FFF;
            border-top: 2px solid #000;
            width: 580px;
        }
        
        #area_title_container {
            display: inline-block;
            width: 1em;
            margin: 0px 45px 10px 0px;
            text-align: left;
        }
                
        #page_plural {
            font-size: 11px;
            line-height 14;
            color: #666;
        }
        
        #next_button {
            font-size: 13px;
            position: relative;
            top: -8px;
            margin: 0;
        }
        
        #atlas_info, #atlas_layout {
           display: inline-block;
           padding-left: 10px;
           margin-left: 10px;
           border-left: 1px dashed #666;
           color: #CCC;
        }
        
        .radio_portrait {
            background: url("{/literal}{$base_dir}{literal}/img/button-portrait-off.png") no-repeat;
            display: inline-block;
            padding: 2px 2px 2px 2px;
            margin-left: 5px;
            position: relative;
            top: 3px;
            width: 19px;
            height: 25px;
            cursor: pointer;
        }
        
        .radio_portrait_selected {
            background: url("{/literal}{$base_dir}{literal}/img/button-portrait-selected.png") no-repeat;
            display: inline-block;
            padding: 2px 2px 2px 2px;
            margin-left: 5px;
            position: relative;
            top: 3px;
            width: 19px;
            height: 25px;
            cursor: pointer;
        }
        
        .radio_landscape {
            background: url("{/literal}{$base_dir}{literal}/img/button-landscape-off.png") no-repeat;
            display: inline-block;
            padding: 2px 0px 2px 2px;
            width: 25px;
            height: 19px;
            cursor: pointer;
        }
        
        .radio_landscape_selected {
            background: url("{/literal}{$base_dir}{literal}/img/button-landscape-selected.png") no-repeat;
            display: inline-block;
            padding: 2px 0px 2px 2px;
            width: 25px;
            height: 19px;
            cursor: pointer;
        }
        
        #area {
            width: auto;
            padding-right: 10px;
            padding-bottom: 0px;
        }
        
        #area .label {
            margin-right: 10px;
        }
        
        .subnav .controls {
            position: relative;
            margin-top: -4px;
            display: inline-block;
        }
        {/literal}
    </style>
</head>
    <body onload="initUI()">
        {include file="navigation.htmlf.tpl"}
        <div id="container" style="position: relative; padding-top: 20px;">
            <form id="compose_print" method="post" accept-charset = "utf-8" action="{$base_dir}/make-step3-info.php">
                <div class="navbar">
                    <div id="subnav_container" style="margin-top: -20px;">
                        <span id="area" class="subnav area active">
                            <span class="label">
                                <span >1.</span><br>
                                <span><b>AREA</b></span>
                            </span>
                            
                            <span class="controls">
                                <div class="radio_landscape_selected" id="landscape_button" title="Landscape" onclick="changeOrientation('landscape');"></div>
                                <div class="radio_portrait" id="portrait_button" title="Portrait" onclick="changeOrientation('portrait');"></div>
                                
                                <select style="width: 150px; top: -8px; margin-left: 10px; position: relative;" name="provider" onchange="setProvider(this.value);">
                                    {if $atlas_data.atlas_provider}
                                        <option value="{$atlas_data.atlas_provider|escape}">{$atlas_data.atlas_provider|escape}</option>
                                    {/if}
                                    {if $mbtiles_data}
                                        <option value="{$mbtiles_data.provider|escape}">{$mbtiles_data.uploaded_file|escape}</option>
                                    {/if}
                                    {foreach from=$providers item="provider"}
                                        <option value="{$provider.0|escape}">{$provider.1|escape}</option>
                                    {/foreach}
                                </select>

                                {if $user_mbtiles}

                                        <select style="width: 150px; top: -8px; margin-left: 10px; position: relative;" name="overlay" onChange="setOverlayProvider(this.value);">
                                                {foreach from=$user_mbtiles key="index" item="user_mbtiles_file"}
                                                   <option value="{$user_mbtiles_file.url|escape}">{$user_mbtiles_file.uploaded_file|escape}</option>
                                                {/foreach}
                                            </select>
                                {/if}
                                
                                <span id="page_count_container">
                                    <span id="page_count"><b>1</b></span><br>
                                    <span id="page_plural">PAGE</span>
                                </span>
                                
                                <input id="next_button" class='btn' type="submit" value="Next">
                            </span>                           
                        </span>
                        <span class="subnav info">
                            <span class="label">
                                <span>2.</span><br>
                                <span><b>INFO</b></span>
                            </span>
                        </span>
                        <span class="subnav layout">
                            <span class="label">
                                <span>3.</span><br>
                                <span><b>LAYOUT</b></span>
                            </span>
                        </span>
                    </div>
                </div>

                <input type="hidden" name="action" value="compose">
                <div id="form_data_div"></div>
                <input type="hidden" id="page_zoom" name="page_zoom">
                <input type="hidden" id="paper_size" name="paper_size">
                <input type="hidden" id="orientation" name="orientation">
                
                {if $atlas_data.atlas_title}
                    <input name="atlas_title" value="{$atlas_data.atlas_title|escape}" type="hidden">
                {/if}
                
                {if $atlas_data.atlas_text}
                    <input name="atlas_text" value="{$atlas_data.atlas_text|escape}" type="hidden">
                {/if}
            </form>
            <div id="zoom-container">
                <span id="zoom-in" style="display: none;">
                    <img src="{$base_dir}/img/button-zoom-in-off.png" id="zoom-in-button" width="46" height="46" title="Zoom In">
                </span>
                <span id="zoom-out" style="display: none;">
                    <img src="{$base_dir}/img/button-zoom-out-off.png" id="zoom-out-button" width="46" height="46" title="Zoom Out">
                </span>
                <span id="zoom-return">
                    <img src="{$base_dir}/img/button-return-off.png" id="zoom-return-button" width="46" height="46" title="Return the Atlas to the Center of the Map">
                </span>
            </div>
            <div id="map">
                <div id="canvas"></div>
            </div>
        </div>
    </body>
</html>
