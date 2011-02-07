from math import e

from PIL import Image
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
    def __init__(self, xmin, ymin, xmax, ymax):
        self.xmin = xmin
        self.ymin = ymin
        self.xmax = xmax
        self.ymax = ymax
        
        self.x = (xmin + xmax) / 2
        self.y = (ymin + ymax) / 2
        self.w = xmax - xmin
        self.h = ymax - ymin
        
        self.bbox = (xmin, ymin, xmax, ymax)

def imgblobs(img, highpass_filename=None, preblobs_filename=None):
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
    mindim = 10
    
    thumb = autocontrast(thumb)
    thumb = highpass(thumb, 16)
    
    if highpass_filename:
        thumb.save(highpass_filename)
    
    thumb = thumb.point(lambda p: (p < 120) and 0xFF or 0x00)
    thumb = thumb.filter(MinFilter(5)).filter(MaxFilter(5))
    
    if preblobs_filename:
        thumb.save(preblobs_filename)
    
    blobs = []
    
    for (xmin, ymin, xmax, ymax) in detect(thumb):
        xmin *= scale
        ymin *= scale
        xmax *= scale
        ymax *= scale
        
        blob = Blob(xmin, ymin, xmax, ymax)
        
        if blob.w < mindim or blob.h < mindim:
            # too small
            continue
        
        if blob.w > maxdim or blob.h > maxdim:
            # too large
            continue
        
        if max(blob.w, blob.h) / min(blob.w, blob.h) > 2:
            # too weird
            continue

        blobs.append(blob)
    
    return blobs

def highpass(img, radius):
    """ Perform a high-pass with a given radius on the image, return a new image.
    """
    #
    # Convert image to arrays
    #
    orig = img2arr(img)
    blur = orig.copy()
    
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
    for row in range(blur.shape[0]):
        blur[row,:] = convolve(blur[row,:], kernel, 'same')
    
    for col in range(blur.shape[1]):
        blur[:,col] = convolve(blur[:,col], kernel, 'same')
    
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
    # Compute transformation from original image bbox to destination image.
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
