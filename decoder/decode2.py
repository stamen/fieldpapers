from sys import argv
from math import e

from PIL import Image
from PIL.Image import ANTIALIAS
from PIL.ImageOps import autocontrast
from PIL.ImageDraw import ImageDraw
from PIL.ImageFilter import MinFilter, MaxFilter
from numpy import array, fromstring, ubyte, convolve

from BlobDetector import detect
from featuremath import Feature, MatchedFeature, blobs2features, stream_pairs

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
    blobs = imgblobs(input)
    print len(blobs), 'blobs.'
    
    print 'preparing features...'
    f1 = Feature(Point(41.4, 750.6), Point(41.4, 41.4), Point(306.0, 41.4))
    f2 = Feature(Point(306.0, 41.4), Point(570.6, 41.4), Point(570.6, 750.6))
    
    features1 = blobs2features(blobs, 1000, f1.theta-.005, f1.theta+.005, f1.ratio-.005, f1.ratio+.005)
    features2 = blobs2features(blobs, 1000, f2.theta-.005, f2.theta+.005, f2.ratio-.005, f2.ratio+.005)
    
    for (feat1, feat2) in stream_pairs(features1, features2):
    
        print '?',

        if feat1[1] != feat2[1]:
            continue
        
        if feat1[0] == feat2[0] or feat1[0] == feat2[2] or feat1[2] == feat2[0] or feat1[2] == feat2[2]:
            continue
        
        print 'yes.'
        
        break
    
    #---------------------------------------------------------------------------
    
    feat1 = MatchedFeature(f1, *[blobs[i] for i in feat1[:3]])
    feat2 = MatchedFeature(f2, *[blobs[i] for i in feat2[:3]])
    
    seen, points = set(), []

    for feat in (feat1, feat2):
        for (p, s) in ((feat.p1, feat.s1), (feat.p2, feat.s2), (feat.p3, feat.s3)):
            if s in seen:
                continue
            
            points.append((p, s))
            seen.add(s)
    
    def make_transform(pairs):
        """ Fit a regression line to a set of point pairs.
        
            Return a function that converts first of each point pair to the second.
        
            http://en.wikipedia.org/wiki/Simple_linear_regression#Fitting_the_regression_line
        """
        #
        # Averages
        #
        avg_lx = sum([l.x for (l, r) in pairs]) / len(pairs)
        avg_ly = sum([l.y for (l, r) in pairs]) / len(pairs)
        avg_rx = sum([r.x for (l, r) in pairs]) / len(pairs)
        avg_ry = sum([r.y for (l, r) in pairs]) / len(pairs)
        
        #
        # Sums of numerators and denominators
        #
        num0 = sum([(l.x - avg_lx) * (r.x - avg_rx) for (l, r) in pairs])
        den0 = sum([(l.x - avg_lx) * (l.x - avg_lx) for (l, r) in pairs])
        
        num1 = sum([(l.y - avg_ly) * (r.x - avg_rx) for (l, r) in pairs])
        den1 = sum([(l.y - avg_ly) * (l.y - avg_ly) for (l, r) in pairs])
        
        num2 = sum([(l.x - avg_lx) * (r.y - avg_ry) for (l, r) in pairs])
        den2 = sum([(l.x - avg_lx) * (l.x - avg_lx) for (l, r) in pairs])
        
        num3 = sum([(l.y - avg_ly) * (r.y - avg_ry) for (l, r) in pairs])
        den3 = sum([(l.y - avg_ly) * (l.y - avg_ly) for (l, r) in pairs])
        
        #
        # Coefficients for a linear transformation
        #
        f = 2 # not sure why this is 2 and not 1
        
        m0 = f * num0 / den0
        b0 = avg_rx - (m0 * avg_lx)
    
        m1 = f * num1 / den1;
        b1 = avg_rx - (m1 * avg_ly)
    
        m2 = f * num2 / den2;
        b2 = avg_ry - (m2 * avg_lx)
    
        m3 = f * num3 / den3;
        b3 = avg_ry - (m3 * avg_ly)
        
        #
        # Terms of a simple matrix
        #
        a, b, c = m0/f, m1/f, b0/f + b1/f
        d, e, f = m2/f, m3/f, b2/f + b3/f
        
        return lambda pt: Point(a * pt.x + b * pt.y + c, d * pt.x + e * pt.y + f)
    
    print '-' * 20
    
    p2s = make_transform(points)
    
    for (p, s) in points:
        # mapping from print to scan pixels
        print (int(p.x), int(p.y)), (int(p2s(p).x), int(p2s(p).y)), (int(s.x), int(s.y))
    
    s2p = make_transform([(s, p) for (p, s) in points])
    
    print '-' * 20
    
    for (p, s) in points:
        # mapping from print to scan pixels
        print (int(s.x), int(s.y)), (int(s2p(s).x), int(s2p(s).y)), (int(p.x), int(p.y))
    
    exit(1)
    
    print 'drawing...'
    draw = ImageDraw(input)
    
    for (i, j, k, ratio, theta) in (feat1, feat2):

        ix, iy = blobs[i].x, blobs[i].y
        jx, jy = blobs[j].x, blobs[j].y
        kx, ky = blobs[k].x, blobs[k].y

        draw.line((ix, iy, jx, jy), fill=(0, 0xCC, 0))
        draw.line((ix, iy, kx, ky), fill=(0xCC, 0, 0xCC))
        draw.line((jx, jy, kx, ky), fill=(0x99, 0, 0x99))
    
    for blob in blobs:
        draw.rectangle(blob.bbox, outline=(0xFF, 0, 0))

    print 'saving...'
    input.save('out.png')
