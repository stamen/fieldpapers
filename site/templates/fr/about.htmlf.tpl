<h2>À propos de Walking Papers</h2>

<p>
    OpenStreetMap, la carte du monde sous forme de wiki que n'importe qui peut modifier, a besoin d'un nouveau moyen pour ajouter du contenu.
    Walking Papers est un moyen de cartographier “en route” des données sur papier, pour faciliter les modifications des détails dans les rues dont OSM a besoin le plus, ainsi que de distribuer la charge en rendant des notes lisibles partageables, et transformées en des données géographiques réelles. 
</p>
<p>
    Walking Papers est un service fonctionnel qui implémente cette idée "papier", basée sur <a href="http://mike.teczno.com/notes/walking-papers.html">les expérimentations techniques initiales</a> remontant à février. 
</p>

<h3>Trois méthodes de cartographie</h3>

<p>
    Un réseau routier grossier des États-Unis a été complété de manière basique dans OSM depuis un certain temps maintenant, depuis l'import en masse du jeu de données US Census TIGER/Line. Cela signifie que les rencontres de cartographie aux État-Unis peuvent être contre-productives : les rencontres ont été pensées pour les lieux qui avaient un grand besoin en traces GPS, et les participants créent régulièrement des données à jour pour un endroit donné pour la toute première fois. Vous apparaissez, on vous donne un GPS portable, dont on vous a rapidement expliqué l'utilisation, et on vous envoie à pied, à vélo ou en voiture pour tracer les routes et les chemins  aux alentours. 
</p>
<p>
    Parce que nous, contribuables, avons payé pour la création de données gratuites et publiques de chaque route aux État-Unis, les routes de base existent en général dans la base de données. Les données TIGER peuvent être inexactes, mais grâce à la généreuse licence des images aériennes de Yahoo, il est possible de corriger des routes mal placées, sans même bouger de votre bureau. Utilisez simplement l'éditeur intégré à OSM pour déplacer les routes jusqu'à ce qu'elles coïncident avec celles de l'image satellite en dessous. Ce genre d'activité peut se révéler très amusant, un peu comme un <a href="http://fr.wikipedia.org/wiki/Trouble_obsessionnel_compulsif">TOC</a>, et nous avons personnellement passé des heures et des heures à déplacer des nœuds ici et là afin d'améliorer la précision des rues. 
</p>
<p>
    Il y a une troisième méthode de cartographie qui est mieux gérée sur papier, et c'est l'annotation de spécificités locales, à un niveau humain, qui seraient invisibles sur une image aérienne, inutiles en l'absence de données routières basiques, et impossibles à collecter sans visiter le site : feux, magasins de vélos, toilettes, distributeurs de billets, escaliers, cafés, bars, adresses, et d'autres informations géographiques, qui font d'OpenStreetMap un sérieux acteur face aux plus grands services commerciaux, à échelle humaine.
</p>

<h3>Contribuer à la 3e méthode</h3>

<p>
    Pour le moment, il n'existe pas de méthode en place spécifiquement conçue pour ce troisième type de cartographie locale.
</p>
<p>
    Walking Papers est un site et un service conçu pour clôre cette boucle finale en fournissant des cartes à imprimer d'OpenStreetMap qui peuvent être retouchées avec un stylo, scannée ensuite sur votre PC, et enfin tracée en utilisant l'éditeur en ligne d'OSM, Potlatch. Cela a été pensé pour le cartographe du dimanche qui ne veut pas s'encombrer les poches de gadgets électroniques pour enregistrer ce qu'il y a autour de lui, pour le cartographe social qui sortirait en prenant des notes et en les comparant avec ses amis, et pour le cartographe opportuniste qui aimerait prendre des notes durant un trajet ou une ballade s'il avait sous la main un morceau de papier sur lequel écrire. Pour finir, le service est conçu pour le cartographe luddite qui aimerait aider le projet OpenStreetMap mais qui a besoin d'aide de la part d'une communauté distribuée pour convertir ses annotations manuscrites en données tagguées et conventions locales d'OpenStreetMap. 
</p>
<p>
    Nous tentons de fusionner ces utilisations avec l'utilisation de services web et d'accomplissement vieux-jeu non numérique. Chaque carte scannée est géocodée en sens inverse en utilisant l'<a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">API flickr.places.findByLatLon</a> de Flickr qui récupère un nom local qui a du sens pour une zone géographique donnée, pour que vous puissiez consulter les collections de scans de tout le monde, et peut-être reconnaître un endroit que vous connaissez et aider à le tracer. Chaque action d'impression et de scan est aussi possible par une promesse (sans doute optimiste) d'envoyer par courrier des cartes imprimées aux utilisateurs, et de recevoir en retour les cartes annotées. Si vous voulez vous adonner à de la correspondance néogéographique ou si vous n'avez tout simplement pas de scanner à votre disposition, Walking Papers peut vous aider. 
</p>

<h3>Contexte</h3>
<p>
    Ce projet est tout particulièrement inspiré par <a href="http://aaronland.info/">Aaron Cope de Flickr</a> et <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom à Really Interesting Group</a>, dont leurs <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> et <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> ont aidés à donner un sens à cette technologie post-numérique et médiévale.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
