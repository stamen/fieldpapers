from sys import argv, stderr
from StringIO import StringIO
from subprocess import Popen, PIPE
from os.path import basename, dirname, join as pathjoin
from os import close, write, unlink, rename
from xml.etree import ElementTree
from urlparse import urlparse
from tempfile import mkstemp
from urllib import urlopen
from math import hypot
from glob import glob

from PIL import Image
from PIL.ImageDraw import ImageDraw

from ModestMaps.Geo import Location
from ModestMaps.Core import Point, Coordinate
from ModestMaps.OpenStreetMap import Provider as OpenStreetMapProvider

from apiutils import append_scan_file, update_scan, update_step
from featuremath import MatchedFeature, blobs2features, stream_pairs
from matrixmath import Transform, quad2quad, triangle2triangle
from imagemath import imgblobs, extract_image
from dimensions import ptpin

def paper_matches(blobs):
    """ Generate matches for specific paper sizes.
    
        Yield tuples with transformations from scan pixels to print points,
        paper sizes and orientations. Print points are centered on lower right
        corner of QR code.
    """
    from dimensions import ratio_portrait_a3, ratio_portrait_a4, ratio_portrait_ltr
    from dimensions import ratio_landscape_a3, ratio_landscape_a4, ratio_landscape_ltr
    from dimensions import point_E_portrait_a3, point_E_portrait_a4, point_E_portrait_ltr
    from dimensions import point_E_landscape_a3, point_E_landscape_a4, point_E_landscape_ltr
    
    for (acb_match, adc_match) in _blob_matches_primary(blobs):
        for (e_match, point_E) in _blob_matches_secondary(blobs, acb_match, adc_match):
            #
            # determing paper size and orientation based on identity of point E.
            #
            if point_E is point_E_portrait_a3:
                orientation, paper_size, scale = 'portrait', 'a3', 1/ratio_portrait_a3

            elif point_E is point_E_portrait_a4:
                orientation, paper_size, scale = 'portrait', 'a4', 1/ratio_portrait_a4

            elif point_E is point_E_portrait_ltr:
                orientation, paper_size, scale = 'portrait', 'letter', 1/ratio_portrait_ltr

            elif point_E is point_E_landscape_a3:
                orientation, paper_size, scale = 'landscape', 'a3', 1/ratio_landscape_a3

            elif point_E is point_E_landscape_a4:
                orientation, paper_size, scale = 'landscape', 'a4', 1/ratio_landscape_a4

            elif point_E is point_E_landscape_ltr:
                orientation, paper_size, scale = 'landscape', 'letter', 1/ratio_landscape_ltr
            
            else:
                raise Exception('How did we ever get here?')
            
            #
            # find the scan location of point E
            #
            (scan_E, ) = [getattr(e_match, 's%d' % i)
                          for i in (1, 2, 3)
                          if getattr(e_match, 'p%d' % i) is point_E]
        
            #
            # transform from scan pixels to homogenous print coordinates - A, B, D, E
            #
            s2h = quad2quad(acb_match.s1, acb_match.p1, acb_match.s3, acb_match.p3,
                            adc_match.s2, adc_match.p2, scan_E, point_E)
            
            #
            # transform from scan pixels to printed points, with (0, 0) at lower right
            #
            h2p = Transform(scale, 0, 0, 0, scale, 0)
            s2p = s2h.multiply(h2p)
            
            yield s2p, paper_size, orientation

