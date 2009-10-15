<h2>Über Walking Papers</h2>

<p>
    OpenStreetMap, die freie Wiki-Weltkarte, die von jedem bearbeitet werden kann, benötigt einen neue Möglichkeit, um Daten hinzuzufügen. Walking Papers macht es möglich Daten auf Papier zu entnehmen und wieder hinzuzufügen, damit es einfacher ist, auf der Straße Daten zu bearbeiten und lesbare, einfache Notizen verfügbar zu machen und anschließend in geographische Daten umzuwandeln.
</p>
<p>
    Walking Papers ist ein funktionierender Service, der diese Papier-Idee nutzt, basierend auf <a href="http://mike.teczno.com/notes/walking-papers.html">einem ersten technischen Experiment
    </a> im Februar. 
</p>

<h3>Drei verschieden Arten des Erfassens</h3>

<p>
    Ein grobes Straßennetz der USA ist in OpenStreetMap seit dem großen Import der Tiger-Daten bereits vorhanden. Daher sind U.S. Mapping-Partys manchmal widersinnig: das Party-Konzept wurde für Plätze erfunden, wo man hauptsächlich rohe GPS-Tracks benötigt und die Mitwirkenden häufig frische Daten das erste Mal für einen bestimmten Ort hinzufügen. Normalerweise bekommt man eine Einführung in die Benutzung des GPS-Gerätes und sammelt anschließend neue Tracks von nahe gelegenen Straßen und Wegen zu Fuß oder per Rad. 

Auch in Deutschland sind mittlerweile große Teile des Straßennetzes bereits erfasst, wohingegen Details wie Straßennamen, Geschäfte und weitere Dinge noch fehlen.
</p>
<p>
    Da wir als (amerikanische) Steuerzahler die Erstellung von freien, öffentlichen Daten für jede Straße in der USA bezahlt haben, sind in  grobe Straßenverläufe meistens bereits in der Datenbasis vorhanden. TIGER-Daten können ungenau sein, aber mit der uns freundlichen Lizenz der Yahoo Satellitenbildern ist es möglich fehlerhafte Straßen zu korrigieren ohne dazu den Schreibtisch zu verlassen - man kann einfach den eingebauten OSM-Editor (Potlatch) nutzen, um die Straßen so zu verschieben, damit sie die darunter liegenden Satellitenbilder entsprechen. Diese Art des Mappens kann viel Spaß machen und beinahe zu eine kleinen <a href="http://de.wikipedia.org/wiki/Zwangsst%C3%B6rung">Zwangsstörungen</a> führen ;-), auch wir haben viele Stunden mit dem Verschieben von Knoten zur Verbesserung des Straßennetzes verbracht.
</p>
<p>
    Es gibt eine weitere, dritte Art des Kartenbearbeitens, die am besten mit Papier durchgeführt werden kann, die Notierung von lokalen Dingen und Details, die auf Satellitenbildern unsichtbar sind, bedeutungslos ohne Straßendaten und unmöglich zu Erfassen ohne direkten Besuch des Ortes: Ampeln, Fahrradläden, Toiletten, Bankautomaten, Treppen, Cafés, Kneipen, Adressen/Hausnummern und andere geographische Details die OpenStreetMap zu solch einem Herausforderer für die großen, kommerziellen Anbieter machen.
</p>

<h3>Ein Service für #3</h3>

<p>
    Aktuell gibt es keine Methoden und Dienste, die speziell für diese dritte Art des lokalen Erfassens von Daten konzipiert wurden.
</p>
<p>
    Walking Papers ist eine Webseite und ein Service, der dazu gemacht wurde um dieses letzte Problem zu lösen, indem OpenStreetMap-Karten bereitgestellt werden, die mit einem Stift beschriftet werden können, wieder am Computer eingescannt werden und von denen anschließend die notierten Informationen mit dem normalen, web-basierten OpenStreetMap Editor Potlatch nach gezeichnet werden können und der Datenbasis so hinzugefügt werden. Er wurde für den normalen Mapper gestaltet, der nicht erst ein Gerät kaufen möchte, um Informationen aufzuzeichnen, für den sozialen Mapper, der sich draußen Notizen macht und sie mit seinen Freunden vergleichen möchte und für den opportunistischen Mapper, der Notizen während des Weges zur Arbeit oder bei einem Spaziergang aufnehmen würden, wenn er ein Blatt in der Größe eines Notizbuch hätte, auf dem er notieren könnte. Außerdem ist dieser Service für die weniger technikversierten Mapper gedacht, die dem OpenStreetMap-Projekt helfen wollen, aber Hilfe von einer verteilten Community benötigen, um ihre handschriftlichen Notizen zu OpenStreetmap-Daten zu konvertieren.
<p>
    Wir versuchen einige dieser Benutzungsarten durch diesen Webservice und altertümliche, nicht-digitale Methoden zu unterstützen. Jede eingescannte Karte wird wieder geocodiert (Bestimmung des Ortes) durch die Benutzung von Flickr's 
    <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">flickr.places.findByLatLon API feature</a>, das einen sinnvollen, lokalen Namen für ein bestimmtes geographisches Gebiet bestimmt, damit man eine Sammlung aller eingescannten Karten durchsehen kann und vielleicht einen Ort erkennt, bei dem man mithelfen kann die Daten zu erfassen. Für jede Druck- und Scan-Aktion gibt es auch das (möglicherweise optimistische) Versprechen, dass gedruckte Karten per Post gesendet werden und auch beschriftete Karten per Post zurück zum Scannen gesendet werden können (aktuell ist nur eine Adresse für die USA vorhanden, ein deutscher Service wird bald verfügbar sein).
</p>

<h3>Kontext</h3>
<p>
    Das Projekt ist hauptsächlich von <a href="http://aaronland.info/">Aaron Cope von Flickr</a> inspiriert und von <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>, deren <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> und <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> all diesen post-digitalen, mittelalterlichen Technologien helfen sinnvoll zu sein.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
