<h2>О Walking Papers</h2>

<p>
    OpenStreetMap - вики-карта всего мира, которую может редактировать каждый. Walking Papers - это способ “round trip” карту через бумажную, чтобы облегчить ввод изменений полученных непосредственно на местности, а также облегчить работу засчет удобного способа обмена фрагментами карты с подписями. 
</p>
<p>
    Walking Papers - сервис который воплощает идею использования бумажный карт основанную на <a href="http://mike.teczno.com/notes/walking-papers.html"> первом эксперименте</a> проведенном в Феврале. 
</p>

<h3>Есть три способа картировать</h3>

<p>
    Там где какая-то дорожная сеть в OSM отсутствует, люди устраивают так называемые "покартушки", встречи где они ходят, ездят на велосипедах и машинах с GPS'ами по улицам. Треки собираемые с помощью навигаторов потом используются для того, чтобы по ним отрисовать разного рода дороги. 
</p>
<p>
    Неправильно нанесенные данные можно потом исправить не выходя из дома, используя один из редакторов данных OSM и спутниковые данные. Эта работа может быть увлекательна и даже <a href="http://en.wikipedia.org/wiki/Obsessive%E2%80%93compulsive_disorder">слишком</a>, и мы лично убили многие часы на улучшение карты в наших окрестностях. 
</p>
<p>
    Есть также третья форма редактирования карты, для которой бумага походит лучшие способом. На бумагу можно записывать местоположение объектов, которые невозможно увидеть на снимках и которые бесполезно наносить пока нет дорог, объектов подробности про которые можно узнать только на местности: фонари, магазины, туалеты, банкоматы, лестницы, кафе, рестораны, адреса и другие данные, которые делают OpenStreetMap сильным конкуретном других сервисов. 
</p>

<h3>Решаем проблему #3</h3>

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
