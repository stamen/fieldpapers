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
    {include file="navigation.htmlf.tpl"}
    <div class="container">
        {if $form.parsed}
            <h2>{$form.title}</h2>
            <h3>Created by {$form.user_name} on {$form.created|date_format}</h3>
            
            {if $fields|@count == 0}
                <p>We did not find any inputs on this form.</p>
            {/if}
            
            {if $fields|@count >= 1}
                {if field|@count == 1}
                    <p>There is <b>{$fields|@count}</b> input on this form:  
                {else}
                    <p>There are <b>{$fields|@count}</b> inputs on this form: 
                {/if}
                    <ul>
                        {foreach from=$fields item="field"}
                            {if isset($field.type) && isset($field.label)}
                                <li>A {$field.type} element labeled <b>{$field.label}</b></li>
                            {/if}
                            
                            {if !isset($field.label)}
                                <li>A {$field.type} element with no label</li>
                            {/if}
                        {/foreach}
                    </ul>
                </p>
            {/if}
            <p><a href="{$base_dir}/make-set-area.php?form_id={$form.id|escape}">Make</a> an atlas with this form.</p>
        {else}
            <p>Preparing your form.</p>
            <p>
                This may take a while, generally a few minutes. You don't need to keep this
                window open; you can <a href="{$base_dir}/form.php?id={$form.id|escape}">bookmark 
                this page</a> and come back later.
            </p>
        {/if}
        
        {include file="footer.htmlf.tpl"}
    </div>
</body>
</html>