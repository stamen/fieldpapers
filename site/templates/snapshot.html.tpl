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
        <script type="text/javascript" src="{$base_dir}/reqwest.min.js"></script>
        <script type="text/javascript" src="{$base_dir}/marker_notes.js"></script>
    {/if}
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
        
        #atlas_inputs_container {
            /*height: 0px;*/
            position: absolute;
            z-index: 2;
            width: 100%;
            /*top:0;*/
            /*text-align: center;*/
        }
        
        .atlas_inputs {
            padding: 0px 0px 0px 0px;
            margin: -25px auto 0 auto;
            background-color: #FFF;
            border-top: 2px solid #000;
            width: 460px;
            height: auto;
            /*border: 1px solid #FF0000;*/
        }
    
        /*
        #area_title_container {
            display: inline-block;
            width: 1em;
            margin: 0px 45px 10px 0px;
            text-align: left;
        }
        */
        
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
            /*padding: 2px 0px 2px 2px;*/
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
    
        #marker-container
        {
            position: absolute;
            z-index: 4;
        }
        
        #marker-container .marker
        {
            position: absolute;
        }
        
        #marker_note
        {
            background-color: #000;
            /*border: 1px solid #050505;*/
            padding: 0px;
            position: absolute;
            z-index: 5;
        }
        
        #polygon_note
        {
            background-color: #000;
            /*border: 1px solid #050505;*/
            padding: 0px;
            position: absolute;
            z-index: 5;
        }
        
        #new_polygon_note
        {
            background-color: #000;
            /*border: 1px solid #050505;*/
            padding: 0px;
            position: absolute;
            z-index: 5;
        }
        
        #new_marker_note
        {
            background-color: #000;
            /*border: 1px solid #050505;*/
            padding: 0px;
            position: absolute;
            z-index: 5;
        }
        
        #marker-container .marker img
        {
            cursor: move;
        }
        
        .hide {
            display: none;
        }
        
        .show {
            display: block;
        }
        
        #notes {
            margin: 0;
        }
        
        #textarea_note {
            margin: 0;
            position: absolute;
            z-index: 4;
        }
        
        #textarea_note_button {
            margin: 0;
            position: absolute;
            z-index: 4;
        }
        
        #marker_textarea {
            width: 200px;
            height: 100px;
            padding: 5px;
            margin: 0px;
            background-color: #FFC;
            border: none; 
        }
        
        #new_marker_textarea {
            width: 200px;
            padding: 5px;
            margin: 0px;
        }
        
        #polygon_textarea {
            width: 200px;
            padding: 5px;
            margin: 0px;
        }
        
        #new_polygon_textarea {
            width: 200px;
            padding: 5px;
            margin: 0px;
        }
        
        #remove, #remove_new, #ok, #ok_new, #cancel {
            float: left;
        }
        
        #saved_note {
            background-color: white;
            margin: 2px;
            padding: 10px;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-weight: normal;
            font-size: .8em;
            width: 150px;
            height: auto;
            border-bottom: 2px solid #000;
            z-index: 5;
        }
        
        #polygon_tip {
            background-color: white;
            margin: 2px;
            padding: 10px;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-weight: normal;
            font-size: .8em;
            width: 150px;
            height: auto;
            border-bottom: 2px solid #000;
            
            position: absolute;
            z-index: 5;
        }
        
        #marker_tip {
            background-color: white;
            margin: 2px;
            padding: 10px;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-weight: normal;
            font-size: .8em;
            width: 150px;
            height: auto;
            border-bottom: 2px solid #000;
            
            position: absolute;
            z-index: 5;
        }
        
        #button_container {
            background-color: #000; 
            padding: 5px; 
            position: relative; 
            top: -3px;
        }
        
    /* {/literal}]]> */
    </style>
</head>
<body> 
    {include file="navigation.htmlf.tpl"}
    <div id="container" style="position: relative">
            {if $scan && $scan.decoded}
                <div id="atlas_inputs_container">
                    <div class="atlas_inputs">
                        <div style="display: inline-block; float: left; background-color: black; width: auto; height: auto; padding: 14px;">
                            <span id="toolbar_title" style="color: #FFF">
                                A3
                            </span>
                        </div>
                        <div style="display: inline-block; float: left; padding: 8px;">
                            <span style="color: #666; font-size: 13px;">
                                Add notes to page A3 of 16 from
                            </span>
                            <br/>
                            <span style="color: #000; font-size: 13px;">
                                <a style="text-decoration: none" href="{$base_dir}/print.php?id={$print_id}">ATLAS NAME</a>
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
                        <textarea id="new_marker_textarea" style="background-color: #FFC; border: none; height: 100px;"></textarea>
                        <div style="background-color: #000; padding: 5px; position: relative; top: -3px;">
                            <button type="button" id="new_marker_ok_button">OK</button>
                            <button type="button" id="new_marker_delete_button">Delete</button>    
                        </div>
                    </div>
                    <div id="marker_note" class="hide">
                        <textarea id="marker_textarea" style="background-color: #FFC; border: none; height: 100px;">Note</textarea>
                        <div style="background-color: #000; padding: 5px; position: relative; top: -3px;">
                            <button type="button" id="marker_ok_button">OK</button>
                            <button type="button" id="marker_cancel_button">Cancel</button>
                            <button type="button" id="marker_delete_button" style="float: right;" onclick="deletePolygonNote();">Delete</button>
                        </div>
                    </div>

                    <div id="polygon_tip" class="hide">Note</div>
                    <div id="new_polygon_note" class="hide">
                        <textarea id="new_polygon_textarea" style="background-color: #FFC; border: none; height: 100px;"></textarea>
                        <div style="background-color: #000; padding: 5px; position: relative; top: -3px;">
                            <button type="button" id="new_polygon_ok_button" onclick="submitPolygonNote();">OK</button>
                            <button type="button" id="new_polygon_delete_button" onclick="deleteNewPolygonNote();">Delete</button>    
                        </div>
                    </div>
                    <div id="polygon_note" class="hide">
                        <textarea id="polygon_textarea" style="background-color: #FFC; border: none; height: 100px;">Note</textarea>
                        <div style="background-color: #000; padding: 5px; position: relative; top: -3px;">
                            <button type="button" id="polygon_ok_button" onclick="submitPolygonNote();">OK</button>
                            <button type="button" id="polygon_ok_button" onclick="resetPolygonNote();">Cancel</button>
                            <button type="button" id="polygon_delete_button" style="float: right;" onclick="deletePolygonNote();">Delete</button>
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
            {/if}
        </div>
    
</body>
</html>