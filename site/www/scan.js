function makeProviderFunction(base_url)
{
    return function(coord) {
        return base_url + '/' + coord.zoom +'/'+ coord.column +'/'+ coord.row + '.jpg';
    }
}

function createCookie(name, value, days)
{
    if(days) {
        var date = new Date();
        date.setTime(date.getTime() + (days*24*60*60*1000));
        var expires = '; expires=' + date.toGMTString();
    } else {
        var expires = '';
    }

    document.cookie = name + '=' + value + expires + '; path=/';
}

function readCookie(name)
{
    var nameEQ = name + '=';
    var ca = document.cookie.split(';');

    for(var i=0; i < ca.length; i++)
    {
        var c = ca[i];

        while(c.charAt(0) == ' ')
            c = c.substring(1, c.length);

        if(c.indexOf(nameEQ) == 0)
            return c.substring(nameEQ.length, c.length);
    }

    return null;
}

function eraseCookie(name)
{
    createCookie(name, '', -1);
}

function editInPotlatch(inputs)
{
    var minrow = parseFloat(inputs['minrow'].value);
    var maxrow = parseFloat(inputs['maxrow'].value);
    var mincolumn = parseFloat(inputs['mincolumn'].value);
    var maxcolumn = parseFloat(inputs['maxcolumn'].value);
    var minzoom = parseInt(inputs['minzoom'].value);
    var maxzoom = parseInt(inputs['maxzoom'].value);
    var base_url = inputs['base_url'].value;

    var mm = com.modestmaps;
    var tl = (new mm.Coordinate(minrow, mincolumn, minzoom)).zoomTo(maxzoom).zoomBy(-1);
    var br = (new mm.Coordinate(maxrow, maxcolumn, maxzoom)).zoomBy(-1);
    var center = new mm.Coordinate((tl.row + br.row) / 2, (tl.column + br.column) / 2, tl.zoom)

    var provider = new mm.MapProvider(makeProviderFunction(base_url));
    var center = provider.coordinateLocation(center);
    
    var custombg = base_url+'/!/!/!.jpg';
    var token = inputs['username'].value + ':' + inputs['password'].value;
    
    if(inputs['username'].value)
        createCookie('openstreetmap-username', inputs['username'].value, 15);
    
    var pl = new SWFObject("http://www.openstreetmap.org/potlatch/potlatch.swf?d="+Math.round(Math.random()*1000), "potlatch", "100%", "100%", "6", "#FFFFFF");

    pl.addVariable('scale', tl.zoom);
    pl.addVariable('token', token);
    pl.addVariable('custombg', custombg);
    pl.addVariable('lat', center.lat);
    pl.addVariable('long', center.lon);

    pl.write("editor");
    
    return false;
}
