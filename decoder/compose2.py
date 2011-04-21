from sys import argv
from math import log
from itertools import product
from urllib import urlopen, urlencode
from os.path import join as pathjoin, dirname
from urlparse import urljoin, urlparse, parse_qs
from os import close, write, unlink, rename
from json import dumps as json_encode
from optparse import OptionParser
from StringIO import StringIO
from tempfile import mkstemp

from ModestMaps import Map, mapByExtentZoom, mapByCenterZoom
from ModestMaps.Providers import TemplatedMercatorProvider
from ModestMaps.Geo import Location
from ModestMaps.Core import Point

from cairo import ImageSurface, PDFSurface, Context
from PIL import Image

from svgutils import create_cairo_font_face_for_file, place_image, draw_box, draw_circle
from dimensions import point_A, point_B, point_C, point_D, point_E, ptpin
from apiutils import append_print_file, finish_print, ALL_FINISHED
from cairoutils import FakeContext

def get_qrcode_image(print_href):
    """ Render a QR code to an ImageSurface.
    """
    scheme, host, path, p, query, f = urlparse(print_href)

    print_path = scheme + '://' + host + path
    print_id = parse_qs(query).get('id', [''])[0]
    
    q = {'print': print_id}
    u = urljoin(print_path, 'code.php') + '?' + urlencode(q)
    
    handle, filename = mkstemp(suffix='.png')

    write(handle, urlopen(u).read())
    close(handle)
    
    img = ImageSurface.create_from_png(filename)
    
    unlink(filename)

    return img

