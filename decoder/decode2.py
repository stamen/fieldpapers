from sys import argv, stderr
from math import e

from PIL import Image
from PIL.Image import ANTIALIAS, AFFINE, BICUBIC
from PIL.ImageOps import autocontrast
from PIL.ImageDraw import ImageDraw
from PIL.ImageFilter import MinFilter, MaxFilter
from numpy import array, fromstring, ubyte, convolve

from BlobDetector import detect
from featuremath import Feature, MatchedFeature, blobs2features, stream_pairs
from featuremath import regress_transform, Transform

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
    high = .5 * orig + .5 * (1 - blur)
    
    return arr2img(high)

class Point:
    """
    """
    def __init__(self, x, y):
        self.x, self.y = x, y

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
    blobs = imgblobs(input, 'highpass.jpg', 'preblobs.jpg')
    print len(blobs), 'blobs.'
    
    print 'preparing features...'
    tl = Point(41.4, 41.4)
    tr = Point(570.6, 41.4)
    bl = Point(41.4, 750.6)
    br = Point(570.6, 750.6)

    f1 = Feature(tl, tr, bl) # bl, tr, tl
    f2 = Feature(tr, tl, br) # br, tl, tr
    
    matches1 = blobs2features(blobs, 1000, f1.theta-.016, f1.theta+.016, f1.ratio-.036, f1.ratio+.036)
    matches2 = blobs2features(blobs, 1000, f2.theta-.016, f2.theta+.016, f2.ratio-.036, f2.ratio+.036)
    
    found = False
    
    for (match1, match2) in stream_pairs(matches1, matches2):
    
        match1 = MatchedFeature(f1, *[blobs[i] for i in match1[:3]])
        match2 = MatchedFeature(f2, *[blobs[i] for i in match2[:3]])
        
        print >> stderr, '?',
        
        if match1.s1 is match2.s1:
            continue
        
        if match1.s2 is not match2.s3:
            continue
        
        if match1.s3 is not match2.s2:
            continue
        
        print >> stderr, 'yes.'
        
        found = True
        break
    
    assert found
    
    #---------------------------------------------------------------------------
    
    seen, points = set(), []

    for match in (match1, match2):
        for (p, s) in ((match.p1, match.s1), (match.p2, match.s2), (match.p3, match.s3)):
            if s in seen:
                continue
            
            points.append((p, s))
            seen.add(s)
    
    # matrices from print points to scan pixels and back
    p2s = regress_transform(points)
    s2p = regress_transform([(s, p) for (p, s) in points])
    
    # matrix for finding the largest QR code at (468pt, 368pt)
    m = s2p
    m = m.multiply(Transform(1, 0, -468, 0, 1, -360))
    m = m.multiply(Transform(4, 0, 0, 0, 4, 0))
    m = m.multiply(Transform(1, 0, 34, 0, 1, 34))
    m = m.inverse()
    a = m.affine(0, 0, 500, 500)
    
    input.transform((500, 500), AFFINE, a, BICUBIC).save('qrcode.png')
    
    print 'drawing...'
    draw = ImageDraw(input)
    
    for match in (match1, match2):

        s1 = match.s1
        s2 = match.s2
        s3 = match.s3
        
        draw.line((s1.x, s1.y, s2.x, s2.y), fill=(0, 0xCC, 0))
        draw.line((s1.x, s1.y, s3.x, s3.y), fill=(0xCC, 0, 0xCC))
        draw.line((s2.x, s2.y, s3.x, s3.y), fill=(0x99, 0, 0x99))
    
    for blob in blobs:
        draw.rectangle(blob.bbox, outline=(0xFF, 0, 0))

    print 'saving...'
    input.save('out.png')
