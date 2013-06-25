var zoom_in_active = base_url + '/img/button-zoom-in-on.png',
    zoom_in_inactive = base_url + '/img/button-zoom-in-off.png',
    zoom_out_active = base_url + '/img/button-zoom-out-on.png',
    zoom_out_inactive = base_url + '/img/button-zoom-out-off.png';

var map,
    MM;    
    
MM = com.modestmaps;

var hashStr = (location.hash.charAt(0) == '#') ? location.hash.substr(1) : location.hash;
var incomingCoords = MM.Hash.prototype.parseHash(hashStr) || null;

var provider = base_provider + '/{Z}/{X}/{Y}.jpg';
var template = new MM.Template(provider);
var layer = new MM.Layer(template);
map = new MM.Map("map", layer, null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
    
var bounds = geojpeg_bounds.split(','),
    north = parseFloat(bounds[0]),
    west = parseFloat(bounds[1]),
    south = parseFloat(bounds[2]),
    east = parseFloat(bounds[3]),
    extents = [new MM.Location(north, west), new MM.Location(south, east)];

var hash = new MM.Hash(map);
if(!incomingCoords){
    map.setExtent(extents);
    map.zoomIn();
    map.panBy(0,40);
}else{
    map.setCenterZoom(incomingCoords.center,incomingCoords.zoom);
}
