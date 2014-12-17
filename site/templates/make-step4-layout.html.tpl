<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Set Layout - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">

    <style>
    {literal}
    #clone-msg{
        margin: 15px 0;
        border: 1px solid #fff;
    }
    #clone-msg h3{
        margin-bottom: 5px;
    }
    #clone-msg input{
        margin-left: 10px;
        color: #666;
    }
    .smallLayoutContainer{
        margin-top: 20px;
        font-size: 1em;
    }
    input[type='radio'], input[type='checkbox']{
        vertical-align: text-bottom;
    }
    {/literal}
    </style>
</head>
<body>      
    {include file="navigation.htmlf.tpl"}
    <div class="navbar">
        <div id="subnav_container">
            <span class="subnav area">
                <span id="area">
                    <span>1.</span><br>
                    <span><b>AREA</b></span>
                </span>
            </span>
            <span class="subnav info">
                <span>
                    <span>2.</span><br>
                    <span><b>INFO</b></span>
                </span>
            </span>
            <span class="subnav layout active">
                <span>
                    <span>3.</span><br>
                    <span><b>LAYOUT</b></span>
                </span>
            </span>
        </div>
    </div>
    
	<form id="compose_print" action="{$base_dir}/compose-atlas.php" accept-charset="utf-8" method="POST">    
   
    <div class="smallLayoutContainer">
    	<h2>Choose a Layout</h2>
        <p><label><input type="checkbox" name="grid" /> Add a UTM grid overlay to each map? (What's <a href="http://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system">UTM</a>?)</label></p>
        <p><label><input type="checkbox" name="redcross" /> Add the Red Cross overlay (for disaster relief efforts)</label></p>
    </div>
    <div class="container"> 
            
        {if !$atlas_data.atlas_text}
            <div class="homeThird">
                <label for="maps_only">
                    <img src="{$base_dir}/img/image-make-maps-only.png" alt="Make Maps Only">
                </label>
                <div style="text-align: left; margin-left: 90px;">
                    <input style="margin-right: 10px" type="radio" name="layout" id="maps_only" value="full-page" checked>
                    Maps Only
                    <br><span style="font-size: .8em; color: #666; margin-left: 30px;">one per page</span>
                </div>
            </div>
        {/if}
        <div class="homeThird">
            <label for="maps_notes_own">
                <img src="{$base_dir}/img/image-make-map-notes.png" alt="Maps and Notes on Their Own Page">
            </label>
            <div style="text-align: left; margin-left: 90px;">
            <input style="margin-right: 10px" type="radio" name="layout" id="maps_notes_own" value="full-page">
            Maps + Notes
            <br><span style="font-size: .8em; color: #666; margin-left: 30px;">on their own pages</span>
            </div>
        </div>
        <div class="homeThird">
            <label for="maps_notes_same">
                <img src="{$base_dir}/img/image-make-maps-notes-2up.png" alt="Maps and Notes on the Same Page">
            </label>
            <div style="text-align: left; margin-left: 90px;">
                <input style="margin-right: 10px" type="radio" name="layout" id="maps_notes_same" value="half-page" {if $atlas_data.atlas_text}checked{/if}>
                Maps + Notes
                <br><span style="font-size: .8em; color: #666; margin-left: 30px;">on same page</span>
            </div>
        </div>
        <div class="clearfloat"></div> 
     </div>   
     <div class="smallLayoutContainer" style="text-align:right;">
            <input type="hidden" name="atlas_title" value="{$atlas_data.atlas_title|escape}">          
            <input type="hidden" name="atlas_text" value="{$atlas_data.atlas_text|escape}">
            <input type="hidden" id="page_zoom" name="page_zoom" value="{$atlas_data.page_zoom|escape}">
            <input type="hidden" id="paper_size" name="paper_size" value="{$atlas_data.paper_size|escape}">
            <input type="hidden" id="orientation" name="orientation" value="{$atlas_data.orientation|escape}">
            <input type="hidden" id="provider" name="provider" value="{$atlas_data.provider|escape}">
            <input type="hidden" name="private" value="{$atlas_data.private|escape}">
            
            {if $atlas_data.clone_id}
                <input type="hidden" name="clone_id" value="{$atlas_data.clone_id|escape}">
            {/if}

            {if $atlas_data.overlay}
                <input type="hidden" name="overlay" value="{$atlas_data.overlay|escape}">
            {/if}
            
            {if $atlas_data.refresh_id}
                <input type="hidden" id="refresh_id" name="refresh_id" value="{$atlas_data.refresh_id|escape}">
            {/if}

            {if $atlas_data.form_url}
                <input type="hidden" name="form_url" value="{$atlas_data.form_url|escape}">
            {elseif $atlas_data.form_id}
                <input type="hidden" name="form_id" value="{$atlas_data.form_id|escape}">
            {/if}

            {foreach from=$atlas_data.pages item="page" key="index"}
                <input type="hidden" name="pages[{$index|escape}]" value="{$page|escape}">
            {/foreach}
            
        <div style=" margin-bottom: 40px;">
            <input id="finished-btn" class="btn" type="submit" value="Finished!">
            <input type="hidden" name="action" value="compose">
        </div> 
    </div>
    </form>
        {include file="footer.htmlf.tpl"} 
    </div> 
</body>
</html>


