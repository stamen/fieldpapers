from math import sqrt as _sqrt, atan2 as _atan2, sin as _sin, cos as _cos, pi, hypot as _hypot
from numpy import array as _array, repeat, reshape, nonzero, transpose, arctan2, sqrt as nsqrt
from itertools import chain, product

from matrixmath import Point, Vector, Transform

class Feature:
    """ Unmatched feature, probably in print coordinates.
        
        A feature is derived from a trio of points/blobs forming two line segments:
        
          2.
          *
          |   3.
          |  *
        A | /
          |/ B
          *
          1.
    
        A is the longest side of the triangle.
        B is the second-longest side by convention.
        
        Ratio is B/A and must be <= 1.0.
        Theta is from B to A and can be positive or negative.

        Features are scale and rotation invariant, though this function
        considers the largest ones first to spend less time on image noise.
    """
    def __init__(self, pa, pb, pc):
        """
        """
        self.p1, self.p2, self.p3, self.ratio, self.theta = _normalize(pa, pb, pc)

class MatchedFeature:
    """ Matched feature, with print coordinates like Feature plus raw scan coordinates.
    """
    def __init__(self, feature, s1, s2, s3):
        """
        """
        self.p1 = feature.p1
        self.p2 = feature.p2
        self.p3 = feature.p3
        
        self.ratio, self.theta = feature.ratio, feature.theta
        
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
    
    def fits(self, other):
        """ Return false if this feature conflicts with another.
        
            Two features fit if their numbered points match pairwise, with
            the identity relationship between self.pn and other.pn being equal
            to that of self.sn and other.sn.
            
            Assume that vertices can be simply compared with "is" and "is not".
        """
        for (i, j) in product((1, 2, 3), (1, 2, 3)):
            self_p, other_p = getattr(self, 'p%d' % i), getattr(other, 'p%d' % j)
            self_s, other_s = getattr(self, 's%d' % i), getattr(other, 's%d' % j)
            
            if self_p is other_p and self_s is not other_s:
                return False

            elif self_p is not other_p and self_s is other_s:
                return False

        return True

def _normalize(p1, p2, p3):
    """ Return feature parts for a trio of points - ordered points, ratio, theta.
    """
    h12 = _hypot(p2.x - p1.x, p2.y - p1.y)
    h13 = _hypot(p3.x - p1.x, p3.y - p1.y)
    h23 = _hypot(p3.x - p2.x, p3.y - p2.y)
    
    hs = sorted([h12, h13, h23], reverse=True)
    
    #
    # Shuffle the points into correct order.
    #
    if hs[0] is h12:
        if hs[1] is h13:
            p1, p2, p3 = p1, p2, p3
        elif hs[1] is h23:
            p1, p2, p3 = p2, p1, p3
    elif hs[0] is h13:
        if hs[1] is h12:
            p1, p2, p3 = p1, p3, p2
        elif hs[1] is h23:
            p1, p2, p3 = p3, p1, p2
    elif hs[0] is h23:
        if hs[1] is h12:
            p1, p2, p3 = p2, p3, p1
        elif hs[1] is h13:
            p1, p2, p3 = p3, p2, p1
    
    va, vb = Vector(p1, p2), Vector(p1, p3)
    
    theta = _atan2(va.y, va.x)
    
    x = vb.x * _cos(-theta) - vb.y * _sin(-theta)
    y = vb.x * _sin(-theta) + vb.y * _cos(-theta)
    
    ratio = hs[1] / hs[0]
    theta = _atan2(y, x)
    
    return p1, p2, p3, ratio, theta

def blobs2features(blobs, min_hypot=0, min_theta=-pi, max_theta=pi, min_ratio=0, max_ratio=1):
    """ Generate a stream of features conforming to limits.
    
        Yields 5-element tuples: indexes for three blobs followed by feature ratio, theta.
    """
    count = len(blobs)
    
    # one-dimensional arrays of simple positions
    xs = _array([blob.x for blob in blobs], dtype=float)
    ys = _array([blob.y for blob in blobs], dtype=float)
    
    #
    # two-dimensional arrays of component distances between each blob
    #   dx = b.x - a.x, dy = b.y - a.y
    #
    xs_ = repeat(reshape(xs, (1, count)), count, 0)
    ys_ = repeat(reshape(ys, (1, count)), count, 0)
    dxs, dys = transpose(xs_) - xs_, transpose(ys_) - ys_
    
    #
    # two-dimensional array of distances between each blob
    #   distance = sqrt(dx^2 + dy^2)
    #
    distances = nsqrt(dxs ** 2 + dys ** 2)
    
    #
    # make a list of eligible hypotenuses, sorted largest-to-smallest
    #
    hypoteni = distances.copy()
    hypoteni[distances < min_hypot] = 0
    
    hypot_nonzero = nonzero(hypoteni)
    hypot_sorted = [(distances[i,j], i, j) for (i, j) in zip(*hypot_nonzero)]
    hypot_sorted.sort(reverse=True)
    
    #
    # check each hypotenuse for an eligible third point
    #
    for (row, (distance, i, j)) in enumerate(hypot_sorted):
        #
        # vector theta for hypotenuse (i, j)
        #
        ij_theta = _atan2(dys[i,j], dxs[i,j])
        
        #
        # rotate each blob[k] around blob[i] by -theta, to get a hypotenuse-relative theta for (i, k)
        #
        ik_xs = dxs[i,:] * _cos(-ij_theta) - dys[i,:] * _sin(-ij_theta)
        ik_ys = dxs[i,:] * _sin(-ij_theta) + dys[i,:] * _cos(-ij_theta)
        
        ik_thetas = arctan2(ik_ys, ik_xs)
        
        #
        # check each blob[k] for correct distance ratio
        #
        for (k, theta) in enumerate(ik_thetas):
            ratio = distances[i,k] / distances[i,j]
            
            if theta < min_theta or max_theta < theta:
                continue

            if ratio < min_ratio or max_ratio < ratio:
                continue
            
            if i == j or i == k or j == k:
                continue
            
            yield (i, j, k, ratio, theta)

