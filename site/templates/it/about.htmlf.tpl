<h2>Cos'é Walking Papers</h2>

<p>
    OpenStreetMap, la mappa del mondo in stile wiki che tutto il mondo può editare ha bisogno di un nuovo modo per aggiungere contenuti. Walking Papers é un modo per “chiudere il cerchio” dei dati cartografici attraverso la carta, per rendere più semplice il tipo di modifiche effettuate tenendo-gli-occhi-incollati-alla-strada di cui OSM ha ora maggiormente bisogno, e allo stesso tempo per distribuirne il carico rendendo possibile la condivisione di note semplici e leggibili, in modo che possano essere trasformate in dati geografici reali.
</p>
<p>
    Walking Papers é un servizio funzionante che realizza questa idea, basata su una <a href="http://mike.teczno.com/notes/walking-papers.html">sperimentazione tecnica iniziale</a> (articolo in Inglese) dello scorso Febbraio. 
</p>

<h3>Tre tipi di mappature</h3>

<p>
    Una rete stradale approssimata degli Stati Uniti é stata praticamente completata in OSM ormai da un po' di tempo, dai tempi dell'importazione in blocco della base dati US Census TIGER/Line. Questo significa che i gruppi organizzati con lo scopo di mappare gli Stati Uniti possono essere leggermente controproducenti: l'idea del gruppo era stata pensata per posti dove più di tutto fossero necessari i puri tracciati GPS, e dove spesso i partecipanti creano nuovi dati per una data località per la prima volta in assoluto. Ti presenti, ti viene fornito un dispositivo GPS portatile, vieni velocemente istruito nel suo utilizzo e mandato a piedi, in bicicletta o in auto a raccogliere i tracciati di strade e percorsi vicini. 
</p>
<p>
    Dato che attraverso le tasse noi contribuenti abbiamo finanziato la creazione di dati pubblici e liberi per ogni strada negli Stati Uniti, solitamente le semplici strade esistono già nel database. I dati TIGER possono essere poco accurati, ma con la condiscendente licenza delle immagini aeree di Yahoo é possibile correggere strade malposte senza dover lasciare la vostra scrivania: semplicemente basta usare l'editor integrato di OSM per spostare le strade fino a quando non corrispondono all'immagine satellitare di sfondo. Questo tipo di attività di "giardinaggio" può essere molto divertente ed può avvicinarsi pericolosamente ad un <a href="http://it.wikipedia.org/wiki/Disturbo_ossessivo-compulsivo">Disturbo Ossessivo Compulsivo</a>, e personalmente abbiamo passato molte ore spostando nodi da una parte all'altra cercando di migliorare la grigla delle strade. 
</p>
<p>
    C'é un terzo modo di modificare una mappa e funziona al meglio se si utilizzano dei fogli di carta: é l'annotazione di caratteristiche locali, ad altezza uomo che sarebbero invisibili da un'immagine aerea, senza senso in assenza di dati stradali di base ed impossibili da raccogliere senza una visita di persona al sito. Lampioni, negozi di biciclette, bagni pubblici, bancomat, scale, bar, pub, indirizzi ed altri frammenti del contesto geografico fanno di OpenStreetMap un forte concorrente su scala umana di servizi più grandi e a pagamento.
</p>

<h3>Risolvere il terzo punto.</h3>

<p>
    Al momento non c'é alcun metodo progettato specificatamente per affrontare il terzo tipo di mappatura locale.
</p>
<p>
    Walking Papers é un sito web ed un servizio progettato per chiudere il cerchio fornendo stampe di mappe OpenStreetMap che possono essere marcate con una penna, scannerizzate nuovamente in un computer e tracciate utilizzando l'editor web-based di OSM, Potlatch. É stato pensato per il mappatore casuale che non vuole riempirsi le tasche di gadget per registrare quello che ha intorno a lui, per il mappatore sociale che potrebbe essere in giro a scrivere annotazioni, confrontandole poi con gli amici e per il mappatore opportunistico che se avesse un foglio su cui scrivere, potrebbe sfruttare l'opportunità di un viaggio o di una passeggiata per scrivere annotazioni. Infine, é pensato per il mappatore luddita, che vorrebbe aiutare il progetto OpenStreetMap, ma che ha bisogno dell'aiuto di una comunità per convertire in dati etichettati di OpenStreetMap ed in convenzioni locali le sue annotazioni scritte a mano.
</p>
<p>
    Stiamo cercando di unire questi modi d'uso all'opportunismo dei servizi web e al senso di realizzazione tipico di attività non digitali e un po' antiche. Ogni mappa scannerizzata viene geocodificata al contrario utilizzando <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">la funzionalità flickr.places.findByLatLon delle API</a> di Flickr, che sputa fuori il nome di una località avendogli fornito la relativa area geografica. Si può guardare così l'insieme di tutte le scansioni effettuate e magari riconoscere un posto conosciuto e che si può aiutare a tracciare. Ogni azione di stampa e scansione viene anche affiancata da una (forse ottimistica) promessa di recapitare per posta "normale" le mappe agli utenti e di accettare lettere contenenti mappe annotate. Se vuoi divertirti a scambiarti lettere con amici di penna "neogeografici" o semplicemente non hai uno scanner a tua disposizione, Walking Papers può aiutarti.
</p>

<h3>Contesto</h3>
<p>
    Il progetto é stato principalmente ispirato da <a href="http://aaronland.info/">Aaron Cope di Flickr</a> e da <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom di Really Interesting Group</a>, i cui <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> e <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> aiutano a dare un senso a tutta questa tecnologia medievale e post-digitale.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
