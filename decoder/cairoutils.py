import json
from StringIO import StringIO
from os import close, write, unlink
from tempfile import mkstemp

from cairo import PDFSurface, Context
from PIL import Image

from matrixmath import Point as P, Transform

class Point (P):

    def add(self, other):
        return Point(self.x + other.x, self.y + other.y)

class Affine (Transform):

    def __init__(self, a=1, b=0, c=0, d=0, e=1, f=0):
        Transform.__init__(self, a, b, c, d, e, f)

    def __str__(self):
        return '[%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f]' % self.terms()

    def terms(self):
        return tuple(self.matrix[0:2,0:3].flat)
    
    def multiply(self, other):
        out = Transform.multiply(self, other)
        return Affine(*tuple(out.matrix[0:2,0:3].flat))

    def translate(self, x, y):
        return Affine(1, 0, x, 0, 1, y).multiply(self)

    def scale(self, x, y):
        return Affine(x, 0, 0, 0, y, 0).multiply(self)

class FakeContext:

    def __init__(self, context, height):
        self.commands = []
        self.context = context
        self.garbage = []

        self.point = Point(0, 0)
        self.stack = [(1, 0, 0, 0, -1, height)]
        self.affine = Affine(*self.stack[0])

        self.command('1 0 0 -1 0 %.3f cm' % height)
    
    def command(self, text, *args):
        if args:
            self.commands.append((text, args))
        else:
            self.commands.append(('raw', [text]))

    def finish(self):
        print json.dumps(self.commands)
        
        out = open('lossy/commands.json', 'w')
        json.dump(self.commands, out)
        out.close()
        
        for filename in self.garbage:
            continue
            print 'unlink', filename
            unlink(filename)
    
    def translate(self, x, y):
        self.affine = self.affine.translate(x, y)
        self.point = Point(self.point.x + x, self.point.y + y)
        self.command('1 0 0 1 %.3f %.3f cm' % (x, y))

    def scale(self, x, y):
        self.affine = self.affine.scale(x, y)
        self.point = Point(self.point.x * x, self.point.y * y)
        self.command('%.6f 0 0 %.6f 0 0 cm' % (x, y))

    def save(self):
        self.stack.append(self.affine.terms())
        self.command('q')

    def restore(self):
        self.affine = Affine(*self.stack.pop())
        self.command('Q')

    def user_to_device(self, x, y):
        user = Point(x, y)
        device = self.affine(user)
        return (device.x, device.y)

    def device_to_user(self, x, y):
        device = Point(x, y)
        user = self.affine.inverse()(device)
        return (user.x, user.y)

    def move_to(self, x, y):
        self.point = Point(x, y)
        self.command('%.3f %.3f m' % (x, y))

    def rel_line_to(self, x, y):
        end = Point(x, y).add(self.point)
        self.point = end
        self.command('%.3f %.3f l' % (end.x, end.y))

    def set_source_rgb(self, r, g, b):
        self.command('%.3f %.3f %.3f rg' % (r, g, b))

    def fill(self):
        self.command('f')

    def set_source_surface(self, surf, x, y):
        print 'fake context set_source_surface: %dx%d %.1fMB at (%d, %d)' \
            % (surf.get_width(), surf.get_height(), len(surf.get_data()) / 1048576., x, y)
        
        dim = surf.get_width(), surf.get_height()
        img = Image.fromstring('RGBA', dim, surf.get_data()).convert('RGB')

        png_buf = StringIO()
        img.save(png_buf, 'PNG')
        
        jpg_buf = StringIO()
        img.save(jpg_buf, 'JPEG', quality=75)
        
        if len(jpg_buf.getvalue()) < len(png_buf.getvalue()):
            method, buffer, suffix = 'raw_jpeg', jpg_buf, '.jpg'
        
        else:
            method, buffer, suffix = 'raw_png', png_buf, '.png'
        
        handle, filename = mkstemp(prefix='cairoutils-', suffix=suffix)
        self.command(method, filename)
        self.garbage.append(filename)

        write(handle, buffer.getvalue())
        close(handle)
        
        print '...or %.1fK PNG / %.1fK JPEG - %s' \
            % (len(png_buf.getvalue()) / 1024., len(jpg_buf.getvalue()) / 1024., filename)

    def paint(self):
        pass

    def set_line_width(self, w):
        self.command('%.3f w' % w)

    def set_dash(self, a):
        a = ' '.join(['%.3f' % v for v in a])
        self.command('[%s] 0 d' % a)

    def stroke(self):
        self.command('S')

    def rel_curve_to(self, a, b, c, d, e, f):
        p1 = Point(a, b).add(self.point)
        p2 = Point(c, d).add(self.point)
        p3 = Point(e, f).add(self.point)
        self.point = p3
        self.command('%.3f %.3f %.3f %.3f %.3f %.3f c' % (p1.x, p1.y, p2.x, p2.y, p3.x, p3.y))

    def set_font_face(self, font):
        print 'fake context set_font_face:', repr(font)
        return self.context.set_font_face(font)

    def set_font_size(self, size):
        print 'fake context set_font_size:', repr(size)
        return self.context.set_font_size(size)

    def show_text(self, text):
        print 'fake context show_text:', repr(text)

    def text_extents(self, text):
        return self.context.text_extents(text)

    def show_page(self):
        print 'fake context show_page.'

def get_drawing_context(print_filename, page_width_pt, page_height_pt):
    """
    """
    surface = PDFSurface(print_filename, page_width_pt, page_height_pt)
    context = FakeContext(Context(surface), page_height_pt)
    
    return context, context.finish
