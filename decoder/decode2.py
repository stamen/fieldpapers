from sys import argv
from math import e

from PIL import Image
from PIL.Image import ANTIALIAS
from PIL.ImageOps import autocontrast
from PIL.ImageDraw import ImageDraw
from PIL.ImageFilter import MinFilter, MaxFilter
from numpy import array, fromstring, ubyte, convolve

from BlobDetector import detect
from featuremath import blobs2features, _unnamed

def imgblobs(img):
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
    thumb = thumb.point(lambda p: (p < 120) and 0xFF or 0x00)
    thumb = thumb.filter(MinFilter(5)).filter(MaxFilter(5))
    
    blobs = []
    
    for (xmin, ymin, xmax, ymax) in detect(thumb):
        xmin *= scale
        ymin *= scale
        xmax *= scale
        ymax *= scale
    
        w, h = xmax - xmin, ymax - ymin
        
        if w < mindim or h < mindim:
            # too small
            continue
        
        if w > maxdim or h > maxdim:
            # too large
            continue
        
        if max(w, h) / min(w, h) > 2:
            # too weird
            continue

        blobs.append((xmin, ymin, xmax, ymax))
    
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
    high = .5 * orig + .5 * (1 - blur)
    
    return arr2img(high)

def arr2img(ar):
    """ Convert Numeric array to PIL Image.
    """
    return Image.fromstring('L', (ar.shape[1], ar.shape[0]), ar.astype(ubyte).tostring())

def img2arr(im):
    """ Convert PIL Image to Numeric array.
    """
    return fromstring(im.tostring(), ubyte).reshape((im.size[1], im.size[0]))

if __name__ == '__main__':
    
    print 'opening...'
    input = Image.open(argv[1])

    print 'reading blobs...'
    blobs = imgblobs(input)
    print len(blobs), 'blobs'
    
    print 'pulling something or other...'
    indexes = _unnamed(blobs)
    
    print 'drawing...'
    draw = ImageDraw(input)
    
    for (count, (i, j, k)) in enumerate(indexes):
        if count == 5:
            break
    
        ix, iy = (blobs[i][0] + blobs[i][2]) / 2, (blobs[i][1] + blobs[i][3]) / 2
        jx, jy = (blobs[j][0] + blobs[j][2]) / 2, (blobs[j][1] + blobs[j][3]) / 2
        kx, ky = (blobs[k][0] + blobs[k][2]) / 2, (blobs[k][1] + blobs[k][3]) / 2
        
        draw.line((ix, iy, jx, jy), fill=(0xFF, 0, 0xFF))
        draw.line((ix, iy, kx, ky), fill=(0, 0xCC, 0))
    
    for bbox in blobs:
        draw.rectangle(bbox, outline=(0xFF, 0, 0))

    print 'saving...'
    input.save('out.png')
