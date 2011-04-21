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

    def __init__(self, surface, height):
        self.surface = surface
        self.stack = [(1, 0, 0, 0, -1, height)]
        self.affine = Affine(*self.stack[0])
        self.point = Point(0, 0)
        print 'pdf: 1 0 0 -1 0 %.3f cm' % height
    
    def translate(self, x, y):
        self.affine = self.affine.translate(x, y)
        self.point = Point(self.point.x + x, self.point.y + y)
        print 'pdf: 1 0 0 1 %.3f %.3f cm' % (x, y)

    def scale(self, x, y):
        self.affine = self.affine.scale(x, y)
        self.point = Point(self.point.x * x, self.point.y * y)
        print 'pdf: %.6f 0 0 %.6f 0 0 cm' % (x, y)

    def save(self):
        self.stack.append(self.affine.terms())
        print 'pdf: q'

    def restore(self):
        self.affine = Affine(*self.stack.pop())
        print 'pdf: Q'

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
        print 'pdf: %.3f %.3f m' % (x, y)

    def rel_line_to(self, x, y):
        end = Point(x, y).add(self.point)
        self.point = end
        print 'pdf: %.3f %.3f l' % (end.x, end.y)

    def set_source_rgb(self, r, g, b):
        print 'pdf: %.3f %.3f %.3f rg' % (r, g, b)

    def fill(self):
        print 'pdf: f'

    def set_source_surface(self, img, x, y):
        print 'fake context set_source_surface:', (img, x, y)

    def paint(self):
        print 'fake context paint.'

    def set_line_width(self, w):
        print 'pdf: %.3f w' % w

    def set_dash(self, a):
        a = ' '.join(['%.3f' % v for v in a])
        print 'pdf: [%s] 0 d' % a

    def stroke(self):
        print 'pdf: S'

    def rel_curve_to(self, a, b, c, d, e, f):
        p1 = Point(a, b).add(self.point)
        p2 = Point(c, d).add(self.point)
        p3 = Point(e, f).add(self.point)
        self.point = p3
        print 'pdf: %.3f %.3f %.3f %.3f %.3f %.3f c' % (p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)

    def set_font_face(self, font):
        print 'fake context set_font_face:', repr(font)

    def set_font_size(self, size):
        print 'fake context set_font_size:', repr(size)

    def show_text(self, text):
        print 'fake context show_text:', repr(text)

    def text_extents(self, text):
        print 'fake context text_extents:', repr(text)

    def show_page(self):
        print 'fake context show_page.'
