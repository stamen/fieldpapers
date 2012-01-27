function initMap(prov) {
    var providers = prov.split(',');
    
    var maps = [];
    var MM = com.modestmaps;
    
    var center_lat = 37.77,
        center_lon = -122.41;
    
    // Set up some maps
    for (var i=0; i < 6; i++) {
        console.log(providers[i]);
        
        var map_id = 'map' + i;
        
        var map_page = document.createElement('div');
        map_page.setAttribute('id', map_id);

        maps.push(new MM.Map(map_id, new MM.TemplatedMapProvider(providers[i])));
        maps[i].setCenterZoom(new MM.Location(center_lat, center_lon), 14);
    }
}