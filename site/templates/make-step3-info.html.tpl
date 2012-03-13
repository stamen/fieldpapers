<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Add Form - fieldpapers.org</title>    
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
            
            .subnav.info {
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
    <div class="container" style="margin-top: 50px;">            
            <form action="{$base_dir}/make-layout.php" method="POST">
                <p style="margin-bottom: 60px;">
                    <label for="atlas_title" style="font-size: 22px;">Give Your Atlas a Name</label>
                    <br>
                    <input style="margin-top: 10px; color: grey;" type="text" id='title_input' name="atlas_title" size="60"
                           placeholder="Untitled">
                </p>
                <p>
                    If you like, you can also add a document to go alongside each page 
                    in your atlas, like a questionnaire or a site survey form. 
                    Field Papers can import forms created in 
                    <a href="http://docs.google.com">Google Docs</a>. Just 
                    enter the URL to your Google form, and we'll do the rest.
                </p>
                <p>
                    <label for="form_input" style="font-size: 16px"><b>Google Form URL</b> (<i>This is Optional.</i>)</label>
                    <br>
                    <input style="margin-top: 10px; color: grey;" type="text" id='form_input' name="form_url" size="60"
                            placeholder="http://">
                </p>
                <p>
                    Your recent forms:
                    <select name="form_id">
                        {foreach from=$forms item="form"}
                            {assign var="domain" value=$form.form_url|regex_replace:"#^https?://([^/]+)/.+$#":"(\\1)"}
                            <option value="{$form.id|escape}" label="{$form.title|escape} {$domain|escape}">{$form.title|escape} {$domain|escape}</option>
                        {/foreach}
                    </select>
                </p>
                
                <input type="hidden" id="page_zoom" name="page_zoom" value="{$atlas_data.page_zoom}">
                <input type="hidden" id="paper_size" name="paper_size" value="{$atlas_data.paper_size}">
                <input type="hidden" id="orientation" name="orientation" value="{$atlas_data.orientation}">
                <input type="hidden" id="provider" name="provider" value="{$atlas_data.provider}">

                {foreach from=$atlas_data.pages item="page" key="index"}
                    <input type="hidden" name="pages[{$index}]" value="{$page}">
                {/foreach}
                
                <div style="float: right; margin-top: 60px;">
                    <input type="submit" value="Next">
                </div>
            </form>
            
            {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>