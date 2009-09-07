<h2>Acerca de Walking Papers</h2>
<p>
   OpenStreetMap, el mapa del mundo estilo wiki que cualquiera puede modificar, necesita nuevas formas de añadir contenidos. Walking Papers es una forma de llevar los datos cartográficos al papel y otra vez de vuelta, facilitando así la clase de cambios, basados en los testigos directos, que OSM más necesita, así como el distribuir la carga al hacer posible que notas sencillas y legibles puedan compartirse y convertirse en datos geográficos reales.
</p>  

<p>
    Walking Papers es un servicio funcional que implementa esta idea, basada en los <a href="http://mike.teczno.com/notes/walking-papers.html">
    primeros experimentos técnicos</a> del pasado Febrero. 
</p>


<h3>Tres clases de mapas</h3>

<p>
  Tras completarse la importación de los datos TIGER/Line del censo de los Estados Unidos, OSM lleva un tiempo disponiendo de la distribución aproximada de carreteras en los Estados Unidos. Esto signifca que las "mapping parties" en USA pueden resultar ligeramente contraproducentes: el formato de "party" se ideó para sitios donde lo más necesario eran registros GPS en bruto, y los participantes a menudo crean datos nuevos para un emplazamiento por vez primera. Apareces, te dan un GPS de mano, te enseñan a usarlo sobre la marcha y te envían, a pie, en bicicleta o en coche a obtener registros de caminos o carreteras cercanas.
</p>

<p>
  Dado que los contribuyentes han financiado la creación de datos públicos y gratuitos acerca de cada carretera en los USA, las carreteras en sí ya están en la base de datos. Los datos de TIGER pueden no ser exactos, pero, gracias a la generosa licencia de las imágenes aéreas de Yahoo, es posible corregir carreteras posicionadas incorrectamente sin necesidad de levantarte de tu mesa - basta con usar el editor web integrado de OSM para mover las calles hasta que se correspondan con las imágenes por satélite. Este tipo de cuidados y atenciones puede ser muy divertito, en un estilo <a href="http://es.wikipedia.org/wiki/Trastorno_obsesivo-compulsivo" title="Trastorno Obsesivo Compulsivo">obsesivo-compulsivo</a>, y nosotros mismos hemos matado muchas horas moviendo nodos de aquñi para allá para mejorar la exactitud de las retículas de calles.
</p>

<p>
  Hay una tercera forma de edición de mapas que funciona mejor con papel, y esa es la anotación de las caracterísitcas locales, a pie de calle, que resultarían invisibles en vistas aéreas, incomprensibles en la ausencia de datos básicos de carreteras, e imposible de recoger sin una visita al sitio: farolas, tiendas de bicibletas, baños, cajeros automáticos, escaleras, cafeterías, pubs, direcciones, y otros fragmentos de contexto geográfico que convierten a OpenStreetMap en una opción tan fuerte frente a los grandes servicios comerciales en la escala humana. 
</p>

<h3>Arreglando la tercera forma</h3>



<p>
  En la actualidad no hay ningún método en funcionamiento especificamente designado para las necesidades de esta tercera forma de mapeado local y ocasional.
</p>

<p>
  Walking Papers es un sitio web y un servicio diseñado para cerrar este último eslabón al proporcionar mapas impresos de OpenStreetMap en los que se puede escribir con un bolígrafo, escaneados de nuevo y traceados usando con el editor normal de OSM, Potlach. Está diseñado para el mapeador ocasional que no quiere llevar los bolsillos llenos de gadgets para registrar todo lo que le rodea, el mapeador sociable que podría andar por ahí tomando notas y comparándolas con amigos, y el mapeador oportunista que podría tomar notas en el camino al trabajo o durante un paseo si tuviesen un trozo de papel del tamaño de una libreta en el que escribir. Finalmente, está diseñado para el mapeador ludita al que le gustaría ayudar al proyecto OpenStreetMap pero que necesita la ayuda de una comunidad distribuida para convertir sus notas manuscritas en los datos tagueados y las convenciones locales de OpenStreetMap.
</p>

<p>
  Tratamos de crear puente entre algunos de estos usos con el aprovechamiento de servicios web y el desempeño a la vieja usanza y no digital. A cada mapa escaneado se le realiza una geocodificación inversa mediante la <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">funcionalidad flickr.places.findByLatLon de la API</a> de Flickr, que devuelve un nombre adecuado para un área geográfica determinada, para que puedas mirar una colección de los escaneados de todo el mundo y quizás reconocer un sitio familar y que puedas ayudar a trazar. Cada impresión y escaneado es apoyada con la (probablemente optimista) promesa de enviar mapas a los usuarios por correo ordinario y de aceptar también el envío de mapas con notas. Si quieres jugar a la neogeografía por correspondencia, o simplemente no tienes un scanner que puedas usar, Walking Papers te puede ayudar.
</p>




<h3>Contexto</h3>
<p>
  El proyecto está particularmente inspirado por <a href="http://aaronland.info/">Aaron Cope de Flickr</a> y a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom del Really Interesting Group</a>, cuyo <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> y <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> ayudan a encontrarle sentido a toda esta tecnología post-digital y medieval.
</p>

<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
