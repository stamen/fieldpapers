from sys import argv
from math import log
from copy import copy
from itertools import product
from urllib import urlopen, urlencode
from os.path import join as pathjoin, dirname
from urlparse import urljoin, urlparse, parse_qs
from os import close, write, unlink
from json import dumps as json_encode
from optparse import OptionParser
from StringIO import StringIO
from tempfile import mkstemp
from shutil import move

from ModestMaps import Map, mapByExtent, mapByExtentZoom, mapByCenterZoom
from ModestMaps.Providers import TemplatedMercatorProvider
from ModestMaps.Geo import Location
from ModestMaps.Core import Point

from cairo import ImageSurface
from PIL import Image

from svgutils import create_cairo_font_face_for_file, place_image, draw_box, draw_circle
from dimensions import point_A, point_B, point_C, point_D, point_E, ptpin
from apiutils import append_print_file, finish_print, ALL_FINISHED
from cairoutils import get_drawing_context

def get_qrcode_image(print_href):
    """ Render a QR code to an ImageSurface.
    """
    scheme, host, path, p, query, f = urlparse(print_href)

    print_path = scheme + '://' + host + path
    print_id = parse_qs(query).get('id', [''])[0]
    
    q = {'print': print_id}
    u = urljoin(print_path, 'code.php') + '?' + urlencode(q)
    
    handle, filename = mkstemp(suffix='.png')
    
    try:
        write(handle, urlopen(u).read())
        close(handle)
        
        img = ImageSurface.create_from_png(filename)
        
    finally:
        unlink(filename)
    
    return img

def get_mmap_image(mmap):
    """ Render a Map to an ImageSurface.
    """
    handle, filename = mkstemp(suffix='.png')

    try:
        close(handle)
        mmap.draw(fatbits_ok=True).save(filename)
        
        img = ImageSurface.create_from_png(filename)
    
    finally:
        unlink(filename)

    return img

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
    
    location = mmap.pointLocation(Point(x, y))
    zoom = mmap.coordinate.zoom + (log(rows) / log(2))
    
    return mapByCenterZoom(mmap.provider, location, zoom, mmap.dimensions)

def paper_info(paper_size, orientation):
    """ Return page width, height, differentiating points and aspect ration.
    """
    dim = __import__('dimensions')
    
    paper_size = {'letter': 'ltr', 'a4': 'a4', 'a3': 'a3'}[paper_size.lower()]
    width, height = getattr(dim, 'paper_size_%(orientation)s_%(paper_size)s' % locals())
    point_F = getattr(dim, 'point_F_%(orientation)s_%(paper_size)s' % locals())
    point_G = getattr(dim, 'point_G_%(orientation)s_%(paper_size)s' % locals())
    ratio = getattr(dim, 'ratio_%(orientation)s_%(paper_size)s' % locals())
    
    return width, height, (point_F, point_G), ratio

def get_preview_map_size(orientation, paper_size):
    """
    """
    dim = __import__('dimensions')
    
    paper_size = {'letter': 'ltr', 'a4': 'a4', 'a3': 'a3'}[paper_size.lower()]
    width, height = getattr(dim, 'preview_size_%(orientation)s_%(paper_size)s' % locals())
    
    return width, height

def map_by_extent_zoom_size(provider, northwest, southeast, zoom, width, height):
    """
    """
    # we need it to cover a specific area
    mmap = mapByExtentZoom(provider, northwest, southeast, zoom)
                          
    # but we also we need it at a specific size
    mmap = Map(mmap.provider, Point(width, height), mmap.coordinate, mmap.offset)
    
    return mmap

