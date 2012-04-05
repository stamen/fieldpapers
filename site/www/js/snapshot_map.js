var zoom_in_active = base_url + '/img/button-zoom-in-on.png',
    zoom_in_inactive = base_url + '/img/button-zoom-in-off.png',
    zoom_out_active = base_url + '/img/button-zoom-out-on.png',
    zoom_out_inactive = base_url + '/img/button-zoom-out-off.png';

var map,
    MM;    
    
MM = com.modestmaps;
var provider = base_provider + '/{Z}/{X}/{Y}.jpg';
map = new MM.Map("map", new MM.TemplatedMapProvider(provider), null, [new MM.DragHandler(), new MM.DoubleClickHandler()]);
    
var bounds = geojpeg_bounds.split(','),
    north = parseFloat(bounds[0]),
    west = parseFloat(bounds[1]),
    south = parseFloat(bounds[2]),
    east = parseFloat(bounds[3]),
    extents = [new MM.Location(north, west), new MM.Location(south, east)];

map.setExtent(extents);
map.zoomIn();
map.panBy(0,40);