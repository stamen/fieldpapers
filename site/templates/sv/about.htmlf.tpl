<h2>Om Walking Papers</h2>

<p>
    OpenStreetMap ( OSM ), den fria wiki-världskartan som vem som helst kan förbättra, är i behov av ett nytt sätt att lägga till innehåll. Walking Papers gör det möjligt att exportera kart-data till papper, så att det blir enklare att göra noteringar och redigeringar ifrån ett på-vägen-perspektiv som OSM behöver allra mest, såväl som att fördela arbetslasten genom att göra det möjligt för överskådliga, lättlästa anteckningar delas och omvandlas till geografisk data. 
</p>
<p>
    Walking Papers är en fungerande tjänst som implementerar denna pappers-idé, baserat på <a href="http://mike.teczno.com/notes/walking-papers.html">det initiala tekniska experimentet</a> i februari. 
</p>

<h3>Tre sorters kartläggning</h3>

<p>
    Ett koncept kallas för "<em>Mapping party</em>" (ungf. kartläggningsfest), det går ut på att du kommer dit, du får låna en GPS, du får en snabbkurs i hur den används och skickas ut per fot, cyckel eller bil för att samla in spår utav närliggande vägar och banor.<br/>
    Detta koncept var skapat för områden där råa GPS spår behövdes som mest; I USA där ett grovt vägnät i stort sett är klart sedan ett tag tillbaka, tack vare en massimport av US Census TIGER/Line data, så kan kartläggningsfester vara något kontraproduktiv.

    Även i Svergie finns ett (mycket) grovt vägnät och storstäder såsom Stockholm är ganska så detaljerade, men det finns även en del vita fläckar.
</p>
<p>
    I USA så har skattebetalarna finansierat skapandet av fri, publik data för varje väg i U.S., så existerar råa vägar i databasen. TIGER data kan vara inexakt, men med hjälp av den väldigt frikostiga licensieringen av Yahoos aeriella fotografier, så är det möjligt att korrigera felaktiga vägar utan att ens lämna skrivbordet. Denna kartläggnings-konst kan vara både roligt och leda till ett slags <a href="http://sv.wikipedia.org/wiki/Tv%C3%A5ngssyndrom">Tvångssyndrom</a> på sätt och vis ;-) , och vi har själva dödat många timmar genom att flytta noder här och där för att öka nogrannheten på vägar och gator.
</p>
<p>
    Det finns en tredje form av kartläggning som bäst lämpar sig med papper, och det noteringen av saker på marknivå som är osynliga på ett flygfotografi, och omöjliga att samla in utan att faktiskt besöka platsen; såsom gatuljus, cyckelaffärer, toaletter, bankautomater, trappor, kaféer, pubar, adresser och andra delar av geografiskt sammanhang som gör OpenStreetMap till en så stark utmanare till de större, kommersiella tjänsteleverantörerna.
</p>

<h3>Rätta till #3</h3>

<p>
    För närvarande finns det inga metoder på plats som är speciellt utformad för denna tredje typ av sporadisk lokal kartläggning.
</p>
<p>
    Walking Papers är en webbsida och en tjänst utformad för att hjälpa till med denna sista del genom att tillhandahålla utskrifter av OpenStreetMap-kartor som kan märkas med en penna, skannas tillbaka och redigeras med OSMs vanliga flash-baserade redigerare, Potlatch; Den är designad för den sporadiska kartografen som inte vill fylla sina fickor med manicker för att registrera vad som finns runt omkring dem, den sociala kartografen som kanske är ute och tar noter för att jämföra dem med vänner, och den opportunistiska kartografen som skulle passa på under en promenad eller medans hon pendlar om de hade ett papper i storleken av ett anteckningsblock som hon kunde skriva på. Slutligen, så är det även designat för den mindre tekniska kartografen som skulle vilja hjälpa OpenStreetMap-projektet men behöver hjälp ifrån en spridd community till att konvertera deras handskrivna noter till OpenStreetMaps taggade data och lokala överenskommelser.
</p>
<p>
    Vi försöker överbrygga vissa utav dessa användningsområdena med hjälp av denna webbtjänst och gammaldags, icke-digitala metoder. Varje skannad karta är omvänt geokodade (fastställande av plats) genom använding av Flickr’s <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">flickr.places.findByLatLon API funktion</a>, vilken hostar upp en meningsfull beskrivning för den givna geografiska området så att du kan titta på en samling av allas inskanningar och kanske möjligen känna igen ett område du kan och hjälpa till med redigeringen. Varje utskrift och inskanning stöds av ett (möjligen optimistiskt) löfte om att snigel-posta utskrifter till användare, och att ta emot snigel-postade kartor med anteckningar på.
    Om du vill leka nygeografisk brevvän eller helt enkelt inte har en scanner till ditt förfogande, så kan Walking Papers hjälpa till.
</p>

<h3>Bakgrund</h3>
<p>
    Projektet är alldeles särskilt inspirerad av <a href="http://aaronland.info/">Aaron Cope på Flickr</a> och <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom vid Really Interesting Group</a>, vars <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> och <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> bidrar till att göra all denna post-digitala, medeltida teknik förståbar.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
