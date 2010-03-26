<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>Walking Papers</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/index.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
    <script type="text/javascript" src="{$base_dir}/index.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    {include file="$language/index-top-paragraph.htmlf.tpl"}
    
    <p>
        <img src="{$base_dir}/scan-example.jpg" border="1" />
    </p>
    
    <h2>{strip}
        {if $language == "de"}
            Zuletzt gescannt
        {elseif $language == "nl"}
            Recente scans
        {elseif $language == "es"}
            Últimos scans
        {elseif $language == "fr"}
            Scans récents
        {elseif $language == "ja"}
            最近の取込データ
        {elseif $language == "it"}
            Scansioni recenti
        {else}
            Recent Scans
        {/if}
    {/strip}</h2>
    
    <ol>
        {foreach from=$scans item="rscan"}
            <li>
                {if $rscan.print_place_woeid}
                    <a href="{$base_dir}/scan.php?id={$rscan.id|escape}">
                        <b id="scan-{$rscan.id|escape}">{$rscan.age|nice_relativetime|escape}
                            {if $rscan.will_edit == 'no'}✻{/if}</b>
                        <br />
                        {$rscan.print_place_name|escape}</a>

                {else}
                    <a href="{$base_dir}/scan.php?id={$rscan.id|escape}">
                        <b id="scan-{$rscan.id|escape}">{$rscan.age|nice_relativetime|escape}
                            {if $rscan.will_edit == 'no'}✻{/if}</b></a>
    
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                        {if $rscan.print_latitude && $rscan.print_longitude}
                            var onPlaces_{$rscan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$rscan.id|escape}'))");
                            getPlacename({$rscan.print_latitude|escape}, {$rscan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$rscan.id|escape}');
                        {/if}
                    // ]]>
                    </script>
                {/if}

                {if $rscan.description}
                    <br />
                    {$rscan.description|escape}
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p>{strip}
        <a href="{$base_dir}/scans.php">
            {if $language == "de"}
                Weitere Scans...
            {elseif $language == "nl"}
                Meer scans...
            {elseif $language == "es"}
                Más scans... 
            {elseif $language == "fr"}
                Plus de scans... 
            {elseif $language == "ja"}
                最近の取り込みの続き...
            {elseif $language == "it"}
                Altre scansioni recenti...
            {else}
                More recent scans...
            {/if}
        </a>
    {/strip}</p>
    
    <h2>{strip}
        <a name="make">
            {if $language == "de"}
                Einen Ausdruck erstellen
            {elseif $language == "nl"}
                Een afdruk maken
            {elseif $language == "es"}
                Crear impresión   
            {elseif $language == "fr"}
                Créer une impression
            {elseif $language == "ja"}
                印刷する
            {elseif $language == "it"}
                Stampare
            {else}
                Make A Print
            {/if}
        </a>
    {/strip}</h2>
    
    {include file="$language/index-compose-explanation.htmlf.tpl"}

    <form onsubmit="return getPlaces(this.elements['q'].value, this.elements['appid'].value);">
        <input type="text" name="q" size="24" />

        {if $language == "de"}
            {assign var="label" value="Suchen"}
        {elseif $language == "nl"}
            {assign var="label" value="Zoek"}
        {elseif $language == "es"}
            {assign var="label" value="Buscar"}        
        {elseif $language == "fr"}
            {assign var="label" value="Chercher"}
        {elseif $language == "it"}
            {assign var="label" value="Cerca"}
        {elseif $language == "ja"}
            {assign var="label" value="検索"}
        {else}
            {assign var="label" value="Find"}
        {/if}
        <input class="mac-button" type="submit" name="action" value="{$label}" />
        <input type="hidden" name="appid" value="{$constants.GEOPLANET_APPID|escape}" />
        <span id="watch-cursor" style="visibility: hidden;"><img src="{$base_dir}/watch.gif" align="top" vspace="4" /></span>
    </form>

    <p>
        <a href="#" id="permalink"></a>
    </p>

    <div class="sheet">
        <div id="map"></div>
        <!-- <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div> -->
        <img class="slippy-nav" src="{$base_dir}/slippy-nav.png" width="43" height="57" border="0" alt="up" usemap="#slippy_nav"/>
        <map name="slippy_nav">
            <area shape="rect" alt="out" coords="14,31,28,41" href="javascript:map.zoomOut()">
            <area shape="rect" alt="in" coords="14,14,28,30" href="javascript:map.zoomIn()">
            <area shape="rect" alt="right" coords="29,21,42,35" href="javascript:map.panRight()">
            <area shape="rect" alt="down" coords="14,42,28,56" href="javascript:map.panDown()">
            <area shape="rect" alt="up" coords="14,0,28,13" href="javascript:map.panUp()">
            <area shape="rect" alt="left" coords="0,21,13,35" href="javascript:map.panLeft()">
        </map>
        <div class="dog-ear"> </div>
        <div id="zoom-warning" style="display: none;">
            {if $language == "de"}
                Ein Zoom-Level von <b>14 oder mehr</b> wird für das Erfassen von Details auf Straßenebene empfohlen.
            {elseif $language == "nl"}
                We raden aan een zoom niveau van <b>14 of hoger</b> te kiezen om optimaal gebruik te kunnen maken van de afdruk.
            {elseif $language == "es"}
                Recomendamos un nivel de zoom de <b>14 o más</b> para mapear a nivel de calle.
            {elseif $language == "fr"}
                Un niveau de zoom <b>de 14 ou plus</b> est recommandé pour la cartographie au niveau du quartier.
            {elseif $language == "it"}
                Per una mappatura a livello stradale é raccomandato un livello di zoom <b>maggiore o uguale a 14</b>
            {elseif $language == "ja"}
                ズームレベル<b>14以上</b>が、街路レベルのマッピングには推奨されます。
            {else}
                A zoom level of <b>14 or more</b> is recommended for street-level mapping.
            {/if}
        </div>
    </div>
    
    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[

        var map = makeMap('map', '{$provider|escape:"javascript"}');
        map.setCenterZoom(new mm.Location({$latitude}, {$longitude}), {$zoom});
        
        // {literal}
        
        function onPlaces(res)
        {
            if(document.getElementById('watch-cursor'))
                document.getElementById('watch-cursor').style.visibility = 'hidden';
        
            if(res['places'] && res['places']['place'] && res['places']['place'][0])
            {
                var place = res['places']['place'][0];
                var bbox = place['boundingBox'];
        
                var sw = new mm.Location(bbox['southWest']['latitude'], bbox['southWest']['longitude']);
                var ne = new mm.Location(bbox['northEast']['latitude'], bbox['northEast']['longitude']);
                
                map.setExtent([sw, ne]);

            } else {
                {/literal}
                {if $language == "de"}
                    alert("Sorry, es konnte kein Ort mit diesem Namen gefunden werden.");
                {elseif $language == "es"}
                    alert("Lo sentimos, no hemos encontrado ningún lugar llamado así.");
                {elseif $language == "fr"}
                    alert("Désolé, aucun endroit de ce nom n'a été trouvé.");
                {elseif $language == "nl"}
                    {* nl: WRITE ME *}
                    alert("Sorry, I couldn't find a place by that name.");
                {elseif $language == "ja"}
                    alert("申し訳ありません。その名前の場所は見つけられません。");
                {elseif $language == "it"}
                    alert("Ci dispiace non siamo riusciti a trovare un posto con quel nome.");
                {else}
                    alert("Sorry, I couldn't find a place by that name.");
                {/if}
                {literal}
            }
        }
        
        function setProvider(providerURL)
        {
            var tileURL = function(coord) {
                return providerURL.replace('{X}', coord.column).replace('{Y}', coord.row).replace('{Z}', coord.zoom);
            }
            
            map.setProvider(new mm.MapProvider(tileURL));
            onMapChanged(map);
        }
        
        function setPapersize(paper)
        {
            var sheet = map.parent.parentNode;
            
            // ditch existing paper details
            sheet.className = sheet.className.replace(/\b(portrait|landscape|letter|a4|a3)\b/g, ' ');
        
            if(paper == 'portrait-letter') {
                sheet.className = sheet.className + ' portrait letter';
                map.dimensions = new mm.Point(360, 480 - 24);
            
            } else if(paper == 'portrait-a4') {
                sheet.className = sheet.className + ' portrait a4';
                map.dimensions = new mm.Point(360, 504.897);
            
            } else if(paper == 'portrait-a3') {
                sheet.className = sheet.className + ' portrait a3';
                map.dimensions = new mm.Point(360, 506.200);
            
            } else if(paper == 'landscape-letter') {
                sheet.className = sheet.className + ' landscape letter';
                map.dimensions = new mm.Point(480, 360 - 24);
            
            } else if(paper == 'landscape-a4') {
                sheet.className = sheet.className + ' landscape a4';
                map.dimensions = new mm.Point(480, 303.800);
            
            } else if(paper == 'landscape-a3') {
                sheet.className = sheet.className + ' landscape a3';
                map.dimensions = new mm.Point(480, 314.932);
            }

            map.parent.style.width = parseInt(map.dimensions.x) + 'px';
            map.parent.style.height = parseInt(map.dimensions.y) + 'px';
            map.draw();
        }
        
        // {/literal}
    
    // ]]>
    </script>

    <form action="{$base_dir}/compose.php" method="post" name="bounds">
        <input name="north" type="hidden" />
        <input name="south" type="hidden" />
        <input name="east" type="hidden" />
        <input name="west" type="hidden" />
        <input name="zoom" type="hidden" />

        <p>
            {if $language == "de"}
                Ausrichtung:
            {elseif $language == "nl"}
                Papier oriëntatie:
            {elseif $language == "es"}
                Orientación del papel:
            {elseif $language == "fr"}
                Orientation du papier:
            {elseif $language == "ja"}
                向き:
            {elseif $language == "it"}
                Orientamento del foglio:
            {else}
                Orientation:
            {/if}
            
            <select name="paper" onchange="setPapersize(this.value);">
                {foreach from=$paper_sizes item="size"}
                    {if $language == "de"}
                        {assign var="label" value="Hochformat ($size)"}
                    {elseif $language == "nl"}
                        {assign var="label" value="Staand ($size)"}
                    {elseif $language == "es"}
                        {assign var="label" value="Retrato ($size)"}
                    {elseif $language == "fr"}
                        {assign var="label" value="Portrait ($size)"}
                    {elseif $language == "ja"}
                        {assign var="label" value="縦 ($size)"}
                    {elseif $language == "it"}
                        {assign var="label" value="Verticale ($size)"}
                    {else}
                        {assign var="label" value="Portrait ($size)"}
                    {/if}
                    <option label="{$label}" value="portrait-{$size|lower}">{$label}</option>
                {/foreach}
    
                {foreach from=$paper_sizes item="size"}
                    {if $language == "de"}
                        {assign var="label" value="Querformat ($size)"}
                    {elseif $language == "nl"}
                        {assign var="label" value="Liggend ($size)"}
                    {elseif $language == "es"}
                        {assign var="label" value="Paisaje ($size)"}
                    {elseif $language == "fr"}
                        {assign var="label" value="Paysage ($size)"}
                    {elseif $language == "ja"}
                        {assign var="label" value="横 ($size)"}
                    {elseif $language == "it"}
                        {assign var="label" value="Orizzontale ($size)"}
                    {else}
                        {assign var="label" value="Landscape ($size)"}
                    {/if}
                    <option label="{$label}" value="landscape-{$size|lower}">{$label}</option>
                {/foreach}
            </select>
    
            {if $language == "de"}
                {assign var="label" value="Erstellen"}
            {elseif $language == "nl"}
                {assign var="label" value="Samenstellen"}
            {elseif $language == "es"}
                {assign var="label" value="Crear"}
            {elseif $language == "fr"}
                {assign var="label" value="Créer"}
            {elseif $language == "ja"}
                {assign var="label" value="作成"}
            {elseif $language == "it"}
                {assign var="label" value="Crea"}
            {else}
                {assign var="label" value="Make"}
            {/if}
            <input class="mac-button" type="submit" name="action" value="{$label}" />
        </p>
        
        {if $request.get.provider}
            <input type="hidden" name="provider" value="{$provider|escape}" />

        {else}
            <p>
                {if $language == "de"}
                    Kartenstil:
                {elseif $language == "nl"}
                    Provider:
                {elseif $language == "es"}
                    Provider:
                {elseif $language == "fr"}
                    Provider:
                {elseif $language == "ja"}
                    地図供給者:
                {elseif $language == "it"}
                    Provider:
                {else}
                    Provider:
                {/if}
                <select name="provider" onchange="setProvider(this.value);">
                    {assign var="label" value="OpenStreetMap"}
                    <option label="{$label}" selected="selected" value="http://tile.openstreetmap.org/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="OpenStreetMap: CycleMap"}
                    <option label="{$label}" value="http://andy.sandbox.cloudmade.com/tiles/cycle/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="OpenStreetMap: Osmarender"}
                    <option label="{$label}" value="http://tah.openstreetmap.org/Tiles/tile/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Cloudmade: Fineline"}
                    <option label="{$label}" value="http://tile.cloudmade.com/{$constants.CLOUDMADE_KEY|escape}/2/256/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Cloudmade: Fresh"}
                    <option label="{$label}" value="http://tile.cloudmade.com/{$constants.CLOUDMADE_KEY|escape}/997/256/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Cloudmade: No Name"}
                    <option label="{$label}" value="http://tile.cloudmade.com/{$constants.CLOUDMADE_KEY|escape}/3/256/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>

                    {assign var="label" value="Haiti (OpenStreetMap)"}
                    <option label="{$label}" value="http://live.openstreetmap.nl/haiti/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Haiti (Current Satellite Mosaic)"}
                    <option label="{$label}" value="http://maps.nypl.org/tilecache/1/haiti-current/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Haiti (Jan. 16 GeoEye Satellite)"}
                    <option label="{$label}" value="http://maps.nypl.org/tilecache/1/geoeye_100116/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Haiti (Jan. 14-15 IKONOS Satellite)"}
                    <option label="{$label}" value="http://maps.nypl.org/tilecache/1/ikonos_100114/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Haiti (Jan. 13 GeoEye Satellite)"}
                    <option label="{$label}" value="http://maps.nypl.org/tilecache/1/geoeye/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                    
                    {assign var="label" value="Haiti (Digital Globe Crisis Satellite)"}
                    <option label="{$label}" value="http://maps.nypl.org/tilecache/1/dg_crisis/{literal}{Z}/{X}/{Y}{/literal}.png">{$label}</option>
                </select>
            </p>
            <p>
                Grid:
                <input type="radio" name="grid" value="" checked="checked" /> None
                <input type="radio" name="grid" value="utm" /> UTM
                <input type="radio" name="grid" value="mgrs" /> MGRS/USNG
            </p>
        {/if}
    </form>

    <h2>{strip}
        {if $language == "de"}
            Zuletzt gedruckt
        {elseif $language == "nl"}
            Recente afdrukken
        {elseif $language == "es"}
            Últimas impresiones
        {elseif $language == "fr"}
            Impressions récentes
        {elseif $language == "ja"}
            最近の印刷
        {elseif $language == "it"}
            Stampe recenti
        {else}
            Recent Prints
        {/if}
    {/strip}</h2>
    
    <ol>
        {foreach from=$prints item="rprint"}
            <li>
                {if $rprint.place_woeid}
                    <a href="{$base_dir}/print.php?id={$rprint.id|escape}">
                        <b id="print-{$rprint.id|escape}">{$rprint.age|nice_relativetime|escape}</b>
                        <br />
                        {$rprint.place_name|escape} ({$rprint.paper_size|ucwords|escape})</a>

                {else}
                    <a href="{$base_dir}/print.php?id={$rprint.id|escape}">
                        <b id="print-{$rprint.id|escape}">{$rprint.age|nice_relativetime|escape}</b></a>
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                        {if $rprint.latitude && $rprint.longitude}
                            var onPlaces_{$rprint.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('print-{$rprint.id|escape}'))");
                            getPlacename({$rprint.latitude|escape}, {$rprint.longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$rprint.id|escape}');
                        {/if}
                    // ]]>
                    </script>
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p>{strip}
        <a href="{$base_dir}/prints.php">
            {if $language == "de"}
                Weitere Ausdrucke...
            {elseif $language == "nl"}
                Meer recente afdrukken...
            {elseif $language == "es"}
                Más impresiones...
            {elseif $language == "fr"}
                Plus d'impressions récentes...
            {elseif $language == "ja"}
                最近の印刷の続き...
            {elseif $language == "it"}
                Altre stampe recenti...
            {else}
                More recent prints...
            {/if}
        </a>
    {/strip}</p>
    
    <p>
        <a href="http://www.flickr.com/photos/junipermarie/4133315811/" title="IMG_4806.JPG by ricajimarie, on Flickr"><img src="{$base_dir}/kibera-scans.jpg" border="1" /></a>
        <br/>
        <a href="http://www.flickr.com/photos/junipermarie/4133315811/" title="IMG_4806.JPG by ricajimarie, on Flickr">Walking Papers in Kibera</a>
        by <a href="http://www.flickr.com/photos/junipermarie/">ricajimarie on Flickr</a>
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
