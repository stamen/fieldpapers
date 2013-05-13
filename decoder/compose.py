from math import pi
from copy import copy
from urllib import urlopen, urlencode
from os.path import join as pathjoin, dirname, realpath
from urlparse import urljoin, urlparse, parse_qs
from os import close, write, unlink
from optparse import OptionParser
from StringIO import StringIO
from tempfile import mkstemp

from ModestMaps import mapByExtent, mapByExtentZoom
from ModestMaps.Providers import TemplatedMercatorProvider
from ModestMaps.Geo import Location
from ModestMaps.Core import Point

from cairo import ImageSurface

from svgutils import create_cairo_font_face_for_file, place_image, draw_box, draw_circle, draw_cross, flow_text
from dimensions import point_A, point_B, point_C, point_D, point_E, ptpin
from apiutils import append_print_file, finish_print, update_print, ALL_FINISHED
from cairoutils import get_drawing_context

cached_fonts = dict()

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
    
    return int(width), int(height)

def add_page_text(ctx, text, x, y, width, height):
    """
    """
    ctx.save()
    ctx.translate(x, y)
    ctx.move_to(0, 12)
    
    try:
        font_file = realpath('fonts/Helvetica.ttf')
    
        if font_file not in cached_fonts:
            cached_fonts[font_file] = create_cairo_font_face_for_file(font_file)
        
        font = cached_fonts[font_file]

    except:
        # hm.
        pass

    else:
        ctx.set_source_rgb(0, 0, 0)
        ctx.set_font_face(font)
        ctx.set_font_size(10)
        
        flow_text(ctx, width, 12, text)
    
    ctx.restore()

def get_map_scale(mmap, map_height_pt):
    """
    """
    north = mmap.pointLocation(Point(0, 0)).lat
    south = mmap.pointLocation(mmap.dimensions).lat
    
    vertical_degrees = north - south
    vertical_meters = 6378137 * pi * 2 * vertical_degrees / 360
    pts_per_meter = map_height_pt / vertical_meters
    
    # a selection of reasonable scale values to show
    meterses = range(50, 300, 50) + range(300, 1000, 100) + range(1000, 10000, 1000) + range(10000, 100000, 10000) + range(100000, 1000000, 100000) + range(1000000, 10000000, 1000000)
    
    for meters in meterses:
        points = meters * pts_per_meter
        
        if points > 100:
            # stop at an inch and a half or so
            break

    if meters > 1000:
        distance = '%d' % (meters / 1000.0)
        units = 'kilometers'
    elif meters == 1000:
        distance = '%d' % (meters / 1000.0)
        units = 'kilometer'
    else:
        distance = '%d' % meters
        units = 'meters'
    
    return points, distance, units

def add_scale_bar(ctx, mmap, map_height_pt):
    """
    """
    size, distance, units = get_map_scale(mmap, map_height_pt)
    
    ctx.save()
    ctx.translate(60, map_height_pt - 20)
    
    draw_box(ctx, -50, -10, size + 10 + 45, 20)
    ctx.set_source_rgb(1, 1, 1)
    ctx.fill()
    
    #
    # true north
    #

    draw_circle(ctx, -40, 0, 6.7)
    ctx.set_source_rgb(0, 0, 0)
    ctx.fill()
    
    ctx.move_to(-40, -6.7)
    ctx.line_to(-38.75, -2.2)
    ctx.line_to(-41.25, -2.2)
    ctx.line_to(-40, -6.5)
    ctx.set_source_rgb(1, 1, 1)
    ctx.fill()
    
    ctx.set_source_rgb(0, 0, 0)
    ctx.set_font_size(5.8)

    ctx.move_to(-25.1, -2.1)
    ctx.show_text('TRUE')
    ctx.move_to(-27.6, 4.9)
    ctx.show_text('NORTH')

    #
    # scale bar
    #

    ctx.move_to(0, 2)
    ctx.line_to(0, 5)
    ctx.line_to(size, 5)
    ctx.line_to(size, 2)

    ctx.set_source_rgb(0, 0, 0)
    ctx.set_line_width(.5)
    ctx.set_dash([])
    ctx.stroke()

    ctx.set_font_size(9)
    zero_width = ctx.text_extents('0')[2]
    distance_width = ctx.text_extents(distance)[2]

    ctx.move_to(0, 0)
    ctx.show_text('0')
    
    ctx.move_to(size - distance_width, 0)
    ctx.show_text(distance)
    
    ctx.set_font_size(7)
    units_width = ctx.text_extents(units)[2]

    ctx.move_to(zero_width + (size - zero_width - distance_width)/2 - units_width/2, 0)
    ctx.show_text(units.upper())
    
    ctx.restore()

