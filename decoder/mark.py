"""

mark.py

A first stab at automatic feature extraction from walking-papers maps.

Print in grayscale, mark with red, blue and green markers.

author Timothy Caro-Bruce

"""

import os
import sys
import os.path
import tempfile
import PIL
import numpy
import logging as log

import decode

THRESHOLD_PPM = 60  # number of pixels (per million in image) a mark should have to be considered non-trivial
MASK_THRESHOLD = 20  # minimum difference from other channels for a pixel to be in the mask

def get_markers():
    markers = {}
    for basename in ('Header', 'Hand', 'CCBYSA'):
        basepath = os.path.dirname(os.path.realpath(__file__)) + '/corners/' + basename
        markers[basename] = decode.Marker(basepath)
    return markers

def get_image_transform(url):
    """ 
    Uses decode methods to make a translation function from pixel coordinates to geographic locations.
    Also returns source image, so it doesn't need to be downloaded again.
    Mostly copied from decode.test, adapted for mark extraction.
    """
    markers = get_markers()
    image, features, scale = decode.siftImage(url)
    
    for (name, marker) in markers.items():
        log.debug(name + '...')
        marker.locateInFeatures(features)

        x, y = int(marker.anchor.x / scale), int(marker.anchor.y / scale)
        log.debug(str((x, y)))

        marker.anchor = decode.Point(x, y)

    handle, qrcode_filename = tempfile.mkstemp(dir='/tmp', prefix='qrcode-', suffix='.jpg')
    log.debug('QR code in' + qrcode_filename)
    os.close(handle)
    
    qrcode = decode.extractCode(image, markers)
    qrcode.save(qrcode_filename, 'JPEG')

    print_id, north, west, south, east = decode.readCode(qrcode)
    log.debug('code contents: Print %s %s' % (print_id, str((north, west, south, east))))
    
    transform = pixelTransform(image, north, west, south, east, markers)
    return image, transform    

def pixelTransform(image, top, left, bottom, right, markers):
    """  
    Transform a pixel coordinate to longitude, latitude.
    (excerpt from decode.tileZoomLevel)
    """        
    ax, bx, cx = decode.linearSolution(markers['Header'].anchor.x,    markers['Header'].anchor.y, left,
                                       markers['Hand'].anchor.x,      markers['Hand'].anchor.y,   right,
                                       markers['CCBYSA'].anchor.x,    markers['CCBYSA'].anchor.y, left)

    ay, by, cy = decode.linearSolution(markers['Header'].anchor.x,    markers['Header'].anchor.y, top,
                                       markers['Hand'].anchor.x,      markers['Hand'].anchor.y,   top,
                                       markers['CCBYSA'].anchor.x,    markers['CCBYSA'].anchor.y, bottom)
                                
    pixelGeo = lambda x, y: (ax * x + bx * y + cx, ay * x + by * y + cy)
    return pixelGeo

def transform_marks(transform, marks):
    """
    Use the given tranform to make pixel coordinates into geographic coordinates
    """
    return [GeoMark(*(transform(m.x, m.y)), properties=m.properties) for m in marks]

class SimpleMark(object):
    """
    Class representing a colored mark on the page.
    An instance stores just the average center of the pixels comprising the mark.
    """
    def __init__(self, properties={}):
        self.count = 0
        self.sum_x = 0
        self.sum_y = 0
        self.x = 0
        self.y = 0
        self.properties = {}
        self.properties.update(properties)

    def add_pixel(self, x, y):
        self.count += 1
        self.sum_x += x
        self.sum_y += y
        self.x = self.sum_x / self.count
        self.y = self.sum_y / self.count

class GeoMark(object):
    """
    Class representing a mark located geographicaly, with optional properties.
    """
    def __init__(self, lon, lat, properties={}):
        self.lon = lon
        self.lat = lat
        self.properties = properties

    @property
    def __geo_interface__(self):
        return {
            'geometry': {'type': 'Point', 'coordinates': (self.lon, self.lat)},
            'type': 'Feature',
            'properties': self.properties,
        }

def find_mark(ar, x, y):
    """
    Given a boolean array and starting position, use a breadth-first flood 
    to find all the pixels in a mark.
    Returns a SimpleMark, and removes consumed pixels from the boolean array.
    """
    mark = SimpleMark()
    height, width = ar.shape
    q = [(x, y)]
    while q:
        x, y = q.pop(0)
        if x < 0 or x >= width or y < 0 or y >= height:
            continue
        if ar[y, x]:
            mark.add_pixel(x, y)
            ar[y, x] = False
            q.extend([(x-1, y),(x, y-1),(x+1, y),(x, y+1),])
    return mark

