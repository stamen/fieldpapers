from sys import argv
from urllib import urlopen, urlencode
from os import close, write, unlink
from optparse import OptionParser
from tempfile import mkstemp

from cairo import ImageSurface, PDFSurface, Context
from PIL import Image

from dimensions import point_A, point_B, point_C, point_D, ptpin

def place_image(context, img, x, y, width, height):
    """ Add an image to a given context, at a position and size given in millimeters.
    
        Assume that the scale matrix of the context is already in pt.
    """
    context.save()
    context.translate(x, y)
    
    # determine the scale needed to make the image the requested size
    xscale = width / img.get_width()
    yscale = height / img.get_height()
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
    width_pt, height_pt = getattr(dim, 'paper_size_%(orientation)s_%(paper_size)s' % locals())
    fifth_point = getattr(dim, 'point_E_%(orientation)s_%(paper_size)s' % locals())
    
    return width_pt, height_pt, fifth_point

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

def main(paper_size, orientation=None, layout=None, provider=None, bounds=None, zoom=None):
    """
    """
    pass

if __name__ == '__main__':

    opts, args = parser.parse_args()
    
    filename = 'out.pdf'
    
    width_pt, height_pt, fifth_point = paper_info(opts.paper, opts.orientation)
    
    well_width_pt = width_pt - 1 * ptpin
    well_height_pt = height_pt - 1.5 * ptpin
    
    surf = PDFSurface(filename, width_pt, height_pt)
    
    ctx = Context(surf)
    
    #
    # Offset drawing area to top-left of map area
    #
    ctx.save()
    ctx.translate(.5 * ptpin, 1 * ptpin)
    
    #
    # Build up map area in points
    #
    draw_box(ctx, 0, 0, well_width_pt, well_height_pt)
    ctx.set_source_rgb(.9, .9, .9)
    ctx.fill()
    
    #
    # Calculate positions of registration points
    #
    ctx.save()
    
    ctx.translate(well_width_pt, well_height_pt)
    ctx.scale(well_height_pt/733.883, well_height_pt/733.883)
    
    reg_points = [point_A, point_B, point_C, point_D, fifth_point]
    
    device_points = [ctx.user_to_device(pt.x, pt.y) for pt in reg_points]
    
    ctx.restore()
    
    #
    # Draw QR code area
    #
    ctx.save()
    
    ctx.translate(well_width_pt, well_height_pt)
    ctx.scale(ptpin, ptpin)
    
    draw_box(ctx, 0, 0, -1.25, -1.25)
    ctx.set_source_rgb(1, 1, 1)
    ctx.fill()
    
    img = get_qrcode_image('http://walkingpapers.org/print.php?id=abcdefgh')
    place_image(ctx, img, -1.15, -1.15, 1.15, 1.15)
    
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
        ctx.stroke()

        draw_circle(ctx, x, y, .06 * ptpin)
        ctx.set_source_rgb(0, 0, 0)
        ctx.fill()
    
    surf.finish()
    
    exit(0)
