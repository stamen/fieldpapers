from sys import argv, stderr
from StringIO import StringIO
from subprocess import Popen, PIPE
from os.path import basename, dirname, join as pathjoin
from os import close, write, unlink, rename
from xml.etree import ElementTree
from urlparse import urlparse
from tempfile import mkstemp
from urllib import urlopen
from random import random
from math import hypot
from glob import glob

try:
    import PIL
except ImportError:
    import Image
    from ImageDraw import ImageDraw
else:
    from PIL import Image
    from PIL.ImageDraw import ImageDraw

from ModestMaps.Geo import Location
from ModestMaps.Core import Point, Coordinate
from ModestMaps.OpenStreetMap import Provider as OpenStreetMapProvider

from apiutils import append_scan_file, update_scan, update_step
from featuremath import MatchedFeature, blobs2features, blobs2feats_limited, blobs2feats_fitted, theta_ratio_bounds
from matrixmath import Transform, quad2quad, triangle2triangle
from imagemath import imgblobs, extract_image
from dimensions import ptpin

# these must match site/lib/data.php
STEP_UPLOADING = 0
STEP_QUEUED = 1
STEP_SIFTING = 2
STEP_FINDING_NEEDLES = 3
STEP_READING_QR_CODE = 4
STEP_TILING_UPLOADING = 5
STEP_FINISHED = 6
STEP_BAD_QRCODE = 98
STEP_ERROR = 99
STEP_FATAL_ERROR = 100
STEP_FATAL_QRCODE_ERROR = 101

class CodeReadException(Exception):
    pass

def paper_matches(blobs):
    """ Generate matches for specific paper sizes.
    
        Yield tuples with transformations from scan pixels to print points,
        paper sizes and orientations. Print points are centered on lower right
        corner of QR code.
    """
    from dimensions import ratio_portrait_a3, ratio_portrait_a4, ratio_portrait_ltr
    from dimensions import ratio_landscape_a3, ratio_landscape_a4, ratio_landscape_ltr
    from dimensions import point_F_portrait_a3, point_F_portrait_a4, point_F_portrait_ltr
    from dimensions import point_F_landscape_a3, point_F_landscape_a4, point_F_landscape_ltr
    
    for (dbc_match, aed_match) in _blob_matches_primary(blobs):
        for (f_match, point_F) in _blob_matches_secondary(blobs, aed_match):
            #
            # determing paper size and orientation based on identity of point E.
            #
            if point_F is point_F_portrait_a3:
                orientation, paper_size, scale = 'portrait', 'a3', 1/ratio_portrait_a3

            elif point_F is point_F_portrait_a4:
                orientation, paper_size, scale = 'portrait', 'a4', 1/ratio_portrait_a4

            elif point_F is point_F_portrait_ltr:
                orientation, paper_size, scale = 'portrait', 'letter', 1/ratio_portrait_ltr

            elif point_F is point_F_landscape_a3:
                orientation, paper_size, scale = 'landscape', 'a3', 1/ratio_landscape_a3

            elif point_F is point_F_landscape_a4:
                orientation, paper_size, scale = 'landscape', 'a4', 1/ratio_landscape_a4

            elif point_F is point_F_landscape_ltr:
                orientation, paper_size, scale = 'landscape', 'letter', 1/ratio_landscape_ltr
            
            else:
                raise Exception('How did we ever get here?')
            
            #
            # find the scan location of point F
            #
            (scan_F, ) = [getattr(f_match, 's%d' % i)
                          for i in (1, 2, 3)
                          if getattr(f_match, 'p%d' % i) is point_F]
        
            #
            # transform from scan pixels to homogenous print coordinates - A, C, E, F
            #
            s2h = quad2quad(aed_match.s1, aed_match.p1, dbc_match.s3, dbc_match.p3,
                            aed_match.s2, aed_match.p2, scan_F, point_F)
            
            #
            # transform from scan pixels to printed points, with (0, 0) at lower right
            #
            h2p = Transform(scale, 0, 0, 0, scale, 0)
            s2p = s2h.multiply(h2p)
            
            # useful for drawing post-blobs image
            blobs_abcde = aed_match.s1, dbc_match.s2, dbc_match.s3, dbc_match.s1, aed_match.s2
            
            yield s2p, paper_size, orientation, blobs_abcde

