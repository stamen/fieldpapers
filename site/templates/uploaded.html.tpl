<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>{strip}
        {if $language == "de"}
            Scan hochgeladen
        {elseif $language == "nl"}
            WRITE ME
        {else}
            Uploaded Scan
        {/if}
    {/strip} (Walking Papers)</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        form label
        {
            font-weight: bold;
        }
    
    /* {/literal}]]> */
    </style>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>
		{if $language == "de"}
			Du hast eine gescannte Karte hochgeladen
		{elseif $language == "nl"}
            WRITE ME
        {else}
			You’ve Uploaded A Scanned Map
		{/if}	
		</h2>
    
    <p>
		{if $language == "de"}
            Du hast eine gescannte Karte hochgeladen, bitte füge ein paar 
			Informationen hinzu bevor du fortfährst.
        {elseif $language == "nl"}
            WRITE ME
        {else}
			You’ve just uploaded a scanned map, and you’re about to add
			a few bits of information about before you proceed to trace it.
		{/if}
    </p>
    
    <form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post" enctype="multipart/form-data">
        {*
        <p>
            {if $language == "de"}
				privat?
			{elseif $language == "nl"}
				WRITE ME
			{else}
				private?
			{/if}
            <input type="checkbox" value="yes" name="is_private" {if $scan.is_private == 'yes'}checked="checked"{/if} />
        </p>
        *}
    
        <p>
            <label>
                {if $language == "de"}
					Planst du dies selbst zu bearbeiten?
				{elseif $language == "nl"}
					WRITE ME
				{else}
					Do you plan to edit this yourself?
				{/if}
                <select name="will_edit">
                    {if $language == "de"}
                        {assign var="label" value="Ja"}
                    {elseif $language == "nl"}
                        {assign var="label" value="WRITE ME"}
                    {else}
                        {assign var="label" value="Yes"}
                    {/if}	
                    <option label="{$label}" value="yes" {if $scan.will_edit == 'yes'}selected="selected"{/if}>{$label}</option>
                    {if $language == "de"}
                        {assign var="label" value="Nein"}
                    {elseif $language == "nl"}
                        {assign var="label" value="WRITE ME"}
                    {else}
                        {assign var="label" value="No"}
                    {/if}	
                    <option label="{$label}" value="no"  {if $scan.will_edit == 'no'}selected="selected"{/if}>{$label}</option>
                </select>
            </label>
            <br />
				{if $language == "de"}
					Du musst die Bearbeitung für OpenStreetmap nicht selbst durchführen.
					Mit "Nein" zeigst du anderen Beteiligten, dass sie bei der Bearbeitung
					des Scans mithelfen können.
				{elseif $language == "nl"}
					WRITE ME
				{else}
					You don’t have to do your own OpenStreetMap editing. Saying “no”
					will let other visitors know about scans they can help with.
				{/if}
        </p>
    
        <p>
            <label for="description">
				{if $language == "de"}
					Beschreibe deine Ergänzungen.
				{elseif $language == "nl"}
					WRITE ME
				{else}
					Describe your additions.
				{/if}
				</label>
            <br />
				{if $language == "de"}
					Hast du Geschäfte hinzugefügt, Fußwege korrigiert, Ampeln markiert oder
					Briefkästen eingetragen? Hier kannst du deine Änderungen beschreiben.
				{elseif $language == "nl"}
					WRITE ME
				{else}
					Did you add businesses, fix footpaths, mark traffic lights, outline parks,
					place mailboxes? Write a few words about the changes to this area.
				{/if}
            <br />
            <textarea name="description" rows="10" cols="40">{$scan.description|escape}</textarea>
        </p>
    
        <input class="mac-button" type="submit" value="Save">
    </form>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
