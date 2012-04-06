<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>
        Snapshot - fieldpapers.org
    </title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    {if $scan && !$scan.decoded && !$scan.failed}
        <meta http-equiv="refresh" content="5">
    {else}
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/raphael-min.js"></script>
        <script type="text/javascript" src="{$base_dir}/js/reqwest.min.js"></script>
        <script type="text/javascript" src="{$base_dir}/js/marker_notes.js"></script>
    {/if}
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        body {
           background: #fff;
           color: #000;
           font-family: Helvetica, sans-serif;
           margin: 0;
           padding: 0px;
           border: 0;
        }
                
        #atlas_inputs_container {
            position: absolute;
            z-index: 2;
            width: 100%;
        }
        
        .atlas_inputs {
            padding-right: 10px;
            background-color: #FFF;
            border-top: 2px solid #000;
            width: auto;
            height: auto;
            position: absolute;
            z-index: 2;
            left: 220px;
            margin-top: -30px;
        }
            
        #toolbar_title {
            font-size: 24px;
            font-weight: bold;
            position: relative;
        }
                
        .radio_pin {
            background: url("{/literal}{$base_dir}{literal}/img/icon-toolbar-x-off.png") no-repeat;
            display: inline-block;
            padding: 0px;
            margin: 10px 8px 10px 10px;
            width: 31px;
            height: 31px;
            cursor: pointer;
        }
        
        .radio_pin_selected {
            background: url("{/literal}{$base_dir}{literal}/img/icon-toolbar-x-on.png") no-repeat;
            display: inline-block;
            padding: 0px;
            margin: 10px 8px 10px 10px;
            width: 31px;
            height: 31px;
            cursor: pointer;
        }
        
        .radio_shape {
            background: url("{/literal}{$base_dir}{literal}/img/icon-toolbar-shape-off.png") no-repeat;
            display: inline-block;
            padding: 0px;
            margin: 0px 20px 10px 0px;
            width: 31px;
            height: 31px;
            cursor: pointer;
        }
        
        .radio_shape_selected {
            background: url("{/literal}{$base_dir}{literal}/img/icon-toolbar-shape-on.png") no-repeat;
            display: inline-block;
            padding: 0px;
            margin: 0px 20px 10px 0px;
            width: 31px;
            height: 31px;
            cursor: pointer;
        }
        
        #next_button {
            font-size: 13px;
            position: relative;
            top: -22px;
            margin: 0px 0px 0px 0px;
        }
        
        #display_container {
           width: 100%;
           height: 570px;
           position: absolute;
           background-color: #000;
           overflow: hidden;
           z-index: 1;
        }
            
        #map {
           width: 100%;
           height: 100%;
           position: absolute;
        }
        
        .smaller {
            width: 100%; 
            height: 600px;
        }
        
        #zoom-container {
            width: 46px;
            height: 92px;
            position: absolute;
            padding: 8px 0px 0px 20px;
            z-index: 2;
        }
        
        #zoom-in, #zoom-out {
            cursor: pointer;
        }
        
        #canvas {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 3;
        }
    
        #marker-container {
            position: absolute;
            z-index: 4;
        }
        
        .marker {
            position: absolute;
        }
                
        #new_marker_note, #new_polygon_note, #polygon_note, #marker_note {
            background-color: #000;
            padding: 0px;
            position: absolute;
            z-index: 5;
        }
        
        #marker-container .marker img {
            cursor: move;
        }
        
        .hide {
            display: none;
        }
        
        .show {
            display: block;
        }
                
        #new_polygon_textarea, #polygon_textarea, #new_marker_textarea, #marker_textarea {
            width: 200px;
            padding: 5px;
            margin: 0px;
            background-color: #FFC; 
            border: none; 
            height: 100px; 
            min-width: 200px;
        }
                
        #marker_tip, #polygon_tip {
            background-color: white;
            margin: 2px;
            padding: 10px;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-weight: normal;
            font-size: .8em;
            /*width: 150px;*/
            min-width: 150px;
            height: auto;
            border-bottom: 2px solid #000;
            position: absolute;
            z-index: 5;
            white-space: pre;
            /*word-wrap: break-word;*/
        }
        
        .note_container {
            background-color: #000; 
            margin-top: 0%; 
            margin-bottom: 0%; 
            height: auto;
        }
        
        .note_buttons {
            margin:5% 5px 5% 5px; 
            float: left;
        }
        
        .note_buttons.right {
            float: right;
        }
        
        #atlas_link {
            font-size: 13px;
        }
        
        #atlas_link a {
            color: #09F; 
            text-decoration: none;
        }
        
        #atlas_link a:hover, a:active, a:focus {
            color: #09F; 
        }
    /* {/literal}]]> */
    </style>
