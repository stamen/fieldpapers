import sys
import math
import numpy
import os.path
import PIL.Image
import PIL.ImageDraw

class Feature:
    def __init__(self, x, y, scale, rotation, descriptors):
        self.x = x
        self.y = y
        self.s = scale
        self.r = rotation
        self.d = descriptors
        
    def __repr__(self):
        return 'F(%(x)d, %(y)d, %(s).3f, %(r).3f)' % self.__dict__

    def relativeScale(self, other):
        return self.s / other.s

    def relativeRotation(self, other):
        r = other.r - self.r
        
        while r > math.pi:
            r -= 2 * math.pi
        
        while r < -math.pi:
            r += 2 * math.pi

        return r

    def relativeDistance(self, other):
        d = math.hypot(self.x - other.x, self.y - other.y)
        
        return d / self.s

    def relativeBearing(self, other):
        r = math.atan2(other.y - self.y, other.x - self.x)
        
        r = r - self.r
        
        while r > math.pi:
            r -= 2 * math.pi
        
        while r < -math.pi:
            r += 2 * math.pi

        return r

def main(hImage, hData, nImage, nData):
    """ Given a haystack image and descriptor file, and a need image and
        descriptor file, return a new image that shows the two together
        with instances of the needle marked on the haystack.
    """
    # do the work part
    
    hFeatures = [row2feature(row) for row in hData]
    nFeatures = [row2feature(row) for row in nData]
    
    matches = find_matches(hFeatures, nFeatures)
    matches_graph = group_matches(matches, hFeatures, nFeatures)
    needles = find_needles(matches, matches_graph, hFeatures, nFeatures)
    
    # now do some drawing

    out = PIL.Image.new('RGB', (hImage.size[0] + nImage.size[0], max(hImage.size[1], nImage.size[1])), 0x00)
    out.paste(hImage, (0, 0))
    out.paste(nImage, (hImage.size[0], 0))
    canvas = PIL.ImageDraw.ImageDraw(out)
    
    color = 0xFF, 0x99, 0x00
    canvas.line((hImage.size[0], 0, hImage.size[0] + nImage.size[0], nImage.size[1]), fill=color)
    canvas.line((hImage.size[0] + nImage.size[0], 0, hImage.size[0], nImage.size[1]), fill=color)

    for (hKey, nKey) in matches.items():
        n1 = nFeatures[nKey]
        h1 = hFeatures[hKey]

        color = 0x00, 0x66, 0xFF
        draw_feature(canvas, h1, color)
        draw_feature(canvas, n1, color, hImage.size[0])
    
    for ((n1, n2), (h1, h2), transform) in needles:
        color = 0xFF, 0x00, 0xFF
        draw_feature(canvas, h2, color)
        draw_feature(canvas, n2, color, hImage.size[0])
        
        canvas.line((h1.x, h1.y, h2.x, h2.y), fill=color)
        
        color = 0xFF, 0xFF, 0x00
        draw_feature(canvas, h1, color)
        draw_feature(canvas, n1, color, hImage.size[0])
        
        points = (0, 0), (0, nImage.size[1]), (nImage.size[0], nImage.size[1]), (nImage.size[0], 0), (0, 0)
        points = [transform(x, y) for (x, y) in points]
        
        color = 0xFF, 0x99, 0x00
        canvas.line((points[0], points[1]), fill=color)
        canvas.line((points[1], points[2]), fill=color)
        canvas.line((points[2], points[3]), fill=color)
        canvas.line((points[3], points[0]), fill=color)
        canvas.line((points[0], points[2]), fill=color)
        canvas.line((points[1], points[3]), fill=color)

    return out

def feature2row(feature):
    """ Given a feature with x, y, scale, rotation list of descriptors,
        return a row as a string as if it had come from bin/sift.
    """
    location = ['%.6f' % f for f in (feature.x, feature.y, feature.s, feature.r)]
    description = ['%d' % i for i in feature.d[:]]
    
    return ' '.join(location + description)

def row2feature(row):
    """ Given a row as string, split and convert into a feature:
        x, y, scale, rotation, list of descriptors.
    """
    feature = row.split()

    x, y = int(float(feature[0])), int(float(feature[1]))
    s, r = float(feature[2]), float(feature[3])
    desc = [int(float(d)) for d in feature[4:]]
    
    return Feature(x, y, s, r, numpy.array(desc))