def _blob_matches_primary(blobs):
    """ Generate known matches for ACB (top) and ADC (bottom) triangle pairs.
    """
    from dimensions import feature_acb, feature_adc, feature_dab
    from dimensions import min_size, theta_tol, ratio_tol

    acb_theta, acb_ratio = feature_acb.theta, feature_acb.ratio
    adc_theta, adc_ratio = feature_adc.theta, feature_adc.ratio
    dab_theta, dab_ratio = feature_dab.theta, feature_dab.ratio
    
    acb_matches = blobs2features(blobs, min_size, acb_theta-theta_tol, acb_theta+theta_tol, acb_ratio-ratio_tol, acb_ratio+ratio_tol)
    adc_matches = blobs2features(blobs, min_size, adc_theta-theta_tol, adc_theta+theta_tol, adc_ratio-ratio_tol, adc_ratio+ratio_tol)
    
    seen_groups, max_skipped, skipped_groups = set(), 100, 0
    
    for (acb_tuple, adc_tuple) in stream_pairs(acb_matches, adc_matches):
        
        i0, j0, k0 = acb_tuple[0:3]
        i1, j1, k1 = adc_tuple[0:3]
        
        group = (i0, j0, k0, i1, j1, k1)
        
        if skipped_groups > max_skipped:
            return

        if group in seen_groups:
            skipped_groups += 1
            #print >> stderr, 'skip:', group
            continue
        
        seen_groups.add(group)
        skipped_groups = 0

        acb_match = MatchedFeature(feature_acb, blobs[i0], blobs[j0], blobs[k0])
        adc_match = MatchedFeature(feature_adc, blobs[i1], blobs[j1], blobs[k1])
        
        if not acb_match.fits(adc_match):
            #print >> stderr, 'no:', group
            continue
        else:
            #print >> stderr, 'maybe:', group
            pass
        
        #
        # We now know we have a two-triangle match; try a third to verify.
        # Use the very small set of blobs from the current ACB / ACD matches.
        #
        
        _blobs = [blobs[n] for n in set(group)]
        dab_matches = blobs2features(_blobs, min_size, dab_theta-theta_tol, dab_theta+theta_tol, dab_ratio-ratio_tol, dab_ratio+ratio_tol)
        
        for dab_tuple in dab_matches:
            i2, j2, k2 = dab_tuple[0:3]
            dab_match = MatchedFeature(feature_dab, _blobs[i2], _blobs[j2], _blobs[k2])
            
            if acb_match.fits(dab_match) and adc_match.fits(dab_match):
                #print >> stderr, 'yes:', group
                yield acb_match, adc_match

def _blob_matches_secondary(blobs, acb_match, adc_match):
    """ Generate known matches for ACB (top), ADC (bottom) and paper-specific triangle groups.
    """
    from dimensions import feature_e_landscape_ltr, point_E_landscape_ltr
    from dimensions import feature_e_portrait_ltr, point_E_portrait_ltr
    from dimensions import feature_e_landscape_a4, point_E_landscape_a4
    from dimensions import feature_e_portrait_a4, point_E_portrait_a4
    from dimensions import feature_e_landscape_a3, point_E_landscape_a3
    from dimensions import feature_e_portrait_a3, point_E_portrait_a3
    from dimensions import min_size, theta_tol, ratio_tol

    features_e = (
        (feature_e_landscape_ltr, point_E_landscape_ltr),
        (feature_e_portrait_ltr,  point_E_portrait_ltr),
        (feature_e_landscape_a4,  point_E_landscape_a4),
        (feature_e_portrait_a4,   point_E_portrait_a4),
        (feature_e_landscape_a3,  point_E_landscape_a3),
        (feature_e_portrait_a3,   point_E_portrait_a3)
      )

    for (feature_e, point_E) in features_e:
        e_theta, e_ratio = feature_e.theta, feature_e.ratio
        e_matches = blobs2features(blobs, min_size, e_theta-theta_tol, e_theta+theta_tol, e_ratio-ratio_tol, e_ratio+ratio_tol)
        
        for e_tuple in e_matches:
            i, j, k = e_tuple[0:3]
            e_match = MatchedFeature(feature_e, blobs[i], blobs[j], blobs[k])
        
            if e_match.fits(acb_match) and e_match.fits(adc_match):
                #
                # Based on the identity of point_E, we can find paper size and orientation.
                #
                yield e_match, point_E