</head>
<body> 
    {include file="navigation.htmlf.tpl"}
            <div id="container" style="position: relative; padding-top: 30px;">
                        {if $scan && $scan.decoded}
                <div class="navbar">
                    <div class="atlas_inputs">
                        <div style="display: inline-block; float: left; background-color: black; padding: 14px;">
                            <span id="toolbar_title" style="color: #FFF">
                                {$print_page_number|escape}
                            </span>
                        </div>
                        <div style="display: inline-block; float: left; padding: 8px;">
                            <span style="color: #666; font-size: 13px;">
                                Add notes to page {$print_page_number|escape} of {$page_count|escape} from
                            </span>
                            <br/>
                            <span id="atlas_link">
                                <a href="{$base_dir}/print.php?id={$print_id}">{$title|escape}</a>
                            </span>
                        </div>
                        <div class="radio_pin" id="marker_button" title="Add Marker" onclick="addMarkerNote('marker');"></div>
                        <div class="radio_shape" id="polygon_button" title="Add Polygon" onclick="addPolygon();"></div>
                        <input id="next_button" type="button" value="Finished" onclick="finishedRedirect()">
                    </div>
                </div>
                <div id="zoom-container">
                    <span id="zoom-in" style="display: inline;">
                    <img src='{$base_dir}/img/button-zoom-in-off.png' id="zoom-in-button"
                              width="46" height="46">
                    </span>
                    <span id="zoom-out" style="display: inline;">
                        <img src='{$base_dir}/img/button-zoom-out-off.png' id="zoom-out-button"
                                  width="46" height="46">
                    </span>
                </div>
                <div id="display_container">
                    <div id="map">
                        <div id="canvas"></div>
                    </div>
                    <div id="marker-container">
                    </div>
                    
                    <div id="marker_tip" class="hide">Note</div>
                    <div id="new_marker_note" class="hide">
                        <textarea id="new_marker_textarea"></textarea>
                        <div class="note_container">
                            <button type="button" id="new_marker_ok_button" class="note_buttons">OK</button>
                            <button type="button" id="new_marker_delete_button" class="note_buttons">Delete</button>    
                        </div>
                    </div>
                    <div id="marker_note" class="hide">
                        <textarea id="marker_textarea">Note</textarea>
                        <div class="note_container">
                            <button type="button" id="marker_ok_button" class="note_buttons">OK</button>
                            <button type="button" id="marker_cancel_button" class="note_buttons">Cancel</button>
                            <button type="button" id="marker_delete_button" class="note_buttons right" onclick="deletePolygonNote();">Delete</button>
                        </div>
                    </div>

                    <div id="polygon_tip" class="hide">Note</div>
                    <div id="new_polygon_note" class="hide">
                        <textarea id="new_polygon_textarea"></textarea>
                        <div class="note_container">
                            <button type="button" id="new_polygon_ok_button" class="note_buttons" onclick="submitPolygonNote();">OK</button>
                            <button type="button" id="new_polygon_delete_button" class="note_buttons" onclick="deleteNewPolygonNote();">Delete</button>    
                        </div>
                    </div>
                    <div id="polygon_note" class="hide">
                        <textarea id="polygon_textarea">Note</textarea>
                        <div class="note_container">
                            <button type="button" id="polygon_ok_button" class="note_buttons" onclick="submitPolygonNote();">OK</button>
                            <button type="button" id="polygon_cancel_button" class="note_buttons" onclick="resetPolygonNote();">Cancel</button>
                            <button type="button" id="polygon_delete_button" class="note_buttons right" onclick="deletePolygonNote();">Delete</button>
                        </div>
                    </div>
                </div>
                                    
                <script type="text/javascript">
                    var scan_id = {$scan.id|json_encode};
                    var base_url = {$base_dir|json_encode};
                    
                    var notes = {$notes|@json_encode};
                    var post_url = base_url + '/save-scan-notes.php?scan_id=' + scan_id;
                    var base_provider = {$scan.base_url|json_encode};
                    var redirect_url = base_url + '/print.php?id=' + {$print_id|json_encode};
                    var geojpeg_bounds = {$scan.geojpeg_bounds|json_encode};
                    
                    var current_user_id = {$user.id|json_encode};
                </script>
                <script type="text/javascript" src="{$base_dir}/js/snapshot_map.js"></script>
                <script type="text/javascript" src="{$base_dir}/js/polygon_notes.js"></script>
                <script type="text/javascript" src="{$base_dir}/js/snapshot.js"></script>             
            </div>                    
            {elseif $scan}
                {include file="en/scan-process-info.htmlf.tpl"}
                {include file="footer.htmlf.tpl"}
            {/if}
        </div>
    
</body>
</html>