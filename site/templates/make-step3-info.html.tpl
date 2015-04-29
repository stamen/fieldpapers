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
    <div class="smallContainer">
        <h2>Name/Description</h2>
            <form action="{$base_dir}/make-step4-layout.php" accept-charset="utf-8" method="POST">
                <p>
                    <label for="atlas_title">Give Your Atlas a Name</label>
                    <br/>
                    <input type="text" id='title_input' name="atlas_title" size="60"
                           placeholder="Untitled" value="{$atlas_data.atlas_title|escape}">
                </p>
                <p>
                    <label for="paper_size">Choose a Paper Size</label>
                    <br>
                    <select id="paper_size" name="paper_size">
                      <option value="letter">Letter (8.5 x 11 in)</option>
                      <option value="A4">A4 (8.3 x 11.7 in)</option>
                      <option value="A3">A3 (11.7 x 16.5 in)</option>
                    </select>
                </p>
                <p>
                    <label for="atlas_text">Add <i>optional</i> text to each page?</label>
                    <br/>
                    <small>Text you enter will show up next to each map in the atlas</small>
                </p>
                <p>
                    <textarea name="atlas_text" rows="10" style="width:100%;">{$atlas_data.atlas_text|escape}</textarea>
                </p>
                
                <p>
                    <label><input name="private" type="checkbox" {if $atlas_data.private}checked{/if}> Make this atlas private.</label>
                    <br/>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small>(That means it's only accessible to you, if you're logged in, or by direct URL.)</small>
                </p>
                
                
                <input type="hidden" id="page_zoom" name="page_zoom" value="{$atlas_data.page_zoom|escape}">
                <input type="hidden" id="orientation" name="orientation" value="{$atlas_data.orientation|escape}">
                <input type="hidden" id="provider" name="provider" value="{$atlas_data.provider|escape}">
                
                {if $atlas_data.clone_id}
                    <input type="hidden" id="clone_id" name="clone_id" value="{$atlas_data.clone_id|escape}">
                {/if}
                
                {if $atlas_data.refresh_id}
                    <input type="hidden" id="refresh_id" name="refresh_id" value="{$atlas_data.refresh_id|escape}">
                {/if}

                {foreach from=$atlas_data.pages item="page" key="index"}
                    <input type="hidden" name="pages[{$index|escape}]" value="{$page|escape}">
                {/foreach}
                
                <div style="float: right; margin-top: 20px;">
                    <input class='btn' type="submit" value="Next">
                </div>
            </form>
    </div>
    <div class='container'>
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>
