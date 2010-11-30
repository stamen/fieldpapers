import os
import os.path
import httplib
import xml.etree.ElementTree
import json

from math import log
from itertools import product
from urllib import urlopen, urlencode
from urlparse import urlparse, urljoin, urlunparse
from tempfile import mkdtemp
from subprocess import Popen
from pyproj import Proj
from mimetypes import guess_type
from array import array
from StringIO import StringIO

import osgeo.gdal as gdal
import PIL.Image as Image
import PIL.ImageStat as ImageStat

import ModestMaps as mm

srs = '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs'

def main(apibase, password, print_id, paper_size, orientation=None, layout=None, provider=None, bounds=None, zoom=None, geotiff_url=None):
    """
    """
    yield 60
    
    print 'Print:', print_id
    print 'Paper:', paper_size

    if orientation and bounds and zoom and provider and layout:
    
        print 'Orientation:', orientation
        print 'Bounds:', bounds
        print 'Layout:', layout
        print 'Provider:', provider
        print 'Size:', get_preview_map_size(orientation, paper_size)
        
        north, west, south, east = bounds
        width, height = get_preview_map_size(orientation, paper_size)
        
        northwest = mm.Geo.Location(north, west)
        southeast = mm.Geo.Location(south, east)
        
        # we need it to cover a specific area
        mmap = mm.mapByExtentZoom(mm.Providers.TemplatedMercatorProvider(provider),
                                  northwest, southeast, zoom)
                              
        # but we also we need it at a specific size
        mmap = mm.Map(mmap.provider, mm.Core.Point(width, height), mmap.coordinate, mmap.offset)
        
        out = StringIO()
        mmap.draw().save(out, format='JPEG')
        preview_url = append_print_file(print_id, 'preview.jpg', out.getvalue(), apibase, password)
        
        print preview_url
        
        zdiff = min(18, zoom + 2) - zoom
        print 'Zoom diff:', zdiff
        
        # we need it to cover a specific area
        mmap = mm.mapByExtentZoom(mm.Providers.TemplatedMercatorProvider(provider),
                                  northwest, southeast, zoom + zdiff)
                              
        # but we also we need it at a specific size
        mmap = mm.Map(mmap.provider, mm.Core.Point(width * 2**zdiff, height * 2**zdiff), mmap.coordinate, mmap.offset)
        
        out = StringIO()
        mmap.draw().save(out, format='JPEG')
        print_url = append_print_file(print_id, 'print.jpg', out.getvalue(), apibase, password)
        
        print 'Sent print.jpg'
        
        pages_data = []
        
        page_nw = mmap.pointLocation(mm.Core.Point(0, 0))
        page_se = mmap.pointLocation(mmap.dimensions)
        
        page_data = {'name': 'print.jpg', 'bounds': {}}
        page_data['bounds'].update({'north': page_nw.lat, 'west': page_nw.lon})
        page_data['bounds'].update({'south': page_se.lat, 'east': page_se.lon})
        pages_data.append(page_data)
        
        rows, cols = map(int, layout.split(','))
        
        if rows > 1 and cols > 1:
            for (row, col) in product(range(rows), range(cols)):
                sub_mmap = get_mmap_page(mmap, row, col, rows, cols)
                sub_part = '%(row)d,%(col)d' % locals()
                sub_name = 'print-%(sub_part)s.jpg' % locals()
        
                out = StringIO()
                sub_mmap.draw().save(out, format='JPEG')
                append_print_file(print_id, sub_name, out.getvalue(), apibase, password)
                
                print 'Sent', sub_name
                
                page_nw = sub_mmap.pointLocation(mm.Core.Point(0, 0))
                page_se = sub_mmap.pointLocation(sub_mmap.dimensions)
                
                page_data = {'part': sub_part, 'name': sub_name, 'bounds': {}}
                page_data['bounds'].update({'north': page_nw.lat, 'west': page_nw.lon})
                page_data['bounds'].update({'south': page_se.lat, 'east': page_se.lon})
                pages_data.append(page_data)
        
        print 'pages.json:', append_print_file(print_id, 'pages.json', json.dumps(pages_data, indent=2), apibase, password)

        #-----------------------------------------------------------------------
        yield 5
        raise Exception('stop')
        #-----------------------------------------------------------------------
    
    elif geotiff_url:
        
        # we'll need pages_data, a few other things
        raise Exception("I'm pretty sure support for geotiffs is currently broken, with the new atlas feature.")
    
        print 'URL:', geotiff_url
        
        filename = prepare_geotiff(geotiff_url)
        print_img, preview_img, (north, west, south, east), orientation = adjust_geotiff(filename, paper_size)
        os.unlink(filename)
        
        print_img.save(os.path.dirname(filename)+'/out.jpg')
        
        out = StringIO()
        print_img.save(out, format='JPEG')
        append_print_file(print_id, 'print.jpg', out.getvalue(), apibase, password)
        
        out = StringIO()
        preview_img.save(out, format='JPEG')
        preview_url = append_print_file(print_id, 'preview.jpg', out.getvalue(), apibase, password)
        
        zoom = infer_zoom(print_img.size[0], print_img.size[1], north, west, south, east)

    else:
        print 'Missing orientation, bounds, zoom, provider, layout and geotiff_url'
        yield False
        return
    
    paper = '%(orientation)s-%(paper_size)s' % locals()

    print 'Finishing...'
    finish_print(apibase, password, print_id, north, west, south, east, zoom, paper, preview_url)
    
    print '-' * 80
    
    yield False

