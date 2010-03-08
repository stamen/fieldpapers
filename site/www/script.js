/**
 * Take an object response from flickr.places.findByLatLon and sticks it after a given DOM node.
 */
function appendPlacename(res, node)
{
    if(res['places'] && res['places']['place'] && res['places']['place'][0])
    {
        var place = res['places']['place'][0];
        var placeName = document.createTextNode(place['name']);

        node.parentNode.insertBefore(placeName, node.nextSibling);
        node.parentNode.insertBefore(document.createElement('br'), node.nextSibling);
    }
}

/**
 * Retrieves a place name from flickr.places.findByLatLon with a JSON callback
 */
function getPlacename(lat, lon, flickrKey, callback)
{
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'http://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&lat=' + escape(lat) + '&lon=' + escape(lon) + '&accuracy=12&format=json&jsoncallback=' + escape(callback) + '&api_key=' + escape(flickrKey);
    document.body.appendChild(script);
}

function makeStaticMap(elementID, lat, lon)
{
    // "import" the namespace
    var mm = com.modestmaps;
    
    var tileURL = function(coord) {
        return 'http://tile.openstreetmap.org/' + coord.zoom + '/' + coord.column + '/' + coord.row + '.png';
    }
    
    var map = new com.modestmaps.Map(elementID, new mm.MapProvider(tileURL), new mm.Point(408, 252))

    map.setCenterZoom(new mm.Location(lat, lon), 9);
    map.draw();

    // we're not actually looking for an interactive map
    mm.removeEvent(map.parent, 'dblclick', map.getDoubleClick());
    mm.removeEvent(map.parent, 'mousedown', map.getMouseDown());
    mm.removeEvent(map.parent, 'mousewheel', map.getMouseWheel());
    
    return map;
}
