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
    
   <div class="container" style="margin-top:50px;"> 
	<form id="compose_print" action="{$base_dir}/compose-atlas.php" accept-charset="utf-8" method="POST">    
    {if $atlas_data.clone_id}
        <div id="clone-msg">
            <h3>Please rename your clone</h3>
            <input type='text' name='clone_name' size='50' id='clone_name' placeholder='' value='{$atlas_data.atlas_title|escape}_clone_v2'>
        </div>
    {/if} 
    <div class="smallLayoutContainer">
    	<h2>Choose a Layout</h2>
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
     <div class="smallLayoutContainer">
         <p><input type="checkbox" id="grid" /> <label for="grid">Add a grid overlay to each map?</label></p>
            {if $atlas_data.clone_id} 
                <input id='atlas_title_input' type="hidden" name="atlas_title" value="{$atlas_data.atlas_title|escape}_clone_v2">
            {else}
                <input type="hidden" name="atlas_title" value="{$atlas_data.atlas_title|escape}">
            {/if}
            <input type="hidden" name="atlas_text" value="{$atlas_data.atlas_text|escape}">
            <input type="hidden" id="page_zoom" name="page_zoom" value="{$atlas_data.page_zoom|escape}">
            <input type="hidden" id="paper_size" name="paper_size" value="{$atlas_data.paper_size|escape}">
            <input type="hidden" id="orientation" name="orientation" value="{$atlas_data.orientation|escape}">
            <input type="hidden" id="provider" name="provider" value="{$atlas_data.provider|escape}">
            <input type="hidden" name="private" value="{$atlas_data.private|escape}">
            {if $atlas_data.clone_id}
                <input type="hidden" name="clone_id" value="{$atlas_data.clone_id|escape}">
            {/if} 
            {if $atlas_data.form_url}
                <input type="hidden" name="form_url" value="{$atlas_data.form_url|escape}">
            {elseif $atlas_data.form_id}
                <input type="hidden" name="form_id" value="{$atlas_data.form_id|escape}">
            {/if}

            {foreach from=$atlas_data.pages item="page" key="index"}
                <input type="hidden" name="pages[{$index|escape}]" value="{$page|escape}">
            {/foreach}
            
        <div style="float: right; margin-top: 20px; margin-bottom: 40px;">
            <input type="submit" value="Finished!">
            <input type="hidden" name="action" value="compose">
        </div> 
    </div>
    </form>
    
        {include file="footer.htmlf.tpl"} 
    </div>
    <script>
    {literal}
    var cloneInput = document.getElementById('clone_name');
    var atlas_title = document.getElementById('atlas_title_input');
    cloneInput.onkeydown = function(e){
        if(e.keyCode == 13){
            e.preventDefault && e.preventDefault();
            e.returnValue = false;
            return false;
        }
    }    
    function inputChange(val){
        console.log(val);
        if(!val || val.length < 1)return;
        atlas_title.value = val;
    }
    
    cloneInput.onkeypress = function(){
        inputChange(this.value);
    };

    cloneInput.onchange = function(){
        inputChange(this.value);
    };    

    {/literal}
    </script>
</body>
</html>