def find_marks(mask):
    """
    Find all marks larger than a minimum size in the given mask image.
    """
    log.debug("finding marks")
    marks = []
    height, width = mask.shape
    min_pixels = THRESHOLD_PPM * (width * height) / 1000000
    for y in range(height):
        for x in range(width):
            if mask[y,x]:
                mark = find_mark(mask, x, y)
                if mark.count > min_pixels:
                    marks.append(mark)
    return marks

def find_all_marks(image, do_blur=True, do_draw_mask=False):
    if do_blur:
        log.debug("blurring image")
        blurred = image.filter(PIL.ImageFilter.BLUR)
        ar = numpy.array(blurred)
    else:
        ar = numpy.array(image)

    log.debug("converting to float")  
    ar = ar.astype('float')  # necessary to prevent overflow with uint8

    log.debug("separating channels")
    r, g, b = ar[:,:,0], ar[:,:,1], ar[:,:,2]
    
    log.debug("creating masks")
    masks = {
        'red':   ((r - g) > MASK_THRESHOLD) & ((r - b) > MASK_THRESHOLD),
        'green': ((g - r) > MASK_THRESHOLD) & ((g - b) > MASK_THRESHOLD),
        'blue':  ((b - r) > MASK_THRESHOLD) & ((b - g) > MASK_THRESHOLD),
    }
    
    if do_draw_mask:
        draw_mask(masks, 'mask.png')
    
    marks = []
    for color, mask in masks.items():
        color_marks = find_marks(mask)
        for mark in color_marks:
            mark.properties['color'] = color
        marks.extend(color_marks)
    return marks
    
#############################
### TEST VISUALIZATIONS

def draw_mask(masks, out=None):
    "Draw a representation of the color masks."
    log.debug("rendering mask")
    mask_image = numpy.zeros(masks['red'].shape + (3,), numpy.uint8)
    for color in masks:
        mask_image[masks[color]] = {'red':(255,0,0), 'green': (0,255,0), 'blue': (0,0,255)}[color]
    im = PIL.Image.fromarray(mask_image, "RGB")
    if out:
        im.save(out)
    else:
        im.show()

def draw_marks(image, marks):
    draw = PIL.ImageDraw.Draw(image)
    radius = max(min(image.size) / 200, 3)
    colors = {'red':(255,0,0), 'green': (0,255,0), 'blue': (0,0,255)}
    for mark in marks:
        draw.ellipse((m.x-radius, m.y-radius, m.x+radius, m.y+radius), 
                        outline='yellow', 
                        fill=colors[m.properties['color']])

##################################
### SERIALIZERS

class Serializer(object):
    def serialize(self, marks, outfile=None):
        s = self._serialize(marks)
        if outfile:
            f = open(outfile, 'w')
            f.write(s)
            f.close()
        else:
            print s
            
    def _serialize(marks):
        abstract

class GeoJSONSerializer(Serializer):
    def _serialize(self, marks):
        import geojson
        return geojson.dumps(geojson.FeatureCollection(marks))

class KMLSerializer(Serializer):
    def _serialize(self, marks):
        kml_tmpl = open('templates/mark-template.kml').read()   # FIXME -- should be absolute reference
        placemark_kml = """<Placemark>
          <Point>
            <coordinates>%f,%f,0</coordinates>
          </Point>
          <styleUrl>#msn_%s-circle</styleUrl>
        </Placemark>"""
        placemarks = []
        for geomark in marks:
            placemarks.append(placemark_kml % (geomark.lon, geomark.lat, geomark.properties['color']))
        kml = kml_tmpl % ''.join(placemarks)
        return kml
        
class GPXSerializer(Serializer):
    def _serialize(self, marks):
        waypoints = []
        for geomark in marks:
            wpt = """<wpt lon="%f" lat="%f">
                        <desc><![CDATA[%s]]></desc>
                     </wpt>""" % (geomark.lon, geomark.lat, geomark.properties['color'])
            waypoints.append(wpt)
    	
        doc = """<?xml version="1.0" encoding="UTF-8"?>
                    <gpx version="1.0">
                    	<name>Marks</name>
                    	%s
                    </gpx>""" % '\n'.join(waypoints)
        return doc

def process_url(url, outfile, format):
    serializer = {
        'json': GeoJSONSerializer,
        'kml': KMLSerializer,
        'gpx': GPXSerializer
    }[format]()

    image, transform = get_image_transform(url)
    
    all_marks = find_all_marks(image)
    geo_marks = transform_marks(transform, all_marks)
    serializer.serialize(geo_marks, outfile)

if __name__ == '__main__':
    url = sys.argv[1]
    outfile = sys.argv[2]
    if outfile == '-':
        outfile = None
        if len(sys.argv) > 3:
            format = sys.argv[3]
        else:
            format = 'json'
    else:
        format = outfile.split('.')[-1]
    process_url(url, outfile, format)