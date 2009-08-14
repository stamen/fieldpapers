<h2>About Walking Papers</h2>

<p>
    OpenStreetMap, the wiki-style map of the world that anyone can edit, is in need of a new way to add content. Walking Papers is a way to “round trip” map data through paper, to make it easier to perform the kinds of eyes-on-the-street edits that OSM needs now the most, as well as distributing the load by making it possible for legible, easy notes to be shared and turned into real geographical data. 
</p>
<p>
    Walking Papers is a working service that implements this paper idea, based on <a href="http://mike.teczno.com/notes/walking-papers.html">
    initial technical experimentation</a> from back in February. 
</p>

<h3>Three Kinds Of Mapping</h3>

<p>
    A rough road network of the United States has been basically complete in OSM for some time now, since the bulk import of the US Census TIGER/Line data set. This means that U.S. mapping parties can be slightly counterproductive: the party format was designed for places where raw GPS traces are needed most of all, and participants frequently create fresh data for a given location for the very first time. You show up, are given a handheld GPS device, quickly schooled in its use, and sent out on foot or bicycle or car to collect traces of nearby roads and pathways. 
</p>
<p>
    Because we taxpayers have funded the creation of free, public data for every road in the U.S., raw roads generally already exist in the database. TIGER data can be inaccurate, but with the gracious licensing of Yahoo aerial tile imagery, it’s possible to correct misplaced roads without actually leaving your desk - simply use OSM’s built-in editor to move streets around until they match those seen on the underlying satellite imagery. This kind of gardening or tending activity can be great fun in an <a href="http://en.wikipedia.org/wiki/Obsessive%E2%80%93compulsive_disorder">OCD</a> sort of way, and we’ve personally killed many hours moving nodes here and there to improve the accuracy of street grids. 
</p>
<p>
    There’s a third form of map editing that is best addressed by paper, and that is the annotation of local, eye-level features that would be invisible on an aerial image, meaningless in the absence of base road data, and impossible to collect without a site visit: street lights, bike shops, restrooms, cash machines, stairs, cafes, pubs, addresses, and other bits of geographic context that make OpenStreetMap such a strong contender with the larger, commercial services at a human scale. 
</p>

<h3>Fixing #3</h3>

<p>
    Currently, there aren’t any methods in place specifically designed to address this third kind of casual local mapping. 
</p>
<p>
    Walking Papers is a website and a service designed to close this final loop by providing OpenStreetMap print maps that can be marked up with a pen, scanned back into the computer, and traced using OSM’s regular web-based editor, Potlatch. It’s designed for the casual mapper who doesn’t want to fill their pockets with gadgets to record what’s around them, the social mapper who might be out and about taking notes and comparing them with friends, and the opportunistic mapper who might make notes during a commute or a walk if they had a notebook-sized slip of paper to write on. Finally, it’s designed for the luddite mapper who would like to help the OpenStreetMap project but needs help from a distributed community to convert their handwritten annotations into OpenStreetMap’s tagged data and local conventions. 
</p>
<p>
    We’re trying to bridge some of these uses with web service opportunism and old-fashioned undigital fulfillment. Each scanned map is reverse-geocoded using Flickr’s 
    <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">flickr.places.findByLatLon API feature</a>, which coughs up a meaningful local name for a given geographical area so you can look at a collection of everyone’s scans and perhaps recognize a place you know and might help trace. Each print and scan action is also backed by a (possibly optimistic) promise to snail-mail printed maps to users, and to accept snail-mailed annotated maps in return. If you want to play neogeography pen-pal or simply don’t have a scanner at your disposal, Walking Papers can help. 
</p>

<h3>Context</h3>
<p>
    The project is most particularly inspired by <a href="http://aaronland.info/">Aaron Cope of Flickr</a> and <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>, whose <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> and <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> help all this post-digital, medieval technology make sense.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
