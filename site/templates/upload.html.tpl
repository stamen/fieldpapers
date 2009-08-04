<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Scan hochladen
        {elseif $language == "nl"}
            Scan uploaden
        {elseif $language == "es"}
            Subir scan
        {elseif $language == "fr"}
            Envoyer un scan
        {elseif $language == "ja"}
            スキャナーデータのアップロード
        {elseif $language == "it"}
            Invia una mappa scannerizzata
        {else}
            Upload Scan
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <meta http-equiv="refresh" content="30" />
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    {include file="$language/upload-instructions.htmlf.tpl"}
    
    {if $language == "de"}
        {assign var="label" value="Hochladen"}
    {elseif $language == "fr"}
        {assign var="label" value="Envoyer"}
    {elseif $language == "nl"}
        {* nl: WRITE ME *}
        {assign var="label" value="Send"}
    {elseif $language == "ja"}
        {assign var="label" value="送信"}
    {elseif $language == "es"}
        {assign var="label" value="Enviar"}
    {elseif $language == "it"}
        {assign var="label" value="Invia"}
    {else}
        {assign var="label" value="Send"}
    {/if}

    {if $s3post}
        <form action="http://{$s3post.bucket|escape}.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
            <input name="AWSAccessKeyId" type="hidden" value="{$s3post.access|escape}" />
            <input name="acl" type="hidden" value="{$s3post.acl|escape}" />
            <input name="key" type="hidden" value="{$s3post.key|escape}" />
            <input name="redirect" type="hidden" value="{$s3post.redirect|escape}" />
        
            <input name="policy" type="hidden" value="{$s3post.policy|escape}" />
            <input name="signature" type="hidden" value="{$s3post.signature|escape}" />
            
            <input name="file" type="file" />
            <input class="mac-button" type="submit" value="{$label}" />
        </form>

    {elseif $localpost}
        <form action="{$base_dir}/post-file.php" method="post" enctype="multipart/form-data">
            <input name="dirname" type="hidden" value="{$localpost.dirname|escape}" />
            <input name="redirect" type="hidden" value="{$localpost.redirect|escape}" />
        
            <input name="expiration" type="hidden" value="{$localpost.expiration|escape}" />
            <input name="signature" type="hidden" value="{$localpost.signature|escape}" />
            
            <input name="file" type="file" />
            <input class="mac-button" type="submit" value="{$label}" />
        </form>
    {/if}
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
