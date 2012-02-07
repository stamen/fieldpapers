<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Form - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />    
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    
    {if $form && !$form.parsed}
        <meta http-equiv="refresh" content="5" />
    {/if}
</head>
<body>
    <div class="container">
        <div class="content">
            {include file="header.htmlf.tpl"}
            
            {include file="navigation.htmlf.tpl"}
            
            {if $form.parsed}
                <h2>{$form.title}</h2>
                <h3>Created by {$form.user_name} on {$form.created|date_format}</h3>
                
                {foreach from=$fields item="field"}
                    <label for="{$field.name}"><div><b>{$field.label}</b></div</label>
                    
                    {if $field.type eq 'text'}
                        <div style='margin-top: 10px; margin-bottom: 10px'>
                            <input type="text" name="{$field.name}">
                        </div>
                    {/if}
                    
                    {if $field.type eq 'textarea'}
                        <div style='margin-top: 10px; margin-bottom: 10px'>
                            <textarea name="{$field.name}" rows="8" cols="75""></textarea>
                        </div>
                    {/if}
                {/foreach}
                <!--<pre>{$form|@print_r:1|escape}{$fields|@print_r:1|escape}</pre>-->

            {else}
                <p>Preparing your form.</p>
                <p>
                    This may take a while, generally a few minutes. You don't need to keep this
                    window open; you can <a href="{$base_dir}/form.php?id={$form.id|escape}">bookmark 
                    this page</a> and come back later.
                </p>
            {/if}
            
            {include file="footer.htmlf.tpl"}
        <!-- end .content --></div>
        
    <!-- end .container --></div>
</body>
</html>