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
            width: 200px;
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
            font-size: 13px;
            position: relative;
            top: -8px;
            margin: 0px 15px 0px 0px;
        }
        
        .radio_shape {
            background: url("{/literal}{$base_dir}{literal}/img/icon-shape.png") no-repeat;
            display: inline-block;
            padding: 2px 2px 6px 2px;
            margin-left: 5px;
            position: relative;
            top: 3px;
            width: 31px;
            height: 23px;
            cursor: pointer;
        }
        
        .radio_pin {
            background: url("{/literal}{$base_dir}{literal}/img/icon-pin-black.png") no-repeat;
            display: inline-block;
            padding: 2px 0px 2px 2px;
            width: 15px;
            height: 26px;
            cursor: pointer;
        }
        
        #next_button {
            font-size: 13px;
            position: relative;
            top: -8px;
            margin: 0px 0px 0px 10px;
        }
            
        #map {
           width: 100%;
           height: 570px;
           position: absolute;
           background-color: #000;
           overflow: hidden;
           z-index: 1;
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
    
        #scan-form,
        #scan-form .marker
        {
            position: absolute;
            z-index: 4;
        }
        
        #polygon_note
        {
            background-color: #fff;
            border: 1px solid #050505;
            padding: 5px;
            position: absolute;
            z-index: 5;
        }
        
        #scan-form .marker img
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
        
        #polygon_textarea {
            width: 200px;
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
            width: 100px;
        }
        
    /* {/literal}]]> */
    </style>
</head>
<body> 
    {include file="navigation.htmlf.tpl"}
    <div id="container" style="position: relative">
            {if $scan && $scan.decoded}
            
                <p>
                    <div class="buttonBar">
                        <button type="button" onClick= "addPolygon()">Add Polygon Note</button>
                        <button type="button" onClick= "addMarkerNote()">Add Marker Note</button>
                    </div>
                </p>
            
                {if $form.form_url}
                <form id="scan-form">
                    <textarea id="textarea_note" class="hide" style="background-color: white">Note</textarea>
                    <input type="button" value="OK" onclick="submitPolygonNote();" />
                </form>
                    <div class="mapFormHolder">
                        <div class="fieldSet">
                            <iframe align="middle" frameborder="0" src="{$form.form_url}"></iframe>
                        </div>
                        <div class="page_map small" id="map">
                            <div id="canvas"></div>
                        </div>
                    </div>
                    
                {else}
                    <div id="atlas_inputs_container">
                        <div class="atlas_inputs">
                            <span id="toolbar_title">
                                <b>Add</b>
                            </span>
                            <div class="radio_pin" id="marker_button" title="Add Marker" onclick="addMarkerNote('marker');"></div>
                            <div class="radio_shape" id="polygon_button" title="Add Polygon" onclick="addPolygon();"></div>
                            <input id="next_button" type="button" value="Finished" onclick="finishedRedirect()">
                        </div>
                    </div>
                    <form id="scan-form">
                        <div id="polygon_note" class="hide">
                            <textarea id="polygon_textarea" style="background-color: white">Note</textarea>
                            <button type="button" id="polygon_ok_button" onclick="submitPolygonNote();">OK</button>
                            <button type="button" id="polygon_ok_button" onclick="resetPolygonNote();">Cancel</button>
                            <button type="button" id="polygon_delete_button" onclick="deletePolygonNote();">Delete</button>
                        </div>
                    </form>
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
                    <div id="map">
                        <div id="canvas"></div>
                    </div>
                                
                {/if}
    
                <script type="text/javascript">
                    var scan_id = {$scan.id|json_encode};
                    var base_url = {$base_dir|json_encode};
                    
                    var notes = {$notes|@json_encode};
                    var post_url = base_url + '/save-scan-notes.php?scan_id=' + scan_id;
                    var base_provider = {$scan.base_url|json_encode};
                    var redirect_url = {$scan.print_href|json_encode};
                    var geojpeg_bounds = {$scan.geojpeg_bounds|json_encode};
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