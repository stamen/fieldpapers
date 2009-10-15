<h2>ウオーキングペーパーについて</h2>

<p>
    ウィキ(Wiki)スタイルの世界地図で、誰でも編集可能なOpenStreetMap(オープンストリートマップ；OSM）には、新しいコンテンツの作成方法が必要でした。ウオーキングペーパー（ Walking Papers）は、紙を通して地図データを"round trip"する方法です。それは、ストリートで見たことを編集することを簡単にします。これは、みんなにもっと使ってもらえるように負荷を分散するのと同じくらい、OSMが現在もっとも必要としている、ノートを共有し、それを実際の地理データへと変換するのを簡単にするということなのです。
</p>
<p>
    ウオーキングペーパー（Walking Papers）は、この（思いつきの）ペーパーアイディアを実装し、２月から始めた実際に稼働するサービスで<a href="http://mike.teczno.com/notes/walking-papers.html">
   初期の技術的実装 実験 </a> です。    
</p>

<h3>３種のマッピング</h3>

<p>
    USの
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
    本プロジェクトは、とくに <a href="http://aaronland.info/">Aaron Cope of Flickr</a> と <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>に影響され着想を得ました。 後者の, <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> 、 <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> は、ポストデジタル時代のmedieval技術が可能にしたものです。
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
