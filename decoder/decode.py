#!/usr/bin/env python

import traceback

from sys import argv
from StringIO import StringIO
from subprocess import Popen, PIPE
from os.path import basename, dirname, join as pathjoin
from os import close, write, unlink
from urlparse import urlparse, urljoin
from tempfile import mkstemp
from random import random
from shutil import move
from glob import glob

try:
    import PIL
except ImportError:
    import Image
    from ImageDraw import ImageDraw
else:
    from PIL import Image
    from PIL.ImageDraw import ImageDraw

from ModestMaps.Core import Point, Coordinate

from geoutils import create_geotiff, list_tiles_for_bounds, extract_tile_for_coord
from apiutils import append_scan_file, finish_scan, update_scan, fail_scan, get_print_info
from featuremath import MatchedFeature, blobs2features, blobs2feats_limited, blobs2feats_fitted, theta_ratio_bounds
from imagemath import imgblobs, extract_image, open as imageopen
from matrixmath import Transform, quad2quad
from dimensions import ptpin

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
            # determining paper size and orientation based on identity of point E.
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
    
        #print 'Found a match for DBC -', (i0, j0, k0)
        
        dab_matches = blobs2feats_limited([blobs[i0]], blobs, [blobs[j0]], *theta_ratio_bounds(dab_theta, theta_tol, dab_ratio, ratio_tol))
        
        for dab_tuple in dab_matches:
            i1, j1, k1 = i0, dab_tuple[1], j0
            dab_match = MatchedFeature(feature_dab, blobs[i1], blobs[j1], blobs[k1])
            
            if not dab_match.fits(dbc_match):
                continue
            
            #print ' Found a match for DAB -', (i1, j1, k1)
            
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
                
                #print '  Found a match for AED -', (i2, j2, k2)
                
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
                    
                    #print '   Confirmed match with EAC -', (i3, j3, k3)
                    
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
            
            #print '    Found a match for point G -', (i0, j0, k0)

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

                #print '     Found a match for point F -', (i1, j1, k1), point_F
                
                #
                # Based on the identity of point_F, we can find paper size and orientation.
                #
                yield f_match, point_F

