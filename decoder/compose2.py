from sys import argv
from urllib import urlopen, urlencode
from os import close, write, unlink
from optparse import OptionParser
from tempfile import mkstemp

from ModestMaps import Map, mapByExtentZoom
from ModestMaps.Providers import TemplatedMercatorProvider
from ModestMaps.Geo import Location
from ModestMaps.Core import Point

from cairo import ImageSurface, PDFSurface, Context
from PIL import Image

from dimensions import point_A, point_B, point_C, point_D, ptpin

def place_image(context, img, x, y, width, height):
    """ Add an image to a given context, at a position and size.
    
        Assume that the scale matrix of the context is already in pt.
    """
    context.save()
    context.translate(x, y)
    
    # determine the scale needed to make the image the requested size
    xscale = width / float(img.get_width())
    yscale = height / float(img.get_height())
    context.scale(xscale, yscale)

    # paint the image
    context.set_source_surface(img, 0, 0)
    context.paint()

    context.restore()

def get_qrcode_image(content):
    """
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
    """
    """
    handle, filename = mkstemp(suffix='.png')

    close(handle)
    mmap.draw(verbose=True, fatbits_ok=True).save(filename)
    
    img = ImageSurface.create_from_png(filename)
    
    unlink(filename)

    return img

def draw_box(context, x, y, w, h):
    """
    """
    context.move_to(x, y)
    context.rel_line_to(w, 0)
    context.rel_line_to(0, h)
    context.rel_line_to(-w, 0)
    context.rel_line_to(0, -h)

def draw_circle(context, x, y, radius):
    """
    """
    bezier = radius

    context.move_to(x, y - radius)
    context.rel_curve_to(bezier, 0, radius, bezier, radius, radius)
    context.rel_curve_to(0, bezier, -bezier, radius, -radius, radius)
    context.rel_curve_to(-bezier, 0, -radius, -bezier, -radius, -radius)
    context.rel_curve_to(0, -bezier, bezier, -radius, radius, -radius)

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
                    bounds=(37.81310856, -122.26442201, 37.79764683, -122.24897248),
                    paper='letter', orientation='portrait')

papers = 'a3 a4 letter'.split()
orientations = 'landscape portrait'.split()
layouts = '1,1 2,2 4,4'.split()

parser.add_option('-p', '--paper', dest='paper',
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

def main(apibase, password, print_id, paper_size, orientation=None, layout=None, provider=None, bounds=None, zoom=None, geotiff_url=None):
    """
    """
    #yield 60
    
    print 'Print:', print_id
    print 'Paper:', paper_size

    if orientation and bounds and zoom and provider and layout:
    
        print 'Orientation:', orientation
        print 'Bounds:', bounds
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
    
    print 'out.pdf'

if __name__ == '__main__':

    opts, args = parser.parse_args()
    
    main(opts.paper, opts.orientation, opts.layout, 'http://tile.openstreetmap.org/{Z}/{X}/{Y}.png', opts.bounds)
