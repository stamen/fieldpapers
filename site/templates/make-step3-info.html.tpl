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
        <div id="subnav_container">
            <span class="subnav area">
                <span id="area">
                    <span>1.</span><br>
                    <span><b>AREA</b></span>
                </span>
            </span>
            <span class="subnav info active">
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
    </div>
    <div class="container" style="margin-top: 50px;">            
            <form action="{$base_dir}/make-step4-layout.php" method="POST">
                <p style="margin-bottom: 60px;">
                    <label for="atlas_title" style="font-size: 22px;">Give Your Atlas a Name</label>
                    <br>
                    <input style="margin-top: 10px; color: grey;" type="text" id='title_input' name="atlas_title" size="60"
                           placeholder="Untitled" value="{$atlas_data.atlas_title|escape:hexentity}">
                </p>
                <p>
                    <label for="atlas_text" style="font-size: 16px"><b>Page Text</b> (<i>This is optional.</i>)</label>
                </p>
                <p>Add text to each page in your atlas, like a questionnaire or a site survey form.</p>
                <p>
                    <textarea name="atlas_text" rows="10" style="font-size: 16px; width: 40em;" placeholder="Text to print with each page of your atlas">{$atlas_data.atlas_text|escape:hexentity}</textarea>
                </p>
                
                <p>
                    <label><input name="private" type="checkbox" {if $atlas_data.private}checked{/if}> Make this atlas private. (That means it's only accessible to you, if you're logged in, or by direct URL.)</label>
                </p>
                
                <input type="hidden" id="page_zoom" name="page_zoom" value="{$atlas_data.page_zoom|escape}">
                <input type="hidden" id="paper_size" name="paper_size" value="{$atlas_data.paper_size|escape}">
                <input type="hidden" id="orientation" name="orientation" value="{$atlas_data.orientation|escape}">
                <input type="hidden" id="provider" name="provider" value="{$atlas_data.provider|escape}">

                {foreach from=$atlas_data.pages item="page" key="index"}
                    <input type="hidden" name="pages[{$index|escape}]" value="{$page|escape}">
                {/foreach}
                
                <div style="float: right; margin-top: 60px;">
                    <input type="submit" value="Next">
                </div>
            </form>
            
            {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
