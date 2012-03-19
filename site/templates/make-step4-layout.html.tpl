<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Set Layout - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    <style type="text/css">
        {literal}
            .subnav {
               display: inline-block;
               padding-left: 10px;
               padding-top: 10px;
               margin-left: 0px;
               border-top: 2px solid #000;
               width: 75px;
               text-align: left;
               
               color: #CCC;
               font-size: 12px;
            }
            
            .subnav.layout {
               color: #000;
            }
        {/literal}
    </style>
</head>
<body>      
    {include file="navigation.htmlf.tpl"}
    <div style="width: 100%; text-align: center;">
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
        <span class="subnav layout">
            <span>
                <span>3.</span><br>
                <span><b>LAYOUT</b></span>
            </span>
        </span>
    </div>
    <div class="container">
    <form id="compose_print" action="{$base_dir}/compose-atlas.php" method="POST">    
        <span style="font-size: 22px;">Choose a Layout</span>
        
        <div style="margin-top: 20px">
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
        <div class="homeThird">
            <label for="maps_notes_own">
                <img src="{$base_dir}/img/image-make-map-notes.png" alt="Maps and Notes on Their Own Page">
            </label>
            <div style="text-align: left; margin-left: 90px;">
            <input style="margin-right: 10px" type="radio" name="layout" id="maps_notes_own" value="half-page">
            Maps + Notes
            <br><span style="font-size: .8em; color: #666; margin-left: 30px;">on their own pages</span>
            </div>
        </div>
        <div class="homeThird">
            <label for="maps_notes_same">
                <img src="{$base_dir}/img/image-make-maps-notes-2up.png" alt="Maps and Notes on the Same Page">
            </label>
            <div style="text-align: left; margin-left: 90px;">
                <input style="margin-right: 10px" type="radio" name="layout" id="maps_notes_same" value="full-page">
                Maps + Notes
                <br><span style="font-size: .8em; color: #666; margin-left: 30px;">on same page</span>
            </div>
        </div>
        <div class="clearfloat"></div>
        <div style="float: right; margin-top: 60px;">
            <input type="hidden" name="atlas_title" value="{$request.post.atlas_title}">
            <input type="hidden" id="page_zoom" name="page_zoom" value="{$request.post.page_zoom}">
            <input type="hidden" id="paper_size" name="paper_size" value="{$request.post.paper_size}">
            <input type="hidden" id="orientation" name="orientation" value="{$request.post.orientation}">
            <input type="hidden" id="provider" name="provider" value="{$request.post.provider}">

            {if $request.post.form_url}
                <input type="hidden" name="form_url" value="{$request.post.form_url}">
            {elseif $request.post.form_id}
                <input type="hidden" name="form_id" value="{$request.post.form_id}">
            {/if}

            {foreach from=$request.post.pages item="page" key="index"}
                <input type="hidden" name="pages[{$index}]" value="{$page}">
            {/foreach}

            <input type="submit" value="Finished!">
            <input type="hidden" name="action" value="compose">
        </div>
    </form>
    </div>
            {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>