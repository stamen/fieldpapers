<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>About - fieldpapers.org</title>    
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
<!--     <link rel="stylesheet" href="{$base_dir}/css/bootstrap.css" type="text/css"> -->
</head>
<body>         
    {include file="navigation.htmlf.tpl"}
    <div class="smallContainer">
        {literal}
        <h2>About Field Papers</h2>
        <p>
            Field Papers allows you to print a multipage paper atlas of anywhere in the world and take it outside, offline, in the field. You can scribble on it, draw things, make notes. 
        </p>
        <p>
            When you upload a snapshot of your print to Field Papers, we'll do some magic on the server to put it back in the right spot on the map. You can transcribe your notes into digital form and share the result with your friends or download the notes for later analysis.
        </p>
        <p>
            You don't need a <a href="http://en.wikipedia.org/wiki/Global_Positioning_System">GPS</a> to make a map or learn complicated desktop <a href="http://en.wikipedia.org/wiki/Geographic_information_system">GIS</a> software to use Field Papers. It's as easy as print, mark, scan.
        </p>
        <p>
            This project is a continuation of <a href="http://walkingpapers.org">Walking Papers</a>, which was built for the OpenStreetMap (OSM) editing community. Field Papers allows you to print multiple-page atlases using several map styles (including satellite imagery and black and white cartography to save ink) and has built in note annotation tools with GIS format downloads. Field Papers also supports user accounts so you can save “your stuff” for later, or use the service anonymously. Maps from the two systems work together if you want OSM editing (see below).
        </p>
        <p>
            Curious about <a href="http://openstreetmap.org">OpenStreetMap</a>? It's a wiki-style map of the world that anyone can edit and it needs your help to add content. Field Papers and Walking Papers both provide tools to “round trip” map data through paper, to make it easier to perform the kinds of eyes-on-the-street edits, as well as distributing the load by making it possible for legible, easy notes to be shared and turned into real geographical data. Don't see your street on OpenStreetMap? Please add it! 
        </p>

        <h2>Advanced Tools</h2>
        <p>
            Field Papers offers several automation and map customization tools. These tools and workflows are provided for technical users and limited to no supported is provided. If a feature is important to you, we're available for hire. Send a request to info@stamen.com describing your proposal.
        </p>
        <ol>
            <li>
            <p>
                <strong><a href="http://fieldpapers.org/make-canned-atlas-template.html">Atlas Template Tool</a></strong> - Field Papers includes a HTML form based template API that you can host anywhere and populate with preset values for each use case. The form posts those parameters to Field Papers and populates each phase of the make atlas process with those values, while allowing the user to modify the area of interest, etc.
            </p>
            </li>
            <li>
            <p>
                <strong><a href="http://fieldpapers.org/make-geojson-atlas-form.html">Incident Maps</a></strong> - Field checking a list of feature locations? Upload a list of locations in GeoJSON format and we'll center an atlas page on each incident to give you a head start and liberate you from the atlas page grid.
            </p>
            </li>
            <li>
            <p>
                <strong>Custom Map Styles</strong> - <a href="http://fieldpapers.org/upload_mbtiles.php">MBTiles Uploader Tool</a> - Use <a href="http://mapbox.com/tilemill/">TileMill</a> to design your own basemap or leverage existing ArcGIS geodata via <a href="http://www.arc2earth.com/">Arc2Earth</a> to export maps out of ArcMap in the MapBoxTiles SQLite data <a href="http://mapbox.com/mbtiles-spec/">format</a> and upload them for use on Field Papers. You'll need to be logged into Field Papers to save these to your account and have them available in the make atlas process.
            </p>
            </li>
            <li>
            <p>
                <strong>Custom Map Styles</strong> - <a href="http://fieldpapers.org/make-canned-atlas-template.html">TMS endpoints</a> - Already published your basemap online as a tiled map service? Use our template tool detailed above to point to the TMS endpoint. Example: <a href="http://tile.stamen.com/watercolor/{Z}/{X}/{Y}.jpg">http://tile.stamen.com/watercolor/{Z}/{X}/{Y}.jpg</a>.
            </p>
            </li>
            <li>
            <p>
                <strong>Edit in OSM</strong> - Field Papers plays well with others. If you upload a snapshot of your map at <a href="http://walkingpapers.org">Walking Papers</a>, you can use the tools there to edit OpenStreetMap in Potlatch and JOSM using your snapshot as a reference layer. Common tasks include adding streets, parks, building outlines, addresses, business names, and more.
            </p>
            </li>
            <li>
            <p>
                <strong>GIS Analysis</strong> - Need to perform advanced spatial analysis or add structured data? Download your notes in Esri Shapefile format (SHP) or GeoJSON (geographic projection) from each Atlas page. We also offer a GeoTIFF download (in web Mercator projection) of each atlas page snapshot, also from the Atlas page's activity stream. These files can be used in desktop applications like <a href="http://www.qgis.org/">QGIS</a> or <a href="http://www.esri.com/software/arcgis/index.html">ArcGIS</a>.
            </p>
            </li>
            <li>
            <p>
                <strong>Unstructured Text</strong> - FIeld Papers allows you to write notes about each feature when it’s added to the map.
            </p>
            </li>
            <li>
            <p>
                <strong>Structured Data</strong> - Need to store structured form data about each map feature? Field Papers provides a large text field and you have two options: (a) use key:value pairs or (b) enter a uniqueID for a data join in a desktop GIS app with a worksheet of structured form data. An example of a <strong>key:value pair</strong> entered into the notes widget: type:park, name:Golden Gate, about:Large urban park with museums and buffalo. You can use another program outside of Field Papers to split those into separate columns. An example of a <strong>uniqueID</strong> is using a series of sequential numbers (1, 2, 3) entered into the notes widget like: 1. You'd fill out a separate stack of structured data "forms" about each feature in the field, marking the sequential uniqueID onto the map, onto it's form, filling out the form. Back at the computer, you'd add a note for each feature on Field Papers, noting the uniqueID. You'd transcribe the forms into a worksheet using OpenOffice or Excel noting both the uniqueID and the structured data about that feature. Download the GeoJSON or SHP from Field Papers, export your worksheet data, and use a program like <a href="http://www.qgis.org/">QGIS</a> or <a href="http://www.esri.com/software/arcgis/index.html">ArcGIS</a> to "join" the two together. 
            </p>
            </li>
            <li>
            <p>
                <strong><a href="https://github.com/stamen/fieldpapers">Fork us on Github</a></strong> - Field Papers in an open source project hosted at Github.
            </p>
            </li>
        </ol>

        <h2>Inspiration</h2>
        <p>
            The project is most particularly inspired by <a href="http://aaronland.info/">Aaron Cope then of Flickr</a> and <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>, whose <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> and <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> help all this post-digital, medieval technology make sense.
        </p>
        {/literal}
        
        <div class="clearfloat"></div>

</div>
<div class="container">
	{include file="footer.htmlf.tpl"}
</div>
</body>
</html>