def add_print_page(ctx, mmap, href, well_bounds_pt, points_FG, hm2pt_ratio):
    """
    """
    print 'Adding print page:', href
    
    well_xmin_pt, well_ymin_pt, well_xmax_pt, well_ymax_pt = well_bounds_pt
    well_width_pt, well_height_pt = well_xmax_pt - well_xmin_pt, well_ymax_pt - well_ymin_pt
    
    #
    # Offset drawing area to top-left of map area
    #
    ctx.translate(well_xmin_pt, well_ymin_pt)
    
    #
    # Build up map area
    #
    draw_box(ctx, 0, 0, well_width_pt, well_height_pt)
    ctx.set_source_rgb(.9, .9, .9)
    ctx.fill()
    
    img = get_mmap_image(mmap)
    place_image(ctx, img, 0, 0, well_width_pt, well_height_pt)
    
    #
    # Calculate positions of registration points
    #
    ctx.save()
    
    ctx.translate(well_width_pt, well_height_pt)
    ctx.scale(1/hm2pt_ratio, 1/hm2pt_ratio)
    
    reg_points = (point_A, point_B, point_C, point_D, point_E) + points_FG
    
    device_points = [ctx.user_to_device(pt.x, pt.y) for pt in reg_points]
    
    ctx.restore()
    
    #
    # Draw QR code area
    #
    ctx.save()
    
    ctx.translate(well_width_pt, well_height_pt)
    
    draw_box(ctx, 0, 0, -90, -90)
    ctx.set_source_rgb(1, 1, 1)
    ctx.fill()
    
    place_image(ctx, get_qrcode_image(href), -83, -83, 83, 83)
    
    ctx.restore()
    
    #
    # Draw registration points
    #
    for (x, y) in device_points:
        x, y = ctx.device_to_user(x, y)
    
        draw_circle(ctx, x, y, .12 * ptpin)
        ctx.set_source_rgb(0, 0, 0)
        ctx.set_line_width(.5)
        ctx.set_dash([1.5, 3])
        ctx.stroke()

    for (x, y) in device_points:
        x, y = ctx.device_to_user(x, y)
    
        draw_circle(ctx, x, y, .12 * ptpin)
        ctx.set_source_rgb(1, 1, 1)
        ctx.fill()

    for (x, y) in device_points:
        x, y = ctx.device_to_user(x, y)
    
        draw_circle(ctx, x, y, .06 * ptpin)
        ctx.set_source_rgb(0, 0, 0)
        ctx.fill()
    
    #
    # Draw top-left icon
    #
    icon = pathjoin(dirname(__file__), '../site/lib/print/icon.png')
    img = ImageSurface.create_from_png(icon)
    place_image(ctx, img, 0, -29.13, 19.2, 25.6)
    
    try:
        font = create_cairo_font_face_for_file('fonts/Helvetica-Bold.ttf')
    except:
        # no text for us.
        pass
    else:
        # draw some text.
        ctx.set_font_face(font)
        ctx.set_font_size(24)
        ctx.move_to(0 + 19.2 + 8, -29.13 + 25.6 - 1)
        ctx.show_text('Walking Papers')
    
    try:
        font = create_cairo_font_face_for_file('fonts/Helvetica.ttf')
    except:
        # no text for us.
        pass
    else:
        ctx.set_font_face(font)
        ctx.set_font_size(8)
        
        lines = ['OSM data ©2011 CC-BY-SA Openstreetmap.org contributors.',
                 'Help improve OpenStreetMap by drawing on this map, then visit',
                 href or '']
        
        text_width = max([ctx.text_extents(line)[2] for line in lines])
        
        ctx.move_to(well_width_pt - text_width, -25)
        ctx.show_text(lines[0])

        ctx.move_to(well_width_pt - text_width, -15)
        ctx.show_text(lines[1])

        ctx.move_to(well_width_pt - text_width, -5)
        ctx.show_text(lines[2])
    
    ctx.show_page()

parser = OptionParser()

parser.set_defaults(layout='1,1',
                    bounds=(37.81211263, -122.26755482, 37.80641650, -122.25725514),
                    zoom=16, paper_size='letter', orientation='landscape',
                    provider='http://tile.openstreetmap.org/{Z}/{X}/{Y}.png')

papers = 'a3 a4 letter'.split()
orientations = 'landscape portrait'.split()
layouts = '1,1 2,2 4,4'.split()

parser.add_option('-s', '--paper-size', dest='paper_size',
                  help='Choice of papers: %s.' % ', '.join(papers),
                  choices=papers)

parser.add_option('-o', '--orientation', dest='orientation',
                  help='Choice of orientations: %s.' % ', '.join(orientations),
                  choices=orientations)

parser.add_option('-l', '--layout', dest='layout',
                  help='Choice of layouts: %s.' % ', '.join(layouts),
                  choices=layouts)

parser.add_option('-b', '--bounds', dest='bounds',
                  help='Choice of bounds: north, west, south, east.',
                  type='float', nargs=4)

