from sys import argv
from urllib import urlopen, urlencode
from os.path import join as pathjoin, dirname
from os import close, write, unlink
from optparse import OptionParser
from tempfile import mkstemp

from ModestMaps import Map, mapByExtentZoom
from ModestMaps.Providers import TemplatedMercatorProvider
from ModestMaps.Geo import Location
from ModestMaps.Core import Point

from cairo import ImageSurface, PDFSurface, Context
from PIL import Image

from svgutils import create_cairo_font_face_for_file, place_image, draw_box, draw_circle
from dimensions import point_A, point_B, point_C, point_D, ptpin
from apiutils import append_print_file

def get_qrcode_image(content):
    """ Render a QR code to an ImageSurface.
    """
    # http://chart.apis.google.com/chart?chs=264x264&cht=qr&chld=Q|0&chl=http://walkingpapers.org/print.php?id=abcdefgh
    
    q = {'chs': '528x528', 'cht': 'qr', 'chld': 'Q|0', 'chl': content}
    u = 'http://chart.apis.google.com/chart?' + urlencode(q)
    
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
    mmap.draw(verbose=True, fatbits_ok=True).save(filename)
    
    img = ImageSurface.create_from_png(filename)
    
    unlink(filename)

    return img

def paper_info(paper_size, orientation):
    """
    """
    dim = __import__('dimensions')
    
    paper_size = {'letter': 'ltr', 'a4': 'a4', 'a3': 'a3'}[paper_size.lower()]
    width, height = getattr(dim, 'paper_size_%(orientation)s_%(paper_size)s' % locals())
    point_E = getattr(dim, 'point_E_%(orientation)s_%(paper_size)s' % locals())
    ratio = getattr(dim, 'ratio_%(orientation)s_%(paper_size)s' % locals())
    
    return width, height, point_E, ratio

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

def render_page(surface, mmap, well_bounds_pt, point_E, hm2pt_ratio):
    """
    """
    well_xmin_pt, well_ymin_pt, well_xmax_pt, well_ymax_pt = well_bounds_pt
    well_width_pt, well_height_pt = well_xmax_pt - well_xmin_pt, well_ymax_pt - well_ymin_pt
    
    ctx = Context(surface)
    
    #
    # Draw top-left icon
    #
    icon = pathjoin(dirname(__file__), '../site/lib/print/icon.png')
    img = ImageSurface.create_from_png(icon)
    place_image(ctx, img, 35.99, 42.87, 19.2, 25.6)
    
    try:
        font = create_cairo_font_face_for_file('/tmp/Helvetica-Bold.ttf')
    except OSError:
        # no text for us.
        pass
    else:
        # draw some text?
        pass
    
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
    
    reg_points = [point_A, point_B, point_C, point_D, point_E]
    
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
    
    img = get_qrcode_image('http://walkingpapers.org/print.php?id=abcdefgh')
    place_image(ctx, img, -83, -83, 83, 83)
    
    ctx.restore()
    
    #
    # Draw registration points
    #
    for (x, y) in device_points:
        x, y = ctx.device_to_user(x, y)
    
        draw_circle(ctx, x, y, .12 * ptpin)
        ctx.set_source_rgb(1, 1, 1)
        ctx.fill()

        draw_circle(ctx, x, y, .12 * ptpin)
        ctx.set_source_rgb(0, 0, 0)
        ctx.set_line_width(.25)
        ctx.set_dash([1.5, 3])
        ctx.stroke()

        draw_circle(ctx, x, y, .06 * ptpin)
        ctx.set_source_rgb(0, 0, 0)
        ctx.fill()
    
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
    #yield 60
    
    print 'Print:', print_id
    print 'Paper:', paper_size

    if orientation and bounds and zoom and provider and layout:
    
        print 'Orientation:', orientation
        print 'Bounds:', bounds
        print 'Zoom:', zoom
        print 'Layout:', layout
        print 'Provider:', provider
        print 'Size:', get_preview_map_size(orientation, paper_size)
        
        print_data = {'pages': []}
        print_pages = print_data['pages']
        
        north, west, south, east = bounds
        width, height = get_preview_map_size(orientation, paper_size)
        
        northwest = Location(north, west)
        southeast = Location(south, east)
        
        mmap = map_by_extent_zoom_size(TemplatedMercatorProvider(provider),
                                       northwest, southeast, zoom,
                                       width, height)
        
        # out = StringIO()
        # mmap.draw().save(out, format='JPEG')
        # preview_url = append_print_file(print_id, 'preview.jpg', out.getvalue(), apibase, password)
        # 
        # print 'Sent preview.jpg'
        # 
        # yield 60
        
        zdiff = min(18, zoom + 2) - zoom
        print 'Zoom diff:', zdiff
        
        mmap = map_by_extent_zoom_size(TemplatedMercatorProvider(provider),
                                       northwest, southeast, zoom + zdiff,
                                       width * 2**zdiff, height * 2**zdiff)
        
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
        
        # rows, cols = map(int, layout.split(','))
        ########################################################################
        
        print print_data
    
    filename = 'out.pdf'
    
    paper_width_pt, paper_height_pt, point_E, hm2pt_ratio = paper_info(paper_size, orientation)
    
    well_xmin_pt = .5 * ptpin
    well_ymin_pt = 1 * ptpin
    well_xmax_pt = paper_width_pt - .5 * ptpin
    well_ymax_pt = paper_height_pt - .5 * ptpin
    
    well_bounds_pt = well_xmin_pt, well_ymin_pt, well_xmax_pt, well_ymax_pt
    
    surf = PDFSurface(filename, paper_width_pt, paper_height_pt)
    
    render_page(surf, mmap, well_bounds_pt, point_E, hm2pt_ratio)
    
    surf.finish()
    
    append_print_file(print_id, 'composed.pdf', open('out.pdf', 'r').read(), apibase, password)
    
    print 'out.pdf'

if __name__ == '__main__':

    opts, args = parser.parse_args()
    
    main(None, None, None, opts.paper_size, opts.orientation, opts.layout, opts.provider, opts.bounds, opts.zoom)