def _blob_matches_primary(blobs):
    """ Generate known matches for DBC (top) and AED (bottom) triangle pairs.
    """
    from dimensions import feature_dbc, feature_dab, feature_aed, feature_eac
    from dimensions import min_size, theta_tol, ratio_tol

    dbc_theta, dbc_ratio = feature_dbc.theta, feature_dbc.ratio
    dab_theta, dab_ratio = feature_dab.theta, feature_dab.ratio
    aed_theta, aed_ratio = feature_aed.theta, feature_aed.ratio
    eac_theta, eac_ratio = feature_eac.theta, feature_eac.ratio
    
    dbc_matches = blobs2features(blobs, min_size, *theta_ratio_bounds(dbc_theta, theta_tol, dbc_ratio, ratio_tol))
    
    seen_groups, max_skipped, skipped_groups = set(), 100, 0
    
    for dbc_tuple in dbc_matches:
        i0, j0, k0 = dbc_tuple[0:3]
        dbc_match = MatchedFeature(feature_dbc, blobs[i0], blobs[j0], blobs[k0])
    
        #print >> stderr, 'Found a match for DBC -', (i0, j0, k0)
        
        dab_matches = blobs2feats_limited([blobs[i0]], blobs, [blobs[j0]], *theta_ratio_bounds(dab_theta, theta_tol, dab_ratio, ratio_tol))
        
        for dab_tuple in dab_matches:
            i1, j1, k1 = i0, dab_tuple[1], j0
            dab_match = MatchedFeature(feature_dab, blobs[i1], blobs[j1], blobs[k1])
            
            if not dab_match.fits(dbc_match):
                continue
            
            #print >> stderr, ' Found a match for DAB -', (i1, j1, k1)
            
            #
            # We think we have a match for points A-D, now check for point E.
            #
            
            aed_matches = blobs2feats_limited([blobs[j1]], blobs, [blobs[i1]], *theta_ratio_bounds(aed_theta, theta_tol, aed_ratio, ratio_tol))
            
            for aed_tuple in aed_matches:
                i2, j2, k2 = j1, aed_tuple[1], i1
                aed_match = MatchedFeature(feature_aed, blobs[i2], blobs[j2], blobs[k2])
                
                if not aed_match.fits(dbc_match):
                    continue
                
                if not aed_match.fits(dab_match):
                    continue
                
                #print >> stderr, '  Found a match for AED -', (i2, j2, k2)
                
                #
                # We now know we have a three-triangle match; try a fourth to verify.
                # Use the very small set of blobs from the current set of matches.
                #
                
                _blobs = [blobs[n] for n in set((i0, j0, k0) + (i1, j1, k1) + (i2, j2, k2))]
                eac_matches = blobs2features(_blobs, min_size, *theta_ratio_bounds(eac_theta, theta_tol, eac_ratio, ratio_tol))
                
                for eac_tuple in eac_matches:
                    i3, j3, k3 = eac_tuple[0:3]
                    eac_match = MatchedFeature(feature_eac, _blobs[i3], _blobs[j3], _blobs[k3])
                    
                    if not eac_match.fits(dbc_match):
                        continue
                    
                    if not eac_match.fits(dab_match):
                        continue
                    
                    if not eac_match.fits(aed_match):
                        continue
                    
                    #print >> stderr, '   Confirmed match with EAC -', (i3, j3, k3)
                    
                    yield dbc_match, aed_match

