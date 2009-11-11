// "import" the namespace
var mm = com.modestmaps;

function formatDegree(value, axis)
{
    var dir = value;
    var val = Math.abs(value);
    
    var deg = Math.floor(val);
    val = (val - deg) * 60;
    
    var min = Math.floor(val);
    val = (val - min) * 60;
    
    var sec = Math.floor(val);
    
    var str = deg + '°';
    
    if(min <= 9)
        str += '0';

    str += min + "'";
    
    if(sec <= 9)
        str += '0';

    str += sec + '"';
    
    if(axis == 'lat') {
        str += (dir >= 0) ? 'N' : 'S';
    
    } else {
        str += (dir >= 0) ? 'E' : 'W';
    }
    
    return str;
}

function onMapChanged(map)
{
    var center = map.getCenter();
    var permalink = document.getElementById('permalink');
    var warn = document.getElementById('zoom-warning');

    permalink.href = '?lat='+escape(center.lat.toFixed(6))+'&lon='+escape(center.lon.toFixed(6))+'&zoom='+escape(map.getZoom().toString())+'#make';
    permalink.innerHTML = formatDegree(center.lat, 'lat') + ', ' + formatDegree(center.lon, 'lon') + ' at zoom level ' + map.coordinate.zoom + '.';
    warn.style.display = (map.getZoom() < 14) ? 'block' : 'none';
    
    var northwest = map.pointLocation(new mm.Point(0, 0));
    var southeast = map.pointLocation(map.dimensions);
    var form = document.forms['bounds'];
    
    form.elements['north'].value = northwest.lat;
    form.elements['south'].value = southeast.lat;
    form.elements['east'].value = southeast.lon;
    form.elements['west'].value = northwest.lon;
    form.elements['zoom'].value = map.coordinate.zoom;
}

function makeMap(elementID, providerURL)
{
    var tileURL = function(coord) {
        return providerURL.replace('{X}', coord.column).replace('{Y}', coord.row).replace('{Z}', coord.zoom);
    }
    
    var map = new mm.Map(elementID, new mm.MapProvider(tileURL), new mm.Point(360, 456))

    map.addCallback('zoomed',    function(m, a) { return onMapChanged(m); });
    map.addCallback('centered',  function(m, a) { return onMapChanged(m); });
    map.addCallback('extentset', function(m, a) { return onMapChanged(m); });
    map.addCallback('panned',    function(m, a) { return onMapChanged(m); });

    map.draw();
    
    return map;
}

function getPlaces(query, appid)
{
    if(document.getElementById('watch-cursor'))
        document.getElementById('watch-cursor').style.visibility = 'visible';

    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'http://where.yahooapis.com/v1/places.q('+escape(query)+');count=1?format=json&callback=onPlaces&select=long&appid='+escape(appid);
    document.body.appendChild(script);
    
    return false;
}