def find_matches(hFeatures, nFeatures):
    """ Given two lists of features (lists of x, y, scale, rotation, and descriptors)
        return a dictionary of matches where keys are haystack indexes and values
        are needle indexes, so that multiple needles can be found.
    """
    matches = {}
    
    # create an array of all needle descriptors
    nArray = numpy.zeros((len(nFeatures), len(nFeatures[0].d)))

    for (i, nFeature) in enumerate(nFeatures):
        nArray[i,:] = nFeature.d

    # iterate over all haystack descriptors, finding the closest needle match
    for (hKey, hFeature) in enumerate(hFeatures):
        assert len(hFeature.d) == nArray.shape[1]

        #print >> sys.stderr, hKey,
        
        # stretch the haystack array vertically so its size matches the needle array
        hArray = numpy.resize(numpy.array(hFeature.d), nArray.shape)
    
        # compute squared distances for all needle/haystack descriptor pairs
        dist = nArray - hArray
        diffqsums = numpy.sum(dist * dist, 1)
        
        # extract the two closest squared distances
        first, next, nKey = 10000000, 10000000, None
        
        for (i, diffqsum) in enumerate(diffqsums.tolist()):
            if diffqsum < first:
                first, next, nKey = diffqsum, first, i
            elif diffqsum < next:
                next = diffqsum

        # check whether closest distance is less than 0.6 of second.
        if 10 * 10 * first > 6 * 6 * next:
            # it's not, so they're too ambiguous, so nevermind
            #print >> sys.stderr, '-'
            continue

        # yay found a match
        #print >> sys.stderr, nKey
        
        matches[hKey] = nKey

    return matches

def find_single_match(hFeatures, nFeatures):
    """ Given two lists of features (lists of x, y, scale, rotation, and descriptors)
        return a dictionary of matches where keys are haystack indexes and values
        are needle indexes, so that a single needle can be found.
        
        Generally, don't use unless you're sure that there's exactly one match in the haystack.
    """
    matches = {}
    
    # create an array of all haystack descriptors
    hArray = numpy.zeros((len(hFeatures), len(hFeatures[0].d)))

    for (i, hFeature) in enumerate(hFeatures):
        hArray[i,:] = hFeature.d

    # iterate over all haystack descriptors, finding the closest needle match
    for (nKey, nFeature) in enumerate(nFeatures):
        assert len(nFeature.d) == hArray.shape[1]

        #print >> sys.stderr, nKey,
        
        # stretch the haystack array vertically so its size matches the needle array
        nArray = numpy.resize(numpy.array(nFeature.d), hArray.shape)
    
        # compute squared distances for all needle/haystack descriptor pairs
        dist = nArray - hArray
        diffqsums = numpy.sum(dist * dist, 1)
        
        # extract the two closest squared distances
        first, next, hKey = 10000000, 10000000, None
        
        for (i, diffqsum) in enumerate(diffqsums.tolist()):
            if diffqsum < first:
                first, next, hKey = diffqsum, first, i
            elif diffqsum < next:
                next = diffqsum

        # check whether closest distance is less than 0.6 of second.
        if 10 * 10 * first > 6 * 6 * next:
            # it's not, so they're too ambiguous, so nevermind
            #print >> sys.stderr, '-'
            continue

        # yay found a match
        #print >> sys.stderr, hKey
        
        matches[hKey] = nKey

    return matches

def group_matches(matches, hFeatures, nFeatures):
    """ Given a collection of matches, create a graph of matches that are
        mutually-agreeable based on relative position, size, and rotation.
        The resulting array is a graph whose indexes correspond to
        matches.keys, and indicate edges in a graph.
    """
    matches_graph = numpy.zeros((len(matches), len(matches)))

    # haystack feature index -> grid index
    hIndexes = dict([(h, i) for (i, h) in enumerate(matches.keys())])
    
    for (i, j) in matches.items():
        for (k, l) in matches.items():
            if i != k and j != l:
                hThis, nThis = hFeatures[i], nFeatures[j]
                hThat, nThat = hFeatures[k], nFeatures[l]
                

                hRelativeBearing = hThis.relativeBearing(hThat)
                nRelativeBearing = nThis.relativeBearing(nThat)
                
                compareRelativeBearing = abs(hRelativeBearing - nRelativeBearing)
                
                # within 10deg okay
                if compareRelativeBearing < math.pi / 18:
                    pass
                else:
                    # no
                    continue


                hRelativeScale = hThis.relativeScale(hThat)
                nRelativeScale = nThis.relativeScale(nThat)
                
                compareRelativeScale = hRelativeScale / nRelativeScale
                
                # within 25% okay
                if 0.8 <= compareRelativeScale and compareRelativeScale <= 1.25:
                    pass
                else:
                    # no
                    continue


                hRelativeRotation = hThis.relativeRotation(hThat)
                nRelativeRotation = nThis.relativeRotation(nThat)
                
                compareRelativeRotation = abs(hRelativeRotation - nRelativeRotation)
                
                # within 10deg okay
                if compareRelativeRotation < math.pi / 18:
                    pass
                else:
                    # no
                    continue


                hRelativeDistance = hThis.relativeDistance(hThat)
                nRelativeDistance = nThis.relativeDistance(nThat)
                
                if nRelativeDistance == 0:
                    # no
                    continue

                compareRelativeDistance = hRelativeDistance / nRelativeDistance
                
                # within 25% okay
                if 0.8 <= compareRelativeDistance and compareRelativeDistance <= 1.25:
                    pass
                else:
                    # no
                    continue


                # this and that feature may be self-consistent
                matches_graph[hIndexes[i], hIndexes[k]] = 1
                
                # be optimistic, too
                matches_graph[hIndexes[k], hIndexes[i]] = 1

    return matches_graph