def get_mmap_page(mmap, row, col, rows, cols):
    """ Get a mmap instance for a sub-page in an atlas layout.
    """
    dim = mmap.dimensions
    
    # aim for ~5% overlap, vary dep. on total rows/cols
    overlap = 0.1 / rows
    overlap *= (dim.x + dim.y) / 2
    
    # inner width and height of sub-page
    _w = (dim.x - (cols + 1) * overlap) / cols
    _h = (dim.y - (rows + 1) * overlap) / rows
    
    # pixel offset of page center
    x = (col * _w) + (_w / 2) + (col * overlap) + overlap
    y = (row * _h) + (_h / 2) + (row * overlap) + overlap
    
    location = mmap.pointLocation(mm.Core.Point(x, y))
    zoom = mmap.coordinate.zoom + (log(rows) / log(2))
    
    return mm.mapByCenterZoom(mmap.provider, location, zoom, mmap.dimensions)

def prepare_geotiff(geotiff_url):
    """
    """
    s, h, path, p, q, f = urlparse(geotiff_url)
    
    dirname = mkdtemp(prefix='compose-')
    basename = os.path.basename(path)
    filename1 = dirname + '/' + basename
    filename2 = dirname + '/' + os.path.splitext(basename)[0] + '.rgb' + os.path.splitext(path)[1]
    
    open(filename1, 'w').write(urlopen(geotiff_url).read())
    
    translate_cmd = '/usr/bin/gdal_translate -expand rgb -of GTiff ... ...'.split()
    translate_cmd[-2:] = filename1, filename2
    
    print 'd:', dirname
    print 'b:', basename
    print 'f1:', filename1
    print 'f2:', filename2
    print ' '.join(translate_cmd)
    
    translate_cmd = Popen(translate_cmd)
    translate_cmd.wait()
    
    os.unlink(filename1)
    
    return str(filename2)

def geotiff_edge_color(filename):
    """
    """
    src = gdal.Open(filename)
    
    print src
    print src.RasterXSize, src.RasterYSize
    
    buffer = 25
    
    areas = [(0, 0, src.RasterXSize, buffer),
             (0, 0, buffer, src.RasterYSize),
             (0, src.RasterYSize - buffer, src.RasterXSize, buffer),
             (src.RasterXSize - buffer, 0, buffer, src.RasterYSize)]
    
    def bandaverage(band, x, y, w, h):
        img = Image.fromstring('L', (w, h), band.ReadRaster(x, y, w, h))
        return ImageStat.Stat(img).mean[0]
    
    rgb = []
    
    for band in (1, 2, 3):
        band = src.GetRasterBand(band)
        avgs = [(bandaverage(band, x, y, w, h), w * h)
                for (x, y, w, h) in areas]
    
        area = sum( [size for (mean, size) in avgs] )
        average = sum( [(mean * size / area) for (mean, size) in avgs] )
    
        rgb.append(int(average))

    print 'RGB:', rgb
    
    return tuple(rgb)

def get_preview_map_size(*paper):
    """
    """
    if paper == ('portrait', 'letter'):
        return (360, 480 - 24)

    if paper == ('portrait', 'a4'):
        return (360, 504.897)

    if paper == ('portrait', 'a3'):
        return (360, 506.200)

    if paper == ('landscape', 'letter'):
        return (480, 360 - 24)

    if paper == ('landscape', 'a4'):
        return (480, 303.800)

    if paper == ('landscape', 'a3'):
        return (480, 314.932)

