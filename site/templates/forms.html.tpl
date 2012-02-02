<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Recent Forms - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>
    {include file="header.htmlf.tpl"}

    {include file="navigation.htmlf.tpl"}
    
    <h2>Recent Forms</h2>
    
    {assign var="forms_count" value=$forms|@count}
    
    {if $page > 1 and $forms_count > 0}
        <p class="pagination">
            <span class="newer">← <a href="{$base_dir}/forms.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            <span class="older"><a href="{$base_dir}/forms.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        </p>
    {/if}
    
    <ol start="{$offset+1}">
        {foreach from=$forms item="form"}
            <li>
                {if !$form.parsed}
                    <strike>
                        <b id="form-{$form.id|escape}">{$form.age|nice_relativetime|escape}</b></strike>
                
                {else}
                    <a href="{$base_dir}/form.php?id={$form.id|escape}">
                        <b id="form-{$form.id|escape}">{$form.age|nice_relativetime|escape}</b></a>
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                    
                        var onPlaces_{$form.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('form-{$form.id|escape}'))");
                        getPlacename({$form.latitude|escape}, {$form.longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$form.id|escape}');
                
                    // ]]>
                    </script>
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p class="pagination">
        {if $forms_count > 0}
            {if $page > 1}
                <span class="newer">← <a href="{$base_dir}/forms.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            {/if}
            <span class="older"><a href="{$base_dir}/forms.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        {else}
            <span class="newer">← <a href="{$base_dir}/forms.php?perpage={$perpage|escape}&amp;page=1">Newest</a></span>
        {/if}
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
