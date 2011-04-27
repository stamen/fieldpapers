from math import e
from StringIO import StringIO
from urllib import urlopen
from subprocess import Popen
from tempfile import mkstemp
from urlparse import urlparse
from os.path import splitext
from os import write, close, unlink

try:
    import PIL
except ImportError:
    import Image
    from ImageDraw import ImageDraw
    from Image import ANTIALIAS, AFFINE, BICUBIC
    from ImageOps import autocontrast
    from ImageFilter import MinFilter, MaxFilter
else:
    from PIL import Image
    from PIL.ImageDraw import ImageDraw
    from PIL.Image import ANTIALIAS, AFFINE, BICUBIC
    from PIL.ImageOps import autocontrast
    from PIL.ImageFilter import MinFilter, MaxFilter

from numpy import array, fromstring, ubyte, convolve

from BlobDetector import detect
from matrixmath import Point, triangle2triangle
from featuremath import Transform

class Blob:
    """
    """
    def __init__(self, xmin, ymin, xmax, ymax, size):
        self.xmin = xmin
        self.ymin = ymin
        self.xmax = xmax
        self.ymax = ymax
        self.size = size
        
        self.x = (xmin + xmax) / 2
        self.y = (ymin + ymax) / 2
        self.w = xmax - xmin
        self.h = ymax - ymin
        
        self.bbox = (xmin, ymin, xmax, ymax)

def open(url):
    """
    """
    bytes = StringIO(urlopen(url).read())
    image = Image.open(bytes)
    
    try:
        image.load()
    except IOError:
        pass
    else:
        return image

    s, h, path, p, q, f = urlparse(url)
    head, tail = splitext(path)
    
    handle, input_filename = mkstemp(prefix='imagemath-', suffix=tail)
    write(handle, bytes.getvalue())
    close(handle)
    
    handle, output_filename = mkstemp(prefix='imagemath-', suffix='.jpg')
    close(handle)
    
    try:
        convert = Popen(('convert', input_filename, output_filename))
        convert.wait()
        
        if convert.returncode != 0:
            raise IOError("Couldn't read %(url)s even with convert" % locals())
        
        return Image.open(output_filename)
    
    finally:
        unlink(input_filename)
        unlink(output_filename)

def imgblobs(img, highpass_filename=None, preblobs_filename=None, postblobs_filename=None):
    """ Extract bboxes of blobs from an image.
    
        Assumes blobs somewhere in the neighborhood of 0.25" or so
        on a scan not much smaller than 8" on its smallest side.
        
        Each blob is a bbox: (xmin, ymin, xmax, ymax)
    """
    thumb = img.copy().convert('L')
    thumb.thumbnail((1500, 1500), ANTIALIAS)
    
    # needed to get back up to input image size later.
    scale = float(img.size[0]) / float(thumb.size[0])
    
    # largest likely blob size, from scan size, 0.25", and floor of 8" for print.
    maxdim = min(*img.size) * 0.25 / 8.0
    
    # smallest likely blob size, wild-ass-guessed.
    mindim = 8
    
    thumb = autocontrast(thumb)
    thumb = lowpass(thumb, 1)
    thumb = highpass(thumb, 16)
    
    if highpass_filename:
        thumb.save(highpass_filename)
    
    thumb = thumb.point(lambda p: (p < 116) and 0xFF or 0x00)
    thumb = thumb.filter(MinFilter(5)).filter(MaxFilter(5))
    
    if preblobs_filename:
        thumb.save(preblobs_filename)
    
    ident = img.copy().convert('L').convert('RGB')
    draw = ImageDraw(ident)
    
    blobs = []
    
    for (xmin, ymin, xmax, ymax, pixels) in detect(thumb):
    
        coverage = pixels / float((1 + xmax - xmin) * (1 + ymax - ymin))
        
        if coverage < 0.7:
            # too spidery
            continue
        
        xmin *= scale
        ymin *= scale
        xmax *= scale
        ymax *= scale
        
        blob = Blob(xmin, ymin, xmax, ymax, pixels)
        
        if blob.w < mindim or blob.h < mindim:
            # too small
            continue
        
        if blob.w > maxdim or blob.h > maxdim:
            # too large
            continue
        
        if max(blob.w, blob.h) / min(blob.w, blob.h) > 2:
            # too stretched
            continue
        
        draw.rectangle(blob.bbox, outline=(0xFF, 0, 0))
        draw.text(blob.bbox[2:4], str(len(blobs)), fill=(0x99, 0, 0))

        blobs.append(blob)
    
    if postblobs_filename:
        ident.save(postblobs_filename)
    
    return blobs

