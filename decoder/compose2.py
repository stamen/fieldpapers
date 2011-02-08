from sys import argv
from urllib import urlopen, urlencode
from os import close, write, unlink
from tempfile import mkstemp

from cairo import ImageSurface, PDFSurface, Context
from PIL import Image

mmppt = 0.352777778
inppt = 0.013888889

ptpin = 1./inppt
ptpmm = 1./mmppt

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

paper_info = {
    ('A3', 'landscape'): (420*ptpmm, 297*ptpmm, (-1104.997, -213.194)),
    ('A4', 'landscape'): (297*ptpmm, 210*ptpmm, (-1146.044, -300.08)),
    ('letter', 'landscape'): (11*ptpin, 8.5*ptpin, (-1034.824, -155.327)),

    ('A3', 'portrait'): (297*ptpmm, 420*ptpmm, (-508.37, -126.63)),
    ('A4', 'portrait'): (210*ptpmm, 297*ptpmm, (-509.722, -199.482)),
    ('letter', 'portrait'): (8.5*ptpin, 11*ptpin, (-565.823, -271.112))
  }

if __name__ == '__main__':

    paper_size, orientation = argv[1:3]
    
    assert paper_size in ('A3', 'A4', 'letter')
    assert orientation in ('landscape', 'portrait')
    
    filename = 'out.pdf'
    
    width_pt, height_pt, fifth_point = paper_info[(paper_size, orientation)]
    
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
    
    reg_points = [(-508.370, -720.334),
                  ( -13.557, -720.370),
                  ( -13.557, -229.533),
                  (-149.115,  -13.556),
                  fifth_point]
    
    device_points = [ctx.user_to_device(x, y) for (x, y) in reg_points]
    
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