def warp_geotiff(filename1):
    """ Return a warped GeoTIFF, its bgcolor, and bounds in mercator coordinates.
    """
    rgb = geotiff_edge_color(filename1)
    
    filename2 = os.path.splitext(filename1)[0] + '.merc' + os.path.splitext(filename1)[1]
    
    warp_cmd = 'gdalwarp -t_srs ... -dstnodata ... -of GTiff ... ...'.split()
    warp_cmd[-2:] = filename1, filename2
    warp_cmd[4] = '%d %d %d' % rgb
    warp_cmd[2] = srs
    
    print 'f1:', filename1
    print 'f2:', filename2
    print ' '.join(warp_cmd)
    
    warp_cmd = Popen(warp_cmd)
    warp_cmd.wait()
    
    src = gdal.Open(filename2)
    txn = src.GetGeoTransform()
    
    w, h = src.RasterXSize, src.RasterYSize
    ulx, uly = txn[0], txn[3]
    lrx, lry = ulx + w * txn[1], uly + h * txn[5]
    
    print (w, h), (ulx, uly, lrx, lry)
    
    img = Image.open(filename2)
    
    os.unlink(filename2)
    
    return img, rgb, (ulx, uly, lrx, lry)

def adjust_geotiff(filename, paper_size):
    """
    """
    warped_img, bgcolor, bounds = warp_geotiff(filename)
    
    print warped_img, warped_img.size, bounds
    
    img_aspect = float(warped_img.size[0]) / float(warped_img.size[1])
    
    orientation = (img_aspect < 1.0) and 'portrait' or 'landscape'
    
    w, h = get_preview_map_size(orientation, paper_size)
        
    paper_aspect = float(w) / float(h)
    
    print w, h
    
    print paper_aspect, 'paper aspect'
    print img_aspect, 'geotiff aspect'
    
    merc = Proj(srs)
    
    if img_aspect > paper_aspect:
        # image will need extra filling on top and bottom
        total_height = int(warped_img.size[0] / paper_aspect)
        extra_height = total_height - warped_img.size[1]

        print 'total height', total_height, 'extra height', extra_height
        
        print_img = Image.new('RGB', (warped_img.size[0], total_height), bgcolor)
        print_img.paste(warped_img, (0, extra_height/2))
        preview_img = print_img.resize((w, h), Image.ANTIALIAS)
        
        ulx, uly, lrx, lry = bounds
        
        total_span = (lrx - ulx) / paper_aspect
        extra_span = total_span - (uly - lry)

        print 'total span', total_span, 'extra span', extra_span
        
        west, north = merc(ulx, uly + extra_span/2, inverse=True)
        east, south = merc(lrx, lry - extra_span/2, inverse=True)
        
        print north, west, south, east
        
    else:
        # image will need extra filling on left and right
        total_width = int(warped_img.size[1] * paper_aspect)
        extra_width = total_width - warped_img.size[0]

        print 'total width', total_width, 'extra width', extra_width
        
        print_img = Image.new('RGB', (total_width, warped_img.size[1]), bgcolor)
        print_img.paste(warped_img, (extra_width/2, 0))
        preview_img = print_img.resize((w, h))
        
        ulx, uly, lrx, lry = bounds
        
        total_span = (uly - lry) * paper_aspect
        extra_span = total_span - (lrx - ulx)

        print 'total span', total_span, 'extra span', extra_span
        
        west, north = merc(ulx - extra_span/2, uly, inverse=True)
        east, south = merc(lrx + extra_span/2, lry, inverse=True)
        
        print north, west, south, east

    return print_img, preview_img, (north, west, south, east), orientation

def infer_zoom(width, height, north, west, south, east):
    """
    """
    mmap = mm.mapByExtent(mm.OpenStreetMap.Provider(),
                          mm.Geo.Location(north, west), mm.Geo.Location(south, east),
                          mm.Core.Point(width, height))
    
    zoom = int(mmap.coordinate.zoom)
    
    return zoom

def finish_print(apibase, password, print_id, north, west, south, east, zoom, paper, preview_url):
    """
    """
    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    if urlparse(preview_url)[1] == 'localhost':
        # just use an absolute path for preview URL if it's on localhost
        parts = urlparse(preview_url)
        preview_url = urlunparse((None, None, parts[2], parts[3], parts[4], parts[5]))
    
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    
    query = urlencode({'id': print_id})
    params = urlencode({'password': password,
                        'last_step': 6,
                        'paper': paper,
                        'preview_url': preview_url,
                        'north': north, 'west': west,
                        'south': south, 'east': east,
                        'zoom': zoom})
    
    req = httplib.HTTPConnection(host, port)
    req.request('POST', path + '/print.php?' + query, params, headers)
    res = req.getresponse()
    
    assert res.status == 200, 'POST to print.php resulting in status %s instead of 200' % res.status

    return