def read_code(image):
    """
    """
    jit = lambda: .2 * (random() - .5)
    decode = 'zbarimg', '--raw', '-q', '/dev/stdin'
    decode = Popen(decode, stdin=PIPE, stdout=PIPE, stderr=PIPE)

    image.save(decode.stdin, 'PNG')
    decode.stdin.close()
    decode.wait()

    print_url = decode.stdout.read().strip()
    
    if not print_url.startswith('http://'):
        raise CodeReadException('Attempt to read QR code failed')
    
    print_id, north, west, south, east, paper, orientation, layout = get_print_info(print_url)
    
    if layout == 'half-page' and orientation == 'landscape':
        east += (east - west)
        print 'Adjusted', orientation, layout, 'bounds to %.6f, %.6f, %.6f, %.6f' % (north, west, south, east)

    elif layout == 'half-page' and orientation == 'portrait':
        south += (south - north)
        print 'Adjusted', orientation, layout, 'bounds to %.6f, %.6f, %.6f, %.6f' % (north, west, south, east)
    
    else:
        print 'Kept', orientation, layout, 'bounds at %.6f, %.6f, %.6f, %.6f' % (north, west, south, east)

    return print_id, print_url, north, west, south, east, paper, orientation, layout

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
    #
    # Prepare a shorthand for pushing data.
    #
    def _finish_scan(uploaded_file, print_id, print_page_number, print_url, min_coord, max_coord, img_bounds):
        if scan_id:
            finish_scan(apibase, password, scan_id, uploaded_file, print_id, print_page_number, print_url, min_coord, max_coord, img_bounds)
    
    def _update_scan(uploaded_file, progress):
        if scan_id:
            update_scan(apibase, password, scan_id, progress)
    
    def _fail_scan():
        if scan_id:
            fail_scan(apibase, password, scan_id)
    
    def _append_file(name, body):
        """ Append generally a file.
        """
        if scan_id:
            append_scan_file(scan_id, name, body, apibase, password)
    
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
    
    try:
        print 'Downloading', url
    
        input = imageopen(url)
        blobs = imgblobs(input, highpass_filename, preblobs_filename, postblob_filename)
    
        s, h, path, p, q, f = urlparse(url)
        uploaded_file = basename(path)

        _update_scan(uploaded_file, 0.2)
        
        _append_file('highpass.jpg', open(highpass_filename, 'r').read())
        _append_file('preblobs.jpg', open(preblobs_filename, 'r').read())
        postblob_img = Image.open(postblob_filename)
    
        move(highpass_filename, 'highpass.jpg')
        move(preblobs_filename, 'preblobs.jpg')
        unlink(postblob_filename)

        _update_scan(uploaded_file, 0.3)

        for (s2p, paper, orientation, blobs_abcde) in paper_matches(blobs):
            print paper, orientation, '--', s2p
            
            qrcode_img = extract_image(s2p, (-90-9, -90-9, 0+9, 0+9), input, (500, 500))
            _append_image('qrcode.png', qrcode_img)
            qrcode_img.save('qrcode.png')
            
            try:
                print_id, print_url, north, west, south, east, _paper, _orientation, _layout = read_code(qrcode_img)
            except CodeReadException:
                print 'could not read the QR code.'
                continue
    
            if (_paper, _orientation) != (paper, orientation):
                continue
            
            print_page_number = None

            if print_url.startswith(apibase):
                if '/' in print_id:
                    print_id, print_page_number = print_id.split('/', 1)
            else:
                print_id = None
            
            draw_postblobs(postblob_img, blobs_abcde)
            _append_image('postblob.jpg', postblob_img)
            postblob_img.save('postblob.jpg')
    
            _update_scan(uploaded_file, 0.4)
            
            print 'geotiff...',
            
            paper_width_pt, paper_height_pt = get_paper_size(paper, orientation)
            geo_args = paper_width_pt, paper_height_pt, north, west, south, east
            
            geotiff_bytes, geojpeg_img, img_bounds = create_geotiff(input, s2p.inverse(), *geo_args)
            
            _append_file('walking-paper-%s.tif' % scan_id, geotiff_bytes)
            _append_image('walking-paper-%s.jpg' % scan_id, geojpeg_img)
    
            _update_scan(uploaded_file, 0.5)
            
            print 'done.'
            print 'tiles...',
            
            minrow, mincol, minzoom = 2**20, 2**20, 20
            maxrow, maxcol, maxzoom = 0, 0, 0
            
            tiles_needed = list_tiles_for_bounds(input, s2p, *geo_args)
            
            for (index, (coord, scan2coord)) in enumerate(tiles_needed):
                if index % 10 == 0:
                    _update_scan(uploaded_file, 0.5 + 0.5 * float(index) / len(tiles_needed))
                
                tile_img = extract_tile_for_coord(input, coord, scan2coord)
                _append_image('%(zoom)d/%(column)d/%(row)d.jpg' % coord.__dict__, tile_img)

                print coord.zoom,
                
                minrow = min(minrow, coord.row)
                mincol = min(mincol, coord.column)
                minzoom = min(minzoom, coord.zoom)
                
                maxrow = max(maxrow, coord.row)
                maxcol = max(maxcol, coord.column)
                maxzoom = max(minzoom, coord.zoom)
            
            print '...done.'
    
            preview_img = input.copy()
            preview_img.thumbnail((409, 280), Image.ANTIALIAS)
            _append_image('preview.jpg', preview_img)
            
            large_img = input.copy()
            large_img.thumbnail((900, 900), Image.ANTIALIAS)
            _append_image('large.jpg', large_img)
            
            min_coord = Coordinate(minrow, mincol, minzoom)
            max_coord = Coordinate(maxrow, maxcol, maxzoom)
            
            break

    except Exception, e:
        print 'Failed because:', e
        traceback.print_exc()

        _fail_scan()
    
    else:
        if 'print_id' in locals():
            _finish_scan(uploaded_file, print_id, print_page_number, print_url, min_coord, max_coord, img_bounds)

        else:
            print 'Failed, unable to find a print_id'
            _fail_scan()


if __name__ == '__main__':
    main(None, None, None, argv[1])