def read_code(image):
    """
    """
    decode = 'java', '-classpath', ':'.join(glob(pathjoin(dirname(__file__), 'lib/*.jar'))), 'qrdecode'
    decode = Popen(decode, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    
    image.save(decode.stdin, 'PNG')
    decode.stdin.close()
    decode.wait()
    
    decoded = decode.stdout.read().strip()
    
    if decoded.startswith('http://'):
    
        html = ElementTree.parse(urlopen(decoded))
        
        print_id, north, west, south, east = None, None, None, None, None
        
        for span in html.findall('body/span'):
            if span.get('id') == 'print-info':
                for subspan in span.findall('span'):
                    if subspan.get('class') == 'print':
                        print_id = subspan.text
                    elif subspan.get('class') == 'north':
                        north = float(subspan.text)
                    elif subspan.get('class') == 'south':
                        south = float(subspan.text)
                    elif subspan.get('class') == 'east':
                        east = float(subspan.text)
                    elif subspan.get('class') == 'west':
                        west = float(subspan.text)
    
        return print_id, north, west, south, east

    else:
        raise CodeReadException('Attempt to read QR code failed')

def generate_tiles(image, s2p, paper, orientation, north, west, south, east):
    """ Placeholder for now.
    """
    osm = OpenStreetMapProvider()
    
    if (paper, orientation) == ('letter', 'landscape'):
        from dimensions import paper_size_landscape_ltr as paper_size_pt
    
    elif (paper, orientation) == ('letter', 'portrait'):
        from dimensions import paper_size_portrait_ltr as paper_size_pt
    
    else:
        raise Exception('not yet')

    paper_width_pt, paper_height_pt = paper_size_pt
    
    for zoom in range(20):
        #
        # Coordinates of three print corners
        #
        
        ul = osm.locationCoordinate(Location(north, west)).zoomTo(zoom)
        ur = osm.locationCoordinate(Location(north, east)).zoomTo(zoom)
        lr = osm.locationCoordinate(Location(south, east)).zoomTo(zoom)
        
        #
        # Matching points in print and coordinate spaces
        #
        
        ul_pt = Point(1 * ptpin - paper_width_pt, 1.5 * ptpin - paper_height_pt)
        ul_co = Point(ul.column, ul.row)
    
        ur_pt = Point(0, 1.5 * ptpin - paper_height_pt)
        ur_co = Point(ur.column, ur.row)
    
        lr_pt = Point(0, 0)
        lr_co = Point(lr.column, lr.row)
        
        scan_dim = hypot(image.size[0], image.size[1])
        zoom_dim = hypot((lr_co.x - ul_co.x) * 256, (lr_co.y - ul_co.y) * 256)
        
        if zoom_dim/scan_dim < 0.1:
            # too zoomed-out
            continue
        
        if zoom_dim/scan_dim > 1.5:
            # too zoomed-in
            break
        
        #
        # scan2coord by way of scan2print and print2coord
        #

        p2c = triangle2triangle(ul_pt, ul_co, ur_pt, ur_co, lr_pt, lr_co)
        s2c = s2p.multiply(p2c)
        
        for (coord, tile_img) in generate_tiles_for_zoom(image, s2c, zoom):
            yield (coord, tile_img)
    
def generate_tiles_for_zoom(image, scan2coord, zoom):
    """ Yield a stream of coordinates and tile images for a given zoom level.
    """
    ul = scan2coord(Point(0, 0))
    ur = scan2coord(Point(image.size[0], 0))
    lr = scan2coord(Point(*image.size))
    ll = scan2coord(Point(0, image.size[1]))
    
    minrow = min(ul.y, ur.y, lr.y, ll.y)
    maxrow = max(ul.y, ur.y, lr.y, ll.y)
    mincol = min(ul.x, ur.x, lr.x, ll.x)
    maxcol = max(ul.x, ur.x, lr.x, ll.x)
    
    for row in range(int(minrow), int(maxrow) + 1):
        for col in range(int(mincol), int(maxcol) + 1):
            
            coord = Coordinate(row, col, zoom)
            coord_bbox = col, row, col + 1, row + 1
            tile_img = extract_image(scan2coord, coord_bbox, image, (256, 256), 256/8)
            
            yield (coord, tile_img)

def main(apibase, password, scan_id, url):
    """
    """
    yield 30
    
    #
    # Prepare a shorthand for pushing data.
    #
    _append_file = lambda name, body: scan_id and append_scan_file(scan_id, name, body, apibase, password) or None
    _update_step = lambda step_number: scan_id and update_step(apibase, password, scan_id, step_number) or None
    
    def _append_image(filename, image):
        """ Append specifically an image.
        """
        buffer = StringIO()
        format = filename.lower().endswith('.jpg') and 'JPEG' or 'PNG'
        image.save(buffer, format)
        _append_file(filename, buffer.getvalue())
    
    handle, highpass_filename = mkstemp(prefix='highpass-', suffix='.jpg')
    close(handle)
    
    handle, preblobs_filename = mkstemp(prefix='preblobs-', suffix='.jpg')
    close(handle)
    
    _update_step(2)

    input = Image.open(StringIO(urlopen(url).read()))
    blobs = imgblobs(input, highpass_filename, preblobs_filename)
    
    s, h, path, p, q, f = urlparse(url)
    uploaded_file = basename(path)
    
    yield 10
    
    _append_file('highpass.jpg', open(highpass_filename, 'r').read())
    _append_file('preblobs.jpg', open(preblobs_filename, 'r').read())

    rename(highpass_filename, 'highpass.jpg')
    rename(preblobs_filename, 'preblobs.jpg')
    
    _update_step(3)

    for (s2p, paper, orientation) in paper_matches(blobs):

        yield 10

        print >> stderr, paper, orientation, '--', s2p
        
        qrcode_img = extract_image(s2p, (-90-9, -90-9, 0+9, 0+9), input, (500, 500))
        _append_image('qrcode.png', qrcode_img)
        qrcode_img.save('qrcode.png')
        
        yield 10

        _update_step(4)

        print_id, north, west, south, east = read_code(qrcode_img)
        
        _update_step(5)

        print >> stderr, 'tiles...',
        
        minrow, mincol, minzoom = 2**20, 2**20, 20
        maxrow, maxcol, maxzoom = 0, 0, 0

        for (coord, tile_img) in generate_tiles(input, s2p, paper, orientation, north, west, south, east):

            _append_image('%(zoom)d/%(column)d/%(row)d.jpg' % coord.__dict__, tile_img)
            print >> stderr, coord.zoom,
            
            minrow = min(minrow, coord.row)
            mincol = min(mincol, coord.column)
            minzoom = min(minzoom, coord.zoom)
            
            maxrow = max(maxrow, coord.row)
            maxcol = max(maxcol, coord.column)
            maxzoom = max(minzoom, coord.zoom)
        
        print >> stderr, '...tiles.'
        
        preview_img = input.copy()
        preview_img.thumbnail((409, 280), Image.ANTIALIAS)
        _append_image('preview.jpg', preview_img)
        
        large_img = input.copy()
        large_img.thumbnail((900, 900), Image.ANTIALIAS)
        _append_image('large.jpg', large_img)
        
        min_coord = Coordinate(minrow, mincol, minzoom)
        max_coord = Coordinate(maxrow, maxcol, maxzoom)
        
        update_scan(apibase, password, scan_id, uploaded_file, print_id, min_coord, max_coord)

        _update_step(6)
        
        draw = ImageDraw(input)
        
        for blob in blobs:
            draw.rectangle(blob.bbox, outline=(0xFF, 0, 0))
    
        yield 5
        
        _append_image('out.png', input)
        input.save('out.png')
        
        return

if __name__ == '__main__':

    url = argv[1]
    
    for d in main(None, None, None, url):
        pass