def _blob_matches_secondary(blobs, aed_match):
    """ Generate known matches for AED (bottom) and paper-specific triangle groups.
    """
    from dimensions import feature_g_landscape_ltr, point_G_landscape_ltr, feature_f_landscape_ltr, point_F_landscape_ltr
    from dimensions import feature_g_portrait_ltr, point_G_portrait_ltr, feature_f_portrait_ltr, point_F_portrait_ltr
    from dimensions import feature_g_landscape_a4, point_G_landscape_a4, feature_f_landscape_a4, point_F_landscape_a4
    from dimensions import feature_g_portrait_a4, point_G_portrait_a4, feature_f_portrait_a4, point_F_portrait_a4
    from dimensions import feature_g_landscape_a3, point_G_landscape_a3, feature_f_landscape_a3, point_F_landscape_a3
    from dimensions import feature_g_portrait_a3, point_G_portrait_a3, feature_f_portrait_a3, point_F_portrait_a3

    from dimensions import min_size, theta_tol, ratio_tol

    features_fg = (
        (feature_g_landscape_ltr, point_G_landscape_ltr, feature_f_landscape_ltr, point_F_landscape_ltr),
        (feature_g_portrait_ltr,  point_G_portrait_ltr,  feature_f_portrait_ltr,  point_F_portrait_ltr),
        (feature_g_landscape_a4,  point_G_landscape_a4,  feature_f_landscape_a4,  point_F_landscape_a4),
        (feature_g_portrait_a4,   point_G_portrait_a4,   feature_f_portrait_a4,   point_F_portrait_a4),
        (feature_g_landscape_a3,  point_G_landscape_a3,  feature_f_landscape_a3,  point_F_landscape_a3),
        (feature_g_portrait_a3,   point_G_portrait_a3,   feature_f_portrait_a3,   point_F_portrait_a3)
      )

    for (feature_g, point_G, feature_f, point_F) in features_fg:
        g_theta, g_ratio = feature_g.theta, feature_g.ratio
        g_bounds = theta_ratio_bounds(g_theta, theta_tol, g_ratio, ratio_tol)
        g_matches = blobs2feats_fitted(aed_match.s1, aed_match.s2, blobs, *g_bounds)
        
        for g_tuple in g_matches:
            i0, j0, k0 = g_tuple[0:3]
            g_match = MatchedFeature(feature_g, blobs[i0], blobs[j0], blobs[k0])
            
            if not g_match.fits(aed_match):
                continue
            
            aed_blobs = (aed_match.s1, aed_match.s2)
            
            if g_match.s1 in aed_blobs and g_match.s2 in aed_blobs:
                blob_G = g_match.s3
            elif g_match.s1 in aed_blobs and g_match.s3 in aed_blobs:
                blob_G = g_match.s2
            elif g_match.s2 in aed_blobs and g_match.s3 in aed_blobs:
                blob_G = g_match.s1
            else:
                raise Exception('what?')
            
            #print >> stderr, '    Found a match for point G -', (i0, j0, k0)

            #
            # We think we have a match for point G, now check for point F.
            #
            
            f_theta, f_ratio = feature_f.theta, feature_f.ratio
            f_bounds = theta_ratio_bounds(f_theta, theta_tol, f_ratio, ratio_tol)
            f_matches = blobs2feats_fitted(blob_G, aed_match.s2, blobs, *f_bounds)
            
            for f_tuple in f_matches:
                i1, j1, k1 = f_tuple[0:3]
                f_match = MatchedFeature(feature_f, blobs[i1], blobs[j1], blobs[k1])
                
                if not f_match.fits(g_match):
                    continue

                #print >> stderr, '     Found a match for point F -', (i1, j1, k1), point_F
                
                #
                # Based on the identity of point_F, we can find paper size and orientation.
                #
                yield f_match, point_F

def read_code(image):
    """
    """
    jit = lambda: .2 * (random() - .5)
    original = image
    
    for attempt in range(10):
        decode = 'java', '-classpath', ':'.join(glob(pathjoin(dirname(__file__), 'lib/*.jar'))), 'qrdecode'
        decode = Popen(decode, stdin=PIPE, stdout=PIPE, stderr=PIPE)
        
        image.save(decode.stdin, 'PNG')
        decode.stdin.close()
        decode.wait()
        
        decoded = decode.stdout.read().strip()
        
        if decoded.startswith('http://'):
            break
        
        matrix = (1 + jit(), jit(), jit(), jit(), 1 + jit(), jit())
        image = original.transform(image.size, Image.AFFINE, matrix, Image.BICUBIC)
        
        print >> stderr, 'jittering QR code image by %.2f, %.2f, %.2f, %.2f, %.2f, %.2f' % matrix
    
    if not decoded.startswith('http://'):
        raise CodeReadException('Attempt to read QR code failed')
    
    html = ElementTree.parse(urlopen(decoded))
    
    print_id, paper, orientation = None, None, None
    north, west, south, east = None, None, None, None
    
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
                elif subspan.get('class') == 'paper-size':
                    paper = subspan.text
                elif subspan.get('class') == 'orientation':
                    orientation = subspan.text

    return print_id, north, west, south, east, paper, orientation

