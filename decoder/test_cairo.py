import svgutils
from os.path import join as pathjoin, dirname, realpath
font_file = realpath('fonts/Helvetica.ttf')
print font_file
f = svgutils.create_cairo_font_face_for_file(font_file)
assert f