def find_needles(matches, matches_graph, hFeatures, nFeatures):
    """ Look through a big bag of matches and an associated connection graph
        of mutually-agreeable hypotheses, and find needles in the form of
        two pairs of features and a 2D transformation function.
    """
    # grid index -> haystack feature index
    hIndexes = dict([(i, h) for (i, h) in enumerate(matches.keys())])
    
    needles = []
    
    if matches_graph.shape == (0, 0):
        return needles
    
    # while any feature in the graphs seems to be connected to more than two others...
    while max(numpy.sum(matches_graph, 0)) > 2:

        # get the most-connected, largest haystack/needle matched pair
        c, s, i = sorted([(c, hFeatures[hIndexes[i]].s, i) for (i, c) in enumerate(numpy.sum(matches_graph, 0).tolist())], reverse=True)[0]
        
        # primary haystack/needle pair
        h1 = hFeatures[hIndexes[i]]
        n1 = nFeatures[matches[hIndexes[i]]]
        
        # get the most-connected, closest haystack/needle matched pair that's connected to the above
        c, d, j = sorted([(c, math.hypot(h1.x - hFeatures[hIndexes[j]].x, h1.y - hFeatures[hIndexes[j]].y), j)
                          for (j, c) in enumerate(matches_graph[i, :].tolist()) if c], reverse=True)[0]
        
        # secondary haystack/needle pair
        h2 = hFeatures[hIndexes[j]]
        n2 = nFeatures[matches[hIndexes[j]]]

        # delete all connections to the haystack points above
        for (j, on) in enumerate(matches_graph[i, :].tolist()):
            if on:
                matches_graph[j, :] = 0
                matches_graph[:, j] = 0
    
        # really delete all connections to the haystack points above
        matches_graph[i, :] = 0
        matches_graph[:, i] = 0
        
        # save for later
        needle = (n1, n2), (h1, h2), derive_transform(n1, n2, h1, h2)
        needles.append(needle)

    return needles

def derive_transform(a1, a2, b1, b2):
    """ Given two pairs of features, return a 2D transformation
        function that will convert the first pair to the second.
    """
    affine = numpy.identity(3)
    
    # translate A point to (0, 0)
    affine = numpy.dot(numpy.array([[1, 0, -a1.x], [0, 1, -a1.y], [0, 0, 1]]), affine)
    
    # scale to B size
    scale = math.hypot(b2.x - b1.x, b2.y - b1.y) / math.hypot(a2.x - a1.x, a2.y - a1.y)
    affine = numpy.dot(numpy.array([[scale, 0, 0], [0, scale, 0], [0, 0, 1]]), affine)
    
    # rotate to B orientation
    theta = math.atan2(a2.x - a1.x, a2.y - a1.y) - math.atan2(b2.x - b1.x, b2.y - b1.y)
    affine = numpy.dot(numpy.array([[math.cos(theta), -math.sin(theta), 0], [math.sin(theta), math.cos(theta), 0], [0, 0, 1]]), affine)
    
    # translate back to B point
    affine = numpy.dot(numpy.array([[1, 0, b1.x], [0, 1, b1.y], [0, 0, 1]]), affine)
    
    return make_transform(affine)

def make_transform(affine):
    """ Given an affine transformation matrix return the associated 2D transform function.
    """
    ax, bx, cx, ay, by, cy = affine[0,0], affine[0,1], affine[0,2], affine[1,0], affine[1,1], affine[1,2]
    return lambda x, y: (ax * x + bx * y + cx, ay * x + by * y + cy)

def draw_feature(canvas, feature, color, offset=0):
    """
    """
    x, y = feature.x + offset, feature.y
    canvas.ellipse((x - feature.s, y - feature.s, x + feature.s, y + feature.s), outline=color)
    canvas.line((x, y, x + feature.s * math.cos(feature.r) / 2, y + feature.s * math.sin(feature.r) / 2), fill=color)

if __name__ == '__main__':
    try:
        hImage, hData = PIL.Image.open(sys.argv[1]).convert('RGB'), open(sys.argv[2], 'r')
        nImage, nData = PIL.Image.open(sys.argv[3]).convert('RGB'), open(sys.argv[4], 'r')
    except:
        print >> sys.stderr, 'Usage: %s <haystack image> <haystack descriptors> <needle image> <needle descriptors>' % os.path.basename(__file__)
        sys.exit(1)
    else:
        out = main(hImage, hData, nImage, nData)
        out.save('out.png')
