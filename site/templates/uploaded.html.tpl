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
        {elseif $language == "es"}
            Scan subido
        {elseif $language == "fr"}
            Scan envoyé
        {elseif $language == "ja"}
            アップロードした取込データ
        {elseif $language == "it"}
            Scansione inviata
        {elseif $language == "tr"}
            Yüklenmiş Tarama
        {elseif $language == "ru"}
            Загруженный скан
        {elseif $language == "sv"}
        	Uppladdad inskanning
        {elseif $language == "id"}
        	Hasil scan yang telah diunggah
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
        {elseif $language == "es"}
            Has subido un mapa escaneado
        {elseif $language == "fr"}
            Vous avez envoyé une carte scannée.
        {elseif $language == "ja"}
            スキャンしたアップロードしました
        {elseif $language == "it"}
            Hai spedito una mappa scannerizzata.
        {elseif $language == "tr"}
            Bir Taramış Haritasını Yükledin
        {elseif $language == "ru"}
            Вы загрузили отсканированную карту
        {elseif $language == "sv"}
        	Du har laddat upp en inskannad karta
        {elseif $language == "id"}
        	Anda Telah Mengunggah Peta Hasil Scan
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
        {elseif $language == "es"}
            Has subido un mapa escaneado y ahora vas a dar un poco de información adicional antes de proceder a tracearlo.
        {elseif $language == "fr"}
            Vous venez juste d'envoyer une carte scannée, et vous êtes sur le point de renseigner quelques informations
            avant de commencer à la tracer.
        {elseif $language == "ja"}
            スキャナーした地図をアップロードしました。そして、トレースを行う前に若干の情報を追加する段階になりました。
        {elseif $language == "it"}
            Hai appena spedito una mappa scannerizzata e stai per aggiungere un paio di informazioni prima di iniziare a tracciarla.
        {elseif $language == "tr"}
			Sen taranmış bir harita yükledin ve onu dayandırmaya devam etmeden önce onun hakkında birkaç ayrıntıyı eklemek üzeresin.
        {elseif $language == "ru"}
			Вы загрузили отсканированную карту и вам осталось добавить немного
            информации о ней, перед тем как перейти к оцифровке.
        {elseif $language == "sv"}
            Du har nu laddat upp en inskannad karta, och nu behöver du lägga till
            lite mer information om den innan du kan fortsätta.
        {elseif $language == "id"}
            Anda baru saja mengunggah peta yang telah discan, berikutnya Anda akan menambahkan sedikit informasi mengenai peta tersebut sebelum ditandai.
        {else}
            You’ve just uploaded a scanned map, and you’re about to add
            a few bits of information about it before you proceed to trace it.
        {/if}
    </p>
    
    <form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post" enctype="multipart/form-data">
        {*
        <p>
            {if $language == "de"}
                privat?
            {elseif $language == "nl"}
                privé?
            {elseif $language == "es"}
                ¿privado?
            {elseif $language == "fr"}
                privé ?
            {elseif $language == "ja"}
                プライベート?
            {elseif $language == "it"}
                privato?
            {elseif $language == "tr"}
                kişisel mi?
            {elseif $language == "ru"}
                только для вас?
            {elseif $language == "sv"}
            	privat?
            {elseif $language == "id"}
            	milik pribadi?
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
                {elseif $language == "es"}
                    ¿Vas a editar esto tú mismo?
                {elseif $language == "fr"}
                    Avez-vous l'intention de la modifier vous-même ?
                {elseif $language == "ja"}
                    この地図をご自身で編集する予定ですか？
                {elseif $language == "it"}
                    Hai intenzione di iniziarla a modificare tu?
                {elseif $language == "tr"}
					Bunu kendi kendine düzeltmeye planlanıyor musun?
                {elseif $language == "ru"}
					Вы планируете редактировать карту сами?
				{elseif $language == "sv"}
					Tänker du redigera denna själv?
                {elseif $language == "id"}
										Apakah Anda berencana untuk mengedit kembali?
                {else}
                    Do you plan to edit this yourself?
                {/if}
                <select name="will_edit">
                    {if $language == "de"}
                        {assign var="label" value="Ja"}
                    {elseif $language == "nl"}
                        {assign var="label" value="Ja"}
                    {elseif $language == "es"}
                        {assign var="label" value="Sí"}    
                    {elseif $language == "fr"}
                        {assign var="label" value="Oui"}
                    {elseif $language == "ja"}
                        {assign var="label" value="はい"}
                    {elseif $language == "it"}
                        {assign var="label" value="Si"}
                    {elseif $language == "tr"}
                        {assign var="label" value="Evet"}
                    {elseif $language == "ru"}
                        {assign var="label" value="Да"}
                    {elseif $language == "sv"}
                        {assign var="label" value="Ja"}
                    {elseif $language == "id"}
                        {assign var="label" value="Ya"}
                    {else}
                        {assign var="label" value="Yes"}
                    {/if}    
                    <option label="{$label}" value="yes" {if $scan.will_edit == 'yes'}selected="selected"{/if}>{$label}</option>
                    {if $language == "de"}
                        {assign var="label" value="Nein"}
                    {elseif $language == "nl"}
                        {assign var="label" value="Nee"}
                    {elseif $language == "es"}
                        {assign var="label" value="No"}
                    {elseif $language == "fr"}
                        {assign var="label" value="Non"}
                    {elseif $language == "ja"}
                        {assign var="label" value="いいえ"}
                    {elseif $language == "it"}
                        {assign var="label" value="No"}
                    {elseif $language == "tr"}
                        {assign var="label" value="Hayır"}
                    {elseif $language == "ru"}
                        {assign var="label" value="Нет"}
                    {elseif $language == "sv"}
                        {assign var="label" value="Nej"}
                    {elseif $language == "id"}
                        {assign var="label" value="Tidak"}
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
                {elseif $language == "es"}
                    No tienes que hacer tus propias modificaciones a OpenStretMap. Decir "no" permitirá a otros visitantes saber con qué scans pueden colaborar.
                {elseif $language == "fr"}
                    Vous n'avez pas à faire vos propres modifications dans OpenStreetMap. Choisir “Non”
                    indiquera aux visiteurs quels scans ils pourront utiliser pour aider.
                {elseif $language == "ja"}
                    ご自身で、OpenStreetMapの編集を行う必要はありません。ここで"no"と答えれば、他の訪問者がこのスキャン結果について知ることができ、助けることができます。
                {elseif $language == "it"}
                    Non devi effettuare le modifiche OpenStreetMap. Rispondendo “no” renderai a conoscenza gli altri visitatori di scansioni che potrebbero beneficiare del loro aiuto.
                {elseif $language == "tr"}
					Kendi kendine OpenStreetMap düzeltmek zorunda değilsin. "Hayır" diyerek yardım edebilecek taramalar konusunda başka ziyaretciyi haberdar eder.
                {elseif $language == "ru"}
					Вам не обязательно самим редатировать карту. Ответив “нет”
                    позволит другим пользователям узнать о вашем скане и поработать над ним.
                {elseif $language == "sv"}
                	Du behöver inte redigera OpenStreetMap själv; Om du svarar "Nej"
                	så vet andra besökare vilka inskanningar de kan hjälpa till med.
                {elseif $language == "id"}
                	Anda tidak harus melakukan proses editing OpenStreetMap sendiri. Pilih "Tidak" berarti Anda memperbolehkan pengguna lain mengetahui hasil scan dan membantu dalam proses editing.
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
                {elseif $language == "es"}
                    Describe tus modificaciones.    
                {elseif $language == "it"}
                    Descrivi le tue modifiche.
                {elseif $language == "tr"}
                    Describe your additions.
                {elseif $language == "ru"}
                    Опишите ваши добавления.
                {elseif $language == "sv"}
                    Beskriv dina tillägg.
                {elseif $language == "id"}
                    Jelaskan tambahan yang Anda buat.
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
                {elseif $language == "es"}
                    ¿Has añadido negocios, corregido aceras, señalado semáforos, delineado parques, colocado buzones de correos? Describe en pocas palabras tus modificaciones a éste área.
                {elseif $language == "it"}
                    Hai aggiunto negozi, marciapiedi, segnato semafori, delimitato parchi, posizionato buche delle lettere? Scrivi un paio di parole a proposito delle modifiche in quest'area.
                {elseif $language == "tr"}
					Dükkanlar yükedin mi, yaya yolları düzelttin mi, trafik lambaları etiketlendin mi, park kenarları çizdin mi? Bu yere değişiklerinle ilgili birkaç söz yaz.
                {elseif $language == "ru"}
					Что вы добавили? Офисы, исправленные дороги, сигналы дорожного движения,
                    парки, почтовые ящики? Добавьте несколько слов про ваши изменения.
                {elseif $language == "sv"}
                    La du till affärer, korrigerade gångvägar, markerade trafikljus, ritade in en park,
                    eller placerade brevlådor? Skriv några få ord om ändringarna på detta område.
								{elseif $language == "id"}
                    Apakah Anda menambahkan objek bisnis, memperbaiki jalan setapak, menandai lampu lalu lintas, menandai kawasan taman, menandai kotak surat? Tulis beberapa kata mengenai perubahan yang Anda buat pada wilayah ini.
                {else}
                    Did you add businesses, fix footpaths, mark traffic lights, outline parks,
                    place mailboxes? Write a few words about the changes to this area.
                {/if}
            <br />
            <textarea name="description" rows="10" cols="40">{$scan.description|escape}</textarea>
        </p>
        
        {if $language == "de"}
            {assign var="label" value="Speichern"}
        {elseif $language == "fr"}
            {assign var="label" value="Enregistrer"}
        {elseif $language == "nl"}
            {* nl: WRITE ME *}
            {assign var="label" value="Save"}
        {elseif $language == "ja"}
            {assign var="label" value="保存"}
        {elseif $language == "es"}
            {assign var="label" value="Guardar"}
        {elseif $language == "it"}
            {assign var="label" value="Salva"}
        {elseif $language == "tr"}
            {assign var="label" value="Kaydet"}
        {elseif $language == "ru"}
            {assign var="label" value="Сохранить"}
        {elseif $language == "sv"}
            {assign var="label" value="Spara"}
        {elseif $language == "id"}
            {assign var="label" value="Simpan"}
        {else}
            {assign var="label" value="Save"}
        {/if}
        <input class="mac-button" type="submit" value="{$label}">
    </form>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