def gaussian(data, radius):
    """ Perform a gaussian blur on a data array representing an image.
    
        Manipulate the data array directly.
    """
    #
    # Build a convolution kernel based on
    # http://en.wikipedia.org/wiki/Gaussian_function#Two-dimensional_Gaussian_function
    #
    kernel = range(-radius, radius + 1)
    kernel = [(d ** 2) / (2 * (radius * .5) ** 2) for d in kernel]
    kernel = [e ** -d for d in kernel]
    kernel = array(kernel, dtype=float) / sum(kernel)
    
    #
    # Convolve in two dimensions.
    #
    for row in range(data.shape[0]):
        data[row,:] = convolve(data[row,:], kernel, 'same')
    
    for col in range(data.shape[1]):
        data[:,col] = convolve(data[:,col], kernel, 'same')

def lowpass(img, radius):
    """ Perform a low-pass with a given radius on the image, return a new image.
    """
    #
    # Convert image to array
    #
    blur = img2arr(img)
    gaussian(blur, radius)
    
    return arr2img(blur)

def highpass(img, radius):
    """ Perform a high-pass with a given radius on the image, return a new image.
    """
    #
    # Convert image to arrays
    #
    orig = img2arr(img)
    blur = orig.copy()
    gaussian(blur, radius)
    
    #
    # Combine blurred with original, see http://www.gimp.org/tutorials/Sketch_Effect/
    #
    high = .5 * orig + .5 * (0xff - blur)
    
    return arr2img(high)

def extract_image(scan2print, print_bbox, scan_img, dest_dim, step=50):
    """ Extract a portion of a scan image by print coordinates.
    
        scan2print - transformation from scan pixels to original print.
    """
    dest_img = Image.new('RGB', dest_dim)
    
    #
    # Compute transformation from print image bbox to destination image.
    #
    print2dest = triangle2triangle(Point(print_bbox[0], print_bbox[1]), Point(0, 0),
                                   Point(print_bbox[0], print_bbox[3]), Point(0, dest_dim[1]),
                                   Point(print_bbox[2], print_bbox[1]), Point(dest_dim[0], 0))

    #
    # Compute transformation from source image to destination image.
    #
    scan2dest = scan2print.multiply(print2dest)
    
    dest_w, dest_h = dest_dim
    
    for y in range(0, dest_h, step):
        for x in range(0, dest_w, step):
            # dimensions of current destination cell
            w = min(step, dest_w - x)
            h = min(step, dest_h - y)

            # transformation from scan pixels to destination cell
            m = scan2dest
            m = m.multiply(Transform(1, 0, -x, 0, 1, -y))
            m = m.inverse()
            a = m.affine(0, 0, w, h)
            
            p = scan_img.transform((w, h), AFFINE, a, BICUBIC)
            
            dest_img.paste(p, (x, y))

    return dest_img

def arr2img(ar):
    """ Convert Numeric array to PIL Image.
    """
    return Image.fromstring('L', (ar.shape[1], ar.shape[0]), ar.astype(ubyte).tostring())

def img2arr(im):
    """ Convert PIL Image to Numeric array.
    """
    return fromstring(im.tostring(), ubyte).reshape((im.size[1], im.size[0]))