parser.add_option('-z', '--zoom', dest='zoom',
                  help='Map zoom level.',
                  type='int')

parser.add_option('-p', '--provider', dest='provider',
                  help='Map provider in URL template form.')

def main(apibase, password, print_id, pages, paper_size, orientation):
    """
    """
    yield 5
    
    print_path = 'print.php?' + urlencode({'id': print_id})
    print_href = print_id and urljoin(apibase.rstrip('/')+'/', print_path) or None
    print_form = {}
    
    #
    # Prepare a shorthands for pushing data.
    #

    _append_file = lambda name, body: print_id and append_print_file(print_id, name, body, apibase, password) or None
    _finish_print = lambda form: print_id and finish_print(apibase, password, print_id, form) or None
    
    print 'Print:', print_id
    print 'Paper:', orientation, paper_size
    
    #
    # Prepare output context.
    #

    handle, print_filename = mkstemp(suffix='.pdf')
    close(handle)
    
    page_width_pt, page_height_pt, points_FG, hm2pt_ratio = paper_info(paper_size, orientation)
    print_context, finish_drawing = get_drawing_context(print_filename, page_width_pt, page_height_pt)
    
    try:
        map_xmin_pt = .5 * ptpin
        map_ymin_pt = 1 * ptpin
        map_xmax_pt = page_width_pt - .5 * ptpin
        map_ymax_pt = page_height_pt - .5 * ptpin
        
        map_bounds_pt = map_xmin_pt, map_ymin_pt, map_xmax_pt, map_ymax_pt
    
        #
        # Add pages to the PDF one by one.
        #
    
        for page in pages:
            page_href = print_href and (print_href + '/%(number)d' % page) or None
        
            provider = TemplatedMercatorProvider(page['provider'])
            zoom = page['zoom']
            
            north, west, south, east = page['bounds']
            northwest = Location(north, west)
            southeast = Location(south, east)
            
            page_mmap = mapByExtentZoom(provider, northwest, southeast, zoom)
            
            yield 60
            
            add_print_page(print_context, page_mmap, page_href, map_bounds_pt, points_FG, hm2pt_ratio)
            
            #
            # Now make a smaller preview map for the page,
            # 600px looking like a reasonable upper bound.
            #
            
            preview_mmap = copy(page_mmap)
            
            while preview_mmap.dimensions.x > 600:
                preview_zoom = preview_mmap.coordinate.zoom - 1
                preview_mmap = mapByExtentZoom(provider, northwest, southeast, preview_zoom)
    
            yield 15
            
            out = StringIO()
            preview_mmap.draw(fatbits_ok=True).save(out, format='JPEG', quality=85)
            preview_url = _append_file('preview-p%(number)d.jpg' % page, out.getvalue())
            print_form['pages[%(number)d][preview_url]' % page] = preview_url
    
        #
        # Complete the PDF and upload it.
        #
        
        finish_drawing()
        
        pdf_name = 'walking-paper-%s.pdf' % print_id
        pdf_url = _append_file(pdf_name, open(print_filename, 'r').read())
        print_form['pdf_url'] = pdf_url

    except:
        raise
    
    finally:
        unlink(print_filename)
    
    #
    # Make a small preview map of the whole print coverage area.
    #
    
    provider = TemplatedMercatorProvider(pages[0]['provider'])
    
    norths, wests, souths, easts = zip(*[page['bounds'] for page in pages])
    northwest = Location(max(norths), min(wests))
    southeast = Location(min(souths), max(easts))
    
    dimensions = Point(*get_preview_map_size(orientation, paper_size))
    
    preview_mmap = mapByExtent(provider, northwest, southeast, dimensions)
    
    yield 15

    out = StringIO()
    preview_mmap.draw(fatbits_ok=True).save(out, format='JPEG', quality=85)
    preview_url = _append_file('preview.jpg' % page, out.getvalue())
    print_form['preview_url'] = preview_url
    
    #
    # All done, wrap it up.
    #
    
    _finish_print(print_form)
    
    yield ALL_FINISHED

if __name__ == '__main__':

    opts, args = parser.parse_args()
    
    for d in main(None, None, None, opts.paper_size, opts.orientation, opts.layout, opts.provider, opts.bounds, opts.zoom):
        pass