def append_print_file(print_id, file_path, file_contents, apibase, password):
    """ Upload a file via the API append.php form input provision thingie.
    """

    s, host, path, p, q, f = urlparse(apibase)
    host, port = (':' in host) and host.split(':') or (host, 80)
    
    query = urlencode({'print': print_id, 'password': password,
                       'dirname': os.path.dirname(file_path),
                       'mimetype': (guess_type(file_path)[0] or '')})
    
    req = httplib.HTTPConnection(host, port)
    req.request('GET', path + '/append.php?' + query)
    res = req.getresponse()
    
    html = xml.etree.ElementTree.parse(res)
    
    for form in html.findall('*/form'):
        form_action = form.attrib['action']
        
        inputs = form.findall('.//input')
        
        file_inputs = [input for input in inputs if input.attrib['type'] == 'file']
        
        fields = [(input.attrib['name'], input.attrib['value'])
                  for input in inputs
                  if input.attrib['type'] != 'file' and 'name' in input.attrib]
        
        files = [(input.attrib['name'], os.path.basename(file_path), file_contents)
                 for input in inputs
                 if input.attrib['type'] == 'file']

        if len(files) == 1:
            base_url = [el.text for el in form.findall(".//*") if el.get('id', '') == 'base-url'][0]
            resource_url = urljoin(base_url, file_path)
        
            post_type, post_body = encode_multipart_formdata(fields, files)
            
            s, host, path, p, query, f = urlparse(urljoin(apibase, form_action))
            host, port = (':' in host) and host.split(':') or (host, 80)
            
            req = httplib.HTTPConnection(host, port)
            req.request('POST', path+'?'+query, post_body, {'Content-Type': post_type, 'Content-Length': str(len(post_body))})
            res = req.getresponse()
            
            # res.read().startswith("Sorry, encountered error #1 ")
            
            assert res.status in range(200, 308), 'POST of file to %s resulting in status %s instead of 2XX/3XX' % (host, res.status)

            return resource_url
        
    raise Exception('Did not find a form with a file input, why is that?')

def encode_multipart_formdata(fields, files):
    """ fields is a sequence of (name, value) elements for regular form fields.
        files is a sequence of (name, filename, value) elements for data to be uploaded as files
        Return (content_type, body) ready for httplib.HTTP instance
        
        Adapted from http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/146306
    """
    BOUNDARY = '----------multipart-boundary-multipart-boundary-multipart-boundary$'
    CRLF = '\r\n'

    content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
    bytes = array('c')

    for (key, value) in fields:
        bytes.fromstring('--' + BOUNDARY + CRLF)
        bytes.fromstring('Content-Disposition: form-data; name="%s"' % key + CRLF)
        bytes.fromstring(CRLF)
        bytes.fromstring(value + CRLF)

    for (key, filename, value) in files:
        bytes.fromstring('--' + BOUNDARY + CRLF)
        bytes.fromstring('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename) + CRLF)
        bytes.fromstring('Content-Type: %s' % (guess_type(filename)[0] or 'application/octet-stream') + CRLF)
        bytes.fromstring(CRLF)
        bytes.fromstring(value + CRLF)

    bytes.fromstring('--' + BOUNDARY + '--' + CRLF)

    return content_type, bytes.tostring()

if __name__ == '__main__':
    src = gdal.Open(sys.argv[1])
    
    print src
    print src.RasterXSize, src.RasterYSize
    
    buffer = 25
    
    areas = [(0, 0, src.RasterXSize, buffer),
             (0, 0, buffer, src.RasterYSize),
             (0, src.RasterYSize - buffer, src.RasterXSize, buffer),
             (src.RasterXSize - buffer, 0, buffer, src.RasterYSize)]
    
    def bandaverage(band, x, y, w, h):
        img = Image.fromstring('L', (w, h), band.ReadRaster(x, y, w, h))
        return ImageStat.Stat(img).mean[0]
    
    for band in (1, 2, 3):
        band = src.GetRasterBand(band)
        avgs = [(bandaverage(band, x, y, w, h), w * h)
                for (x, y, w, h) in areas]
    
        area = sum( [size for (mean, size) in avgs] )
        average = sum( [(mean * size / area) for (mean, size) in avgs] )
    
        print int(average)