def stream_pairs(source1, source2):
    """ Generate a merged stream from two possibly-infinite streams.
    
        Imagine an infinite plane, swept diagonally from (0, 0) in alternating directions.
        
        Each source stream is repeated up to three times, just to guarantee
        that most possible pairs are produced at the cost of limited duplication.
    """
    list1, list2 = [], []
    iterator1 = chain(source1, source1, source1)
    iterator2 = chain(source2, source2, source2)
    northeast, southwest = 1, 2
    direction = northeast
    row, col = 0, 0
    
    while True:
        while len(list1) <= row:
            list1.append(iterator1.next())

        while len(list2) <= col:
            list2.append(iterator2.next())
        
        yield list1[row], list2[col]
    
        if direction == northeast:
            if row == 0:
                direction = southwest
            else:
                row -= 1
            col += 1
            
        elif direction == southwest:
            if col == 0:
                direction = northeast
            else:
                col -= 1
            row += 1

def stream_triples(src1, src2, src3):
    """ Generate a merged stream from three possibly-infinite streams.
    
        Items in the first stream will tend to be covered before the other two.
    """
    for (item1, (item2, item3)) in stream_pairs(src1, stream_pairs(src2, src3)):
        yield item1, item2, item3
            
if __name__ == '__main__':

    #
    # Set up some fake blobs.
    #
    blobs = [Point(1, 1), Point(2, 5), Point(3, 2)]
    count = len(blobs)
    
    a, b, c = blobs[0], blobs[1], blobs[2]
    
    dab = _sqrt((b.x - a.x) ** 2 + (b.y - a.y) ** 2)
    dbc = _sqrt((c.x - b.x) ** 2 + (c.y - b.y) ** 2)
    dac = _sqrt((c.x - a.x) ** 2 + (c.y - a.y) ** 2)
    
    ratios = {(0, 1, 2): dac/dab, (1, 0, 2): dbc/dab, (2, 1, 0): dac/dbc}
    
    tab = _atan2(b.y - a.y, b.x - a.x)
    tba = _atan2(a.y - b.y, a.x - b.x)
    tac = _atan2(c.y - a.y, c.x - a.x)
    tca = _atan2(a.y - c.y, a.x - c.x)
    tbc = _atan2(c.y - b.y, c.x - b.x)
    tcb = _atan2(b.y - c.y, b.x - c.x)
    
    thetas = {
        (0, 1, 2): _atan2((c.x - a.x) * _sin(-tab) + (c.y - a.y) * _cos(-tab),
                          (c.x - a.x) * _cos(-tab) - (c.y - a.y) * _sin(-tab)),
        
        (1, 0, 2): _atan2((c.x - b.x) * _sin(-tba) + (c.y - b.y) * _cos(-tba),
                          (c.x - b.x) * _cos(-tba) - (c.y - b.y) * _sin(-tba)),
        
        (0, 2, 1): _atan2((b.x - a.x) * _sin(-tac) + (b.y - a.y) * _cos(-tac),
                          (b.x - a.x) * _cos(-tac) - (b.y - a.y) * _sin(-tac)),
        
        (2, 0, 1): _atan2((b.x - c.x) * _sin(-tca) + (b.y - c.y) * _cos(-tca),
                          (b.x - c.x) * _cos(-tca) - (b.y - c.y) * _sin(-tca)),
        
        (1, 2, 0): _atan2((a.x - b.x) * _sin(-tbc) + (a.y - b.y) * _cos(-tbc),
                          (a.x - b.x) * _cos(-tbc) - (a.y - b.y) * _sin(-tbc)),
        
        (2, 1, 0): _atan2((a.x - c.x) * _sin(-tcb) + (a.y - c.y) * _cos(-tcb),
                          (a.x - c.x) * _cos(-tcb) - (a.y - c.y) * _sin(-tcb))
      }
    
    
    for (i, j, k, ratio, theta) in blobs2features(blobs, 0, -pi, pi, 0, 1):
        assert round(ratios[(i, j, k)], 9) == round(ratio, 9), '%.9f vs. %.9f in (%d,%d,%d)' % (ratio, ratios[(i, j, k)], i, j, k)
        assert round(thetas[(i, j, k)], 9) == round(theta, 9), '%.9f vs. %.9f in (%d,%d,%d)' % (theta, thetas[(i, j, k)], i, j, k)

    features = [Feature(Point(.575, .575), Point(.575, 10.425), Point(7.925, 10.425)),
                Feature(Point(.575, .575), Point(7.925, 10.425), Point(.575, 10.425)),
                Feature(Point(7.925, 10.425), Point(.575, .575), Point(.575, 10.425))]
    
    for feature in features:
        assert round(feature.ratio, 9) == 0.801462218, '%.9f vs. %.9f' % (feature.ratio, 0.80146221760756842)
        assert round(feature.theta, 9) == 0.641060105, '%.9f vs. %.9f' % (feature.theta, 0.64106010469117158)