def get_mmap_image(mmap):
    """ Render a Map to an ImageSurface.
    """
    handle, filename = mkstemp(suffix='.png')

    close(handle)
    mmap.draw(fatbits_ok=True).save(filename)
    
    img = ImageSurface.create_from_png(filename)
    
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
    """
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

def main(apibase, password, print_id, paper_size, orientation=None, layout=None, provider=None, bounds=None, zoom=None, geotiff_url=None):
    """
    """
    yield 5
    
    print_path = 'print.php?' + urlencode({'id': print_id})
    print_href = print_id and urljoin(apibase.rstrip('/')+'/', print_path) or None
    print_data = {'pages': []}
    
    #
    # Prepare a shorthand for pushing data.
    #
    _append_file = lambda name, body: print_id and append_print_file(print_id, name, body, apibase, password) or None
    _finish_print = lambda pdf, prev, data: print_id and finish_print(apibase, password, print_id, pdf, prev, data) or None
    
    print 'Print:', print_id
    print 'Paper:', paper_size
    
    handle, print_filename = mkstemp(suffix='.pdf')
    close(handle)
    
    page_width_pt, page_height_pt, points_FG, hm2pt_ratio = paper_info(paper_size, orientation)
    print_surface = PDFSurface(print_filename, page_width_pt, page_height_pt)
    print_context = FakeContext(print_surface, page_height_pt) # Context(print_surface)

    map_xmin_pt = .5 * ptpin
    map_ymin_pt = 1 * ptpin
    map_xmax_pt = page_width_pt - .5 * ptpin
    map_ymax_pt = page_height_pt - .5 * ptpin
    
    map_bounds_pt = map_xmin_pt, map_ymin_pt, map_xmax_pt, map_ymax_pt

    if orientation and bounds and zoom and provider and layout:
    
        print 'Orientation:', orientation
        print 'Bounds:', bounds
        print 'Zoom:', zoom
        print 'Layout:', layout
        print 'Provider:', provider
        print 'Size:', get_preview_map_size(orientation, paper_size)
        
        print_pages = print_data['pages']
        
        north, west, south, east = bounds
        width, height = get_preview_map_size(orientation, paper_size)
        
        northwest = Location(north, west)
        southeast = Location(south, east)
        
        #
        # Prepare preview.jpg
        #
        mmap = map_by_extent_zoom_size(TemplatedMercatorProvider(provider),
                                       northwest, southeast, zoom,
                                       width, height)
        
        yield 30
        
        out = StringIO()
        mmap.draw(fatbits_ok=True).save(out, format='JPEG')
        preview_url = _append_file('preview.jpg', out.getvalue())
        
        print 'Sent preview.jpg'
        
        #
        # Prepare full-size image
        #
        zdiff = min(18, zoom + 2) - zoom
        print 'Zoom diff:', zdiff
        
        mmap = map_by_extent_zoom_size(TemplatedMercatorProvider(provider),
                                       northwest, southeast, zoom + zdiff,
                                       width * 2**zdiff, height * 2**zdiff)
        
        yield 60
        yield 10 # remove me
        
        add_print_page(print_context, mmap, print_href, map_bounds_pt, points_FG, hm2pt_ratio)
        
        # out = StringIO()
        # mmap.draw().save(out, format='JPEG')
        # print_url = append_print_file(print_id, 'print.jpg', out.getvalue(), apibase, password)
        # 
        # print 'Sent print.jpg'
        
        page_nw = mmap.pointLocation(Point(0, 0))
        page_se = mmap.pointLocation(mmap.dimensions)
        
        page_data = {'print': 'print.jpg', 'preview': 'preview.jpg', 'bounds': {}}
        page_data['bounds'].update({'north': page_nw.lat, 'west': page_nw.lon})
        page_data['bounds'].update({'south': page_se.lat, 'east': page_se.lon})
        print_pages.append(page_data)
        
        rows, cols = map(int, layout.split(','))
        
        if rows > 1 and cols > 1:
            for (row, col) in product(range(rows), range(cols)):
                
                sub_mmap = get_mmap_page(mmap, row, col, rows, cols)
                sub_part = '%(row)d,%(col)d' % locals()
                sub_name = 'print-%(sub_part)s.jpg' % locals()
                sub_href = print_href + '/' + sub_part
                
                yield 60
                
                add_print_page(print_context, sub_mmap, sub_href, map_bounds_pt, points_FG, hm2pt_ratio)
        
                #
                # Prepare preview image
                #
                prev_cen = sub_mmap.pointLocation(Point(sub_mmap.dimensions.x / 2, sub_mmap.dimensions.y / 2))
                prev_dim = Point(sub_mmap.dimensions.x / 2**zdiff, sub_mmap.dimensions.y / 2**zdiff)
                prev_mmap = mapByCenterZoom(sub_mmap.provider, prev_cen, sub_mmap.coordinate.zoom - zdiff, prev_dim)
                prev_name = 'preview-%(sub_part)s.jpg' % locals()
        
                out = StringIO()
                prev_mmap.draw(fatbits_ok=True).save(out, format='JPEG')
                prev_href = _append_file(prev_name, out.getvalue())
                
                #
                # Populate page data
                #
                page_nw = sub_mmap.pointLocation(Point(0, 0))
                page_se = sub_mmap.pointLocation(sub_mmap.dimensions)
                
                page_data = {'part': sub_part, 'preview_href': prev_href, 'bounds': {}}
                page_data['bounds'].update({'north': page_nw.lat, 'west': page_nw.lon})
                page_data['bounds'].update({'south': page_se.lat, 'east': page_se.lon})

                print_pages.append(page_data)
    
    print_surface.finish()
    
    yield 60
    
    pdf_name = 'walking-paper-%s.pdf' % print_id
    pdf_url = _append_file(pdf_name, open(print_filename, 'r').read())
    
    print json_encode(print_data)

    yield 10
    
    rename(print_filename, 'out.pdf')
    
    return
    
    _finish_print(pdf_url, preview_url, json_encode(print_data))
    
    yield ALL_FINISHED

if __name__ == '__main__':

    opts, args = parser.parse_args()
    
    for d in main(None, None, None, opts.paper_size, opts.orientation, opts.layout, opts.provider, opts.bounds, opts.zoom):
        pass
