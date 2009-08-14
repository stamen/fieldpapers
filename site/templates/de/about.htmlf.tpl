<h2>Über Walking Papers</h2>

<p>
    OpenStreetMap, die freie Wiki-Weltkarte, die von jedem bearbeitet werden kann, benötigt einen neue Möglichkeit, um Daten hinzuzufügen. Walking Papers macht es möglich Daten auf Papier zu entnehmen und wieder hinzuzufügen, damit es einfacher ist, auf der Straße Daten zu bearbeiten und lesbare, einfache Notizen verfügbar zu machen und in geographische Daten umzuwandeln.
</p>
<p>
    Walking Papers ist ein funktionierender Service, der diese Papier-Idee nutzt, basierend auf <a href="http://mike.teczno.com/notes/walking-papers.html">einem ersten technischen Experiment
    </a> im Februar. 
</p>

<h3>Drei verschieden Arten des Erfassens</h3>

<p>
    Ein grobes Straßennetz der USA ist in OpenStreetMap seit dem großen Import der Tiger-Daten bereits vorhanden. Daher sind U.S. Mapping-Partys manchmal widersinnig: das Party-Konzept wurde für Plätze erfunden, wo man hauptsächlich rohe GPS-Tracks benötigt und die Mitwirkenden häufig frische Daten das erste Mal für einen bestimmten Ort hinzufügen. Normalerweise bekommt man eine Einführung in die Benutzung des GPS-Gerätes und sammelt neue Tracks von nahen Straßen und Wegen zu Fuß oder per Rad. 

Auch in Deutschland sind mittlerweile große Teile des Straßennetzes bereits erfasst, wohingegen Details wie Straßennamen, Geschäfte und weitere Details noch fehlen.
</p>
<p>
    Da wir als Steuerzahler die Erstellung von freien, öffentlichen Daten für jede Straße in der USA bezahlt haben, sind große Straßenverläufe meistens bereits in der Datenbasis vorhanden. TIGER-Daten können ungenau sein, aber mit den freundlichen Lizenz der Yahoo Satellitenbildern ist es möglich fehlerhafte Straßen zu korregieren ohne dazu den Schreibtisch zu verlassen - man kann einfach den eingebauten OSM-Editor (Potlatch) nutzen, um die Straßen so zu verschieben, damit sie die darunterliegenden Satellitenbilder entsprechen. Diese ArtThis kind of gardening or tending activity can be great fun in an <a href="http://de.wikipedia.org/wiki/Zwangsst%C3%B6rung">OCD</a> sort of way, and we’ve personally killed many hours moving nodes here and there to improve the accuracy of street grids. 
</p>
<p>
    Es gibt eine dritte Art des Kartenbearbeitens, die am besten mit Papier durchgeführt werden kann, die Notierung von lokalen Dingen und Details, die auf Satellitenbildern unsichtbar sind, bedeutunglos ohne Straßendaten und unmöglich zu erfassen ohne direkten Besuch des Ortes: Ampeln, Fahrradläden, Toiletten, Bankautomaten, Treppen, Cafés, Kneipen, Adressen/Hausnummern und andere geographische Details die OpenStreetMap zu solch einem Herausforderer für die großen, kommerziellen Anbieter machen.
</p>

<h3>Ein Service für #3</h3>

<p>
    Aktuell gibt es keine Methoden und Dienste, die speziell für diese dritte Art des lokalenb Erfassens von Daten konzipiert wurden.
</p>
<p>
    Walking Papers is a website and a service designed to close this final loop by providing OpenStreetMap print maps that can be marked up with a pen, scanned back into the computer, and traced using OSM’s regular web-based editor, Potlatch. It’s designed for the casual mapper who doesn’t want to fill their pockets with gadgets to record what’s around them, the social mapper who might be out and about taking notes and comparing them with friends, and the opportunistic mapper who might make notes during a commute or a walk if they had a notebook-sized slip of paper to write on. Finally, it’s designed for the luddite mapper who would like to help the OpenStreetMap project but needs help from a distributed community to convert their handwritten annotations into OpenStreetMap’s tagged data and local conventions. 
</p>
<p>
    We’re trying to bridge some of these uses with web service opportunism and old-fashioned undigital fulfillment. Each scanned map is reverse-geocoded using Flickr’s 
    <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">flickr.places.findByLatLon API feature</a>, which coughs up a meaningful local name for a given geographical area so you can look at a collection of everyone’s scans and perhaps recognize a place you know and might help trace. Each print and scan action is also backed by a (possibly optimistic) promise to snail-mail printed maps to users, and to accept snail-mailed annotated maps in return. If you want to play neogeography pen-pal or simply don’t have a scanner at your disposal, Walking Papers can help. 
</p>

<h3>Kontext</h3>
<p>
    The project is most particularly inspired by <a href="http://aaronland.info/">Aaron Cope of Flickr</a> and <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>, whose <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> and <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> help all this post-digital, medieval technology make sense.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