def add_print_page(ctx, mmap, href, well_bounds_pt, points_FG, hm2pt_ratio, layout, text, mark, fuzzy, indexees):
    """
    """
    print 'Adding print page:', href
    
    well_xmin_pt, well_ymin_pt, well_xmax_pt, well_ymax_pt = well_bounds_pt
    well_width_pt, well_height_pt = well_xmax_pt - well_xmin_pt, well_ymax_pt - well_ymin_pt
    well_aspect_ratio = well_width_pt / well_height_pt
    
    #
    # Offset drawing area to top-left of map area
    #
    ctx.translate(well_xmin_pt, well_ymin_pt)
    
    #
    # Build up map area
    #
    img = get_mmap_image(mmap)
    
    if layout == 'half-page' and well_aspect_ratio > 1:
        map_width_pt, map_height_pt = well_width_pt/2, well_height_pt
        add_page_text(ctx, text, map_width_pt + 24, 24, map_width_pt - 48, map_height_pt - 48)

    elif layout == 'half-page' and well_aspect_ratio < 1:
        map_width_pt, map_height_pt = well_width_pt, well_height_pt/2
        add_page_text(ctx, text, 32, map_height_pt + 16, map_width_pt - 64, map_height_pt - 32)

    else:
        map_width_pt, map_height_pt = well_width_pt, well_height_pt
    
    place_image(ctx, img, 0, 0, map_width_pt, map_height_pt)
    
    #
    # Draw a dot if need be
    #
    if fuzzy is not None:
        loc = Location(fuzzy[1], fuzzy[0])
        pt = mmap.locationPoint(loc)

        x = map_width_pt * float(pt.x) / mmap.dimensions.x
        y = map_height_pt * float(pt.y) / mmap.dimensions.y
    
        draw_circle(ctx, x, y, 20)
        ctx.set_source_rgb(0, 0, 0)
        ctx.set_line_width(2)
        ctx.set_dash([2, 6])
        ctx.stroke()
    
    #
    # X marks the spot, if needed
    #
    if mark is not None:
        loc = Location(mark[1], mark[0])
        pt = mmap.locationPoint(loc)

        x = map_width_pt * float(pt.x) / mmap.dimensions.x
        y = map_height_pt * float(pt.y) / mmap.dimensions.y
        
        draw_cross(ctx, x, y, 8, 6)
        ctx.set_source_rgb(1, 1, 1)
        ctx.fill()
        
        draw_cross(ctx, x, y, 8, 4)
        ctx.set_source_rgb(0, 0, 0)
        ctx.fill()
    
    #
    # Perhaps some boxes?
    #
    page_numbers = []
    
    for page in indexees:
        north, west, south, east = page['bounds']
        
        ul = mmap.locationPoint(Location(north, west))
        lr = mmap.locationPoint(Location(south, east))
        
        x1 = map_width_pt * float(ul.x) / mmap.dimensions.x
        x2 = map_width_pt * float(lr.x) / mmap.dimensions.x
        y1 = map_height_pt * float(ul.y) / mmap.dimensions.y
        y2 = map_height_pt * float(lr.y) / mmap.dimensions.y
        
        draw_box(ctx, x1, y1, x2-x1, y2-y1)
        ctx.set_source_rgb(0, 0, 0)
        ctx.set_line_width(1)
        ctx.set_dash([])
        ctx.stroke()
        
        page_numbers.append((x1, y1, x2, y2, page['number']))
    
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
    icon = pathjoin(dirname(__file__), 'images/logo.png')
    img = ImageSurface.create_from_png(icon)
    place_image(ctx, img, 0, -36, 129.1, 36)
    
    try:
        font_file = realpath('fonts/Helvetica.ttf')
    
        if font_file not in cached_fonts:
            cached_fonts[font_file] = create_cairo_font_face_for_file(font_file)
        
        font = cached_fonts[font_file]
    except:
        # no text for us.
        pass
    else:
        ctx.set_font_face(font)
        ctx.set_font_size(12)
        
        line = href
        text_width = ctx.text_extents(line)[2]
        
        ctx.move_to(well_width_pt - text_width, -6)
        ctx.show_text(line)
        
        add_scale_bar(ctx, mmap, map_height_pt)
        
        ctx.set_font_face(font)
        ctx.set_font_size(18)

        for (x1, y1, x2, y2, number) in page_numbers:
            number_w, number_h = ctx.text_extents(number)[2:4]
            offset_x, offset_y = (x1 + x2 - number_w) / 2, (y1 + y2 + number_h) / 2
            
            draw_box(ctx, offset_x - 4, offset_y - number_h - 4, number_w + 8, number_h + 8)
            ctx.set_source_rgb(1, 1, 1)
            ctx.fill()
    
            ctx.set_source_rgb(0, 0, 0)
            ctx.move_to(offset_x, offset_y)
            ctx.show_text(number)
    
    ctx.show_page()