def get_paper_size(paper, orientation):
    """
    """
    if (paper, orientation) == ('letter', 'landscape'):
        from dimensions import paper_size_landscape_ltr as paper_size_pt
    
    elif (paper, orientation) == ('letter', 'portrait'):
        from dimensions import paper_size_portrait_ltr as paper_size_pt
    
    elif (paper, orientation) == ('a4', 'landscape'):
        from dimensions import paper_size_landscape_a4 as paper_size_pt
    
    elif (paper, orientation) == ('a4', 'portrait'):
        from dimensions import paper_size_portrait_a4 as paper_size_pt
    
    elif (paper, orientation) == ('a3', 'landscape'):
        from dimensions import paper_size_landscape_a3 as paper_size_pt
    
    elif (paper, orientation) == ('a3', 'portrait'):
        from dimensions import paper_size_portrait_a3 as paper_size_pt
    
    else:
        raise Exception('not yet')

    paper_width_pt, paper_height_pt = paper_size_pt
    
    return paper_width_pt, paper_height_pt

def generate_tiles(image, s2p, paper, orientation, north, west, south, east):
    """ Placeholder for now.
    """
    osm = OpenStreetMapProvider()
    
    paper_width_pt, paper_height_pt = get_paper_size(paper, orientation)
    
    for zoom in range(19):
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
        
        if zoom_dim/scan_dim < .1:
            # too zoomed-out
            continue
        
        if zoom_dim/scan_dim > 3.:
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

def draw_postblobs(postblob_img, blobs_abcde):
    """ Connect the dots on the post-blob image for the five common dots.
    """
    blob_A, blob_B, blob_C, blob_D, blob_E = blobs_abcde
    
    draw = ImageDraw(postblob_img)
    
    draw.line((blob_B.x, blob_B.y, blob_C.x, blob_C.y), fill=(0x99, 0x00, 0x00))
    draw.line((blob_D.x, blob_D.y, blob_C.x, blob_C.y), fill=(0x99, 0x00, 0x00))
    draw.line((blob_D.x, blob_D.y, blob_B.x, blob_B.y), fill=(0x99, 0x00, 0x00))
    
    draw.line((blob_A.x, blob_A.y, blob_D.x, blob_D.y), fill=(0x99, 0x00, 0x00))
    draw.line((blob_D.x, blob_D.y, blob_E.x, blob_E.y), fill=(0x99, 0x00, 0x00))
    draw.line((blob_E.x, blob_E.y, blob_A.x, blob_A.y), fill=(0x99, 0x00, 0x00))

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
    
    handle, postblob_filename = mkstemp(prefix='postblob-', suffix='.png')
    close(handle)
    
    _update_step(STEP_SIFTING)

    input = Image.open(StringIO(urlopen(url).read()))
    blobs = imgblobs(input, highpass_filename, preblobs_filename, postblob_filename)
    
    s, h, path, p, q, f = urlparse(url)
    uploaded_file = basename(path)
    
    yield 10
    
    _append_file('highpass.jpg', open(highpass_filename, 'r').read())
    _append_file('preblobs.jpg', open(preblobs_filename, 'r').read())
    postblob_img = Image.open(postblob_filename)

    rename(highpass_filename, 'highpass.jpg')
    rename(preblobs_filename, 'preblobs.jpg')
    unlink(postblob_filename)
    
    _update_step(STEP_FINDING_NEEDLES)

    for (s2p, paper, orientation, blobs_abcde) in paper_matches(blobs):

        yield 10

        print >> stderr, paper, orientation, '--', s2p
        
        qrcode_img = extract_image(s2p, (-90-9, -90-9, 0+9, 0+9), input, (500, 500))
        _append_image('qrcode.png', qrcode_img)
        qrcode_img.save('qrcode.png')
        
        yield 10

        _update_step(STEP_READING_QR_CODE)

        try:
            print_id, north, west, south, east, _paper, _orientation = read_code(qrcode_img)
        except CodeReadException:
            print >> stderr, 'could not read the QR code.'
            continue

        if (_paper, _orientation) != (paper, orientation):
            continue
        
        _update_step(STEP_TILING_UPLOADING)

        draw_postblobs(postblob_img, blobs_abcde)
        _append_image('postblob.jpg', postblob_img)
        postblob_img.save('postblob.jpg')
        
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

        _update_step(STEP_FINISHED)
        
        yield 5
        
        return
    
    #
    # If we got this far, it means nothing was detected in the image.
    #
    _update_step(STEP_FATAL_ERROR)

if __name__ == '__main__':

    url = argv[1]
    
    for d in main(None, None, None, url):
        pass
