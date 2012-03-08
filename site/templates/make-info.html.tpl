<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Add Form - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
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
    
    <script type="text/javascript">
        {literal}
            function setValue(value)
            {
                if (value === 'Untitled')
                {
                    document.getElementById('title_input').value = '';
                }
                
                if (value === 'http://')
                {
                    document.getElementById('form_input').value = '';
                }
            }
        {/literal}
    </script>
</head>
<body>      
    {include file="navigation.htmlf.tpl"}
    <div style="width: 100%; text-align: center;">
        <span class="subnav area">
            <span id="area">
                <span>1.</span><br />
                <span><b>AREA</b></span>
            </span>
        </span>
        <span class="subnav info">
            <span>
                <span>2.</span><br />
                <span><b>INFO</b></span>
            </span>
        </span>
        <span class="subnav layout">
            <span>
                <span>3.</span><br />
                <span><b>LAYOUT</b></span>
            </span>
        </span>
    </div>
    <div class="container" style="margin-top: 50px;">            
            <form action="{$base_href}" method="POST">
                <p style="margin-bottom: 60px;">
                    <span style="font-size: 22px;">Give Your Atlas a Name</span><br />
                    <input style="margin-top: 10px; color: grey;" type="text" id='title_input' name="atlas_title" size="60"
                           value="Untitled" onFocus="setValue(this.value);"/>
                </p>
                <p>
                    If you like, you can also add a document to go alongside each page 
                    in your atlas, like a questionnaire or a site survey form. 
                    Field Papers can import forms created in 
                    <a href="http://docs.google.com">Google Docs</a>. Just 
                    enter the URL to your Google form, and we'll do the rest.
                </p>
                <p>
                    <span style="font-size: 16px"><b>Google Form URL</b> (<i>This is Optional.</i>)</span><br />
                    <input style="margin-top: 10px; color: grey;" type="text" id='form_input' name="form_url" size="60"
                            value="http://" onFocus="setValue(this.value);"/>
                </p>
                <div style="float: right; margin-top: 60px;">
                    <input type="submit" value="Next" />
                </div>
            </form>
            
            {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>