parser = OptionParser()

parser.set_defaults(bounds=(37.81211263, -122.26755482, 37.80641650, -122.25725514),
                    zoom=16, paper_size='letter', orientation='landscape',
                    provider='http://tile.openstreetmap.org/{Z}/{X}/{Y}.png')

papers = 'a3 a4 letter'.split()
orientations = 'landscape portrait'.split()

parser.add_option('-s', '--paper-size', dest='paper_size',
                  help='Choice of papers: %s.' % ', '.join(papers),
                  choices=papers)

parser.add_option('-o', '--orientation', dest='orientation',
                  help='Choice of orientations: %s.' % ', '.join(orientations),
                  choices=orientations)

parser.add_option('-b', '--bounds', dest='bounds',
                  help='Choice of bounds: north, west, south, east.',
                  type='float', nargs=4)

parser.add_option('-z', '--zoom', dest='zoom',
                  help='Map zoom level.',
                  type='int')

parser.add_option('-p', '--provider', dest='provider',
                  help='Map provider in URL template form.')

def main(apibase, password, print_id, pages, paper_size, orientation, layout):
    """
    """
    yield 5
    
    print_path = 'atlas.php?' + urlencode({'id': print_id})
    print_href = print_id and urljoin(apibase.rstrip('/')+'/', print_path) or None
    print_info = {}
    
    #
    # Prepare a shorthands for pushing data.
    #

    _append_file = lambda name, body: print_id and append_print_file(print_id, name, body, apibase, password) or None
    _finish_print = lambda print_info: print_id and finish_print(apibase, password, print_id, print_info) or None
    _update_print = lambda progress: print_id and update_print(apibase, password, print_id, progress) or None
    
    print 'Print:', print_id
    print 'Paper:', orientation, paper_size, layout
    
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
    
        for (index, page) in enumerate(pages):
            _update_print(0.1 + 0.9 * float(index) / len(pages))

            page_href = print_href and (print_href + '/%(number)s' % page) or None
        
            provider = TemplatedMercatorProvider(page['provider'])
            zoom = page['zoom']

            mark = page.get('mark', None) or None
            fuzzy = page.get('fuzzy', None) or None
            text = unicode(page.get('text', None) or '').encode('utf8')
            role = page.get('role', None) or None
            
            north, west, south, east = page['bounds']
            northwest = Location(north, west)
            southeast = Location(south, east)
            
            page_mmap = mapByExtentZoom(provider, northwest, southeast, zoom)
            
            yield 60
            
            if role == 'index':
                indexees = [pages[other] for other in range(len(pages)) if other != index]
            else:
                indexees = []
            
            add_print_page(print_context, page_mmap, page_href, map_bounds_pt, points_FG, hm2pt_ratio, layout, text, mark, fuzzy, indexees)
            
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
            preview_url = _append_file('preview-p%(number)s.jpg' % page, out.getvalue())
            print_info['pages[%(number)s][preview_url]' % page] = preview_url
    
        #
        # Complete the PDF and upload it.
        #
        
        finish_drawing()
        
        pdf_name = 'walking-paper-%s.pdf' % print_id
        pdf_url = _append_file(pdf_name, open(print_filename, 'r').read())
        print_info['pdf_url'] = pdf_url

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
    print_info['preview_url'] = preview_url
    
    #
    # All done, wrap it up.
    #
    
    _finish_print(print_info)
    
    yield ALL_FINISHED

if __name__ == '__main__':

    opts, args = parser.parse_args()
    
    for d in main(None, None, None, opts.paper_size, opts.orientation, None, opts.provider, opts.bounds, opts.zoom):
        pass
