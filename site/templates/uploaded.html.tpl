<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>{strip}
        {if $language == "de"}
            Scan hochgeladen
        {elseif $language == "nl"}
            Scan uploaden
        {elseif $language == "fr"}
            Scan envoyé
        {elseif $language == "ja"}
	    アップロードした取込データ
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
			Du hast eine eingescannte Karte hochgeladen
		{elseif $language == "nl"}
            		Je hebt een gescande kaart geupload
		{elseif $language == "fr"}
            Vous avez envoyé une carte scannée.
        	{elseif $language == "ja"}
            	    	スキャンしたアップロードしました
	        {else}
			You’ve Uploaded A Scanned Map
		{/if}	
		</h2>
    
    <p>
		{if $language == "de"}
            Du hast eine eingescannte Karte hochgeladen, bitte füge ein paar 
			Informationen hinzu bevor du fortfährst.
        {elseif $language == "nl"}
            Je hebt een gescande kaart geupload, vul de volgende informatie in alvorens je begint met verwerken.
        {elseif $language == "fr"}
            Vous venez juste d'envoyer une carte scannée, et vous êtes sur le point de renseigner quelques informations
            avant de commencer à la tracer.
        {elseif $language == "ja"}
	    スキャナーした地図をアップロードしました。そして、トレースを行う前に若干の情報を追加する段階になりました。
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
				privé?
			{elseif $language == "fr"}
				privé ?
                        {elseif $language == "ja"}
				プライベート?
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
					Wil je zelf de wijzigingen verwerken?
				{elseif $language == "fr"}
					Avez-vous l'intention de la modifier vous-même ?
                                {elseif $language == "ja"}
					この地図をご自身で編集する予定ですか？
				{else}
					Do you plan to edit this yourself?
				{/if}
                <select name="will_edit">
                    {if $language == "de"}
                        {assign var="label" value="Ja"}
                    {elseif $language == "nl"}
                        {assign var="label" value="Ja"}
                    {elseif $language == "fr"}
                        {assign var="label" value="Oui"}
                    {else}
                        {assign var="label" value="Yes"}
                    {/if}	
                    <option label="{$label}" value="yes" {if $scan.will_edit == 'yes'}selected="selected"{/if}>{$label}</option>
                    {if $language == "de"}
                        {assign var="label" value="Nein"}
                    {elseif $language == "nl"}
                        {assign var="label" value="Nee"}
                    {elseif $language == "fr"}
                        {assign var="label" value="Non"}
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
					Je hoeft niet alleen de OpenStreetMap verwerking te doen. “Nee”
					antwoorden geeft andere gebruikers de mogelijkheid te helpen.
				{elseif $language == "fr"}
                    Vous n'avez pas à faire vos propres modifications dans OpenStreetMap. Choisir “Non”
                    indiquera aux visiteurs quels scans ils pourront utiliser pour aider.
                                {elseif $language == "ja"}
					ご自身で、OpenStreetMapの編集を行う必要はありません。ここで"no"と答えれば、他の訪問者がこのスキャン結果について知ることができ、助けることができます。
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
					Beschrijf jou toevoegingen.
				{elseif $language == "fr"}
					Décriver vos ajouts.
				{elseif $language == "ja"}
				あなたの追加した情報を説明してください
				{else}
					Describe your additions.
				{/if}
				</label>
            <br />
				{if $language == "de"}
					Hast du Geschäfte hinzugefügt, Fußwege korrigiert, Ampeln markiert oder
					Briefkästen eingetragen? Hier kannst du deine Änderungen beschreiben.
				{elseif $language == "nl"}
					Heb je bedrijven toegevoegd, voetpaden verbeterd, verkeerslichten aangeduid, parkgrenzen getekend
					Of bijvoorbeeld brievenbussen in kaart gebracht? Beschrijf kort wat jij hebt veranderd.
				{elseif $language == "fr"}
                    Avez-vous ajouté des sociétés, fixé des chemins piétons, ajouté des feux de signalisation, 
                    détouré des parcs, placé des boites à lettres ? Décrivez en quelques mots les changements que vous avez
                    faits sur cette zone.
                                {elseif $language == "ja"}
					商店、歩道の修正、信号機の追加、公園の輪郭、郵便ポストを追加したでしょうか？このエリアでの追加について、このようなコメントをいれてください。
				{else}
					Did you add businesses, fix footpaths, mark traffic lights, outline parks,
					place mailboxes? Write a few words about the changes to this area.
				{/if}
            <br />
            <textarea name="description" rows="10" cols="40">{$scan.description|escape}</textarea>
        </p>
		
		{if $language == "de"}
            {assign var="label" value="Speichern"}
		{if $language == "fr"}
            {assign var="label" value="Enregistrer"}
        {elseif $language == "nl"}
            {* nl: WRITE ME *}
            {assign var="label" value="Save"}
        {elseif $language == "ja"}
            {assign var="label" value="Save"}
        {else}
            {assign var="label" value="Save"}
        {/if}
        <input class="mac-button" type="submit" value="{$label}">
    </form>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
