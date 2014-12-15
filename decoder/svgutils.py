import ctypes
from re import compile, DOTALL

from cairo import ImageSurface, Context, FORMAT_A8

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

def draw_cross(context, x, y, radius, weight):
    """
    """
    context.move_to(x + weight, y)
    context.line_to(x + radius + weight, y + radius)
    context.line_to(x + radius, y + radius + weight)
    context.line_to(x, y + weight)
    context.line_to(x - radius, y + radius + weight)
    context.line_to(x - radius - weight, y + radius)
    context.line_to(x - weight, y)
    context.line_to(x - radius - weight, y - radius)
    context.line_to(x - radius, y - radius - weight)
    context.line_to(x, y - weight)
    context.line_to(x + radius, y - radius - weight)
    context.line_to(x + radius + weight, y - radius)

def flow_text(context, width, line_height, text):
    """ Flow a block of text into the given width, returning when needed.
    """
    still = compile(r'^\S')
    words = compile(r'^(\S+(\s*))(.*)$', DOTALL)
    
    CR, LF = '\r', '\n'
    text = text.replace(CR+LF, LF).replace(CR, LF)
    
    while still.match(text):
        match = words.match(text)
        head, space, text = match.group(1), match.group(2), match.group(3)
        
        head_extent = context.text_extents(head)
        head_width, x_advance = head_extent[2], head_extent[4]
        
        x, y = context.get_current_point()

        # will we move too far to the right with this word?
        if x + head_width > width:
            context.move_to(0, y + line_height)
        
        context.show_text(head)
        context.rel_move_to(x_advance, 0)
        
        # apply newline if necessary
        while LF in space:
            y = context.get_current_point()[1]
            context.move_to(0, y + line_height)
            space = space[1 + space.index(LF):]

def create_cairo_font_face_for_file(filename, faceindex=0, loadoptions=0):
    """
    
        http://cairographics.org/freetypepython
    """

    CAIRO_STATUS_SUCCESS = 0
    FT_Err_Ok = 0

    # find shared objects
    _freetype_so = ctypes.CDLL('libfreetype.so.6')
    _cairo_so = ctypes.CDLL('libcairo.so.2')

    _cairo_so.cairo_ft_font_face_create_for_ft_face.restype = ctypes.c_void_p
    _cairo_so.cairo_ft_font_face_create_for_ft_face.argtypes = [ ctypes.c_void_p, ctypes.c_int ]
    _cairo_so.cairo_set_font_face.argtypes = [ ctypes.c_void_p, ctypes.c_void_p ]
    _cairo_so.cairo_font_face_status.argtypes = [ ctypes.c_void_p ]
    _cairo_so.cairo_status.argtypes = [ ctypes.c_void_p ]

    # initialize freetype
    _ft_lib = ctypes.c_void_p()
    if FT_Err_Ok != _freetype_so.FT_Init_FreeType(ctypes.byref(_ft_lib)):
      raise "Error initialising FreeType library."

    class PycairoContext(ctypes.Structure):
        _fields_ = [("PyObject_HEAD", ctypes.c_byte * object.__basicsize__),
                    ("ctx", ctypes.c_void_p),
                    ("base", ctypes.c_void_p)]

    _surface = ImageSurface(FORMAT_A8, 0, 0)

    # create freetype face
    ft_face = ctypes.c_void_p()
    cairo_ctx = Context(_surface)
    cairo_t = PycairoContext.from_address(id(cairo_ctx)).ctx
    _cairo_so.cairo_ft_font_face_create_for_ft_face.restype = ctypes.c_void_p

    if FT_Err_Ok != _freetype_so.FT_New_Face(_ft_lib, filename, faceindex, ctypes.byref(ft_face)):
        raise Exception("Error creating FreeType font face for " + filename)

    # create cairo font face for freetype face
    cr_face = _cairo_so.cairo_ft_font_face_create_for_ft_face(ft_face, loadoptions)

    if CAIRO_STATUS_SUCCESS != _cairo_so.cairo_font_face_status(cr_face):
        raise Exception("Error creating cairo font face for " + filename)

    _cairo_so.cairo_set_font_face(cairo_t, cr_face)

    if CAIRO_STATUS_SUCCESS != _cairo_so.cairo_status(cairo_t):
        raise Exception("Error creating cairo font face for " + filename)

    face = cairo_ctx.get_font_face()

    return face