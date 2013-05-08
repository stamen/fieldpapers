<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>Add Form - fieldpapers.org</title>
<link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
</head>
<body>
{include file="navigation.htmlf.tpl"}
<div class="navbar">
    <div id="subnav_container"> <span class="subnav area"> <span id="area"> <span>1.</span><br>
        <span><b>AREA</b></span> </span> </span> <span class="subnav info active"> <span> <span>2.</span><br>
        <span><b>INFO</b></span> </span> </span> <span class="subnav layout"> <span> <span>3.</span><br>
        <span><b>LAYOUT</b></span> </span> </span> </div>
</div>
<div class="smallContainer">
    
    <h2>Name/Description</h2>
    <form action="{$base_dir}/make-step4-layout.php" method="POST">
        <p>
            <label for="atlas_title">Give Your Atlas a Name</label>
            <br>
            <input type="text" id='title_input' name="atlas_title" size="60" placeholder="Untitled" value="{$atlas_data.atlas_title|escape:hexentity}">
        </p>
        <p>
            <label for="atlas_text">Add <i>optional</i> text to each page?</label>
        	<br />
        	<small>Text you enter below will show up next to each map page in the atlas.</small>
        <p>
            <textarea style="width: 100%;" name="atlas_text" rows="10">{$atlas_data.atlas_text|escape:hexentity}</textarea>
        </p>
        <p>
            <input type="checkbox">
            Make this atlas private. <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small>(That means it's only accessible to you, if you're logged in, or by direct URL.)</small> </p>
        <input type="hidden" id="page_zoom" name="page_zoom" value="{$atlas_data.page_zoom|escape}">
        <input type="hidden" id="paper_size" name="paper_size" value="{$atlas_data.paper_size|escape}">
        <input type="hidden" id="orientation" name="orientation" value="{$atlas_data.orientation|escape}">
        <input type="hidden" id="provider" name="provider" value="{$atlas_data.provider|escape}">
        {foreach from=$atlas_data.pages item="page" key="index"}
        <input type="hidden" name="pages[{$index|escape}]" value="{$page|escape}">
        {/foreach}
        <div style="float: right; margin-top: 20px;">
            <input type="submit" value="Next">
        </div>
    </form>
    </div>
<div class="container">
    {include file="footer.htmlf.tpl"} 
</div>

</body>
</html>