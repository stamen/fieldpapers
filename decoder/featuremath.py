from math import sqrt as _sqrt, atan2 as _atan2, sin as _sin, cos as _cos, pi, hypot as _hypot
from numpy import array as _array, repeat, reshape, nonzero, transpose, arctan2, sqrt as nsqrt

def feature(x1, y1, x2, y2, x3, y3):
    """ Return a feature for a trio of points.
    
        A feature is derived from a trio of points/blobs forming two line segments:
        
          b.
          *
          |   c.
          |  *
          | /
          |/
          *
          a.
        
        Ratio is AC/AB and must be <= 1.0.
        Theta is from AC to AB and can be positive or negative.

        AB is the longest side of the triangle.
        AC is the second-longest side by convention.
        
        Features are scale and rotation invariant, though this function
        considers the largest ones first to spend less time on image noise.
    """
    p1, p2, p3 = (x1, y1), (x2, y2), (x3, y3)
    
    h12 = _hypot(x2 - x1, y2 - y1)
    h13 = _hypot(x3 - x1, y3 - y1)
    h23 = _hypot(x3 - x2, y3 - y2)
    
    hs = sorted([h12, h13, h23], reverse=True)
    
    if hs[0] is h12:
        if hs[1] is h13:
            va, vb = (p2[0] - p1[0], p2[1] - p1[1]), (p3[0] - p1[0], p3[1] - p1[1])
        elif hs[1] is h23:
            va, vb = (p1[0] - p2[0], p1[1] - p2[1]), (p3[0] - p2[0], p3[1] - p2[1])
    elif hs[0] is h13:
        if hs[1] is h12:
            va, vb = (p3[0] - p1[0], p3[1] - p1[1]), (p2[0] - p1[0], p2[1] - p1[1])
        elif hs[1] is h23:
            va, vb = (p1[0] - p3[0], p1[1] - p3[1]), (p2[0] - p3[0], p2[1] - p3[1])
    elif hs[0] is h23:
        if hs[1] is h12:
            va, vb = (p3[0] - p2[0], p3[1] - p2[1]), (p1[0] - p2[0], p1[1] - p2[1])
        elif hs[1] is h13:
            va, vb = (p2[0] - p3[0], p2[1] - p3[1]), (p1[0] - p3[0], p1[1] - p3[1])
    
    theta = _atan2(va[1], va[0])
    
    x = vb[0] * _cos(-theta) - vb[1] * _sin(-theta)
    y = vb[0] * _sin(-theta) + vb[1] * _cos(-theta)
    
    ratio = hs[1] / hs[0]
    theta = _atan2(y, x)
    
    return ratio, theta

def blobs2features(blobs, min_hypot=0, min_theta=-pi, max_theta=pi, min_ratio=0, max_ratio=1):
    """ Generate a stream of features conforming to limits.
    
        Yields 5-element tuples: indexes for three blobs followed by feature ratio, theta.
    """
    count = len(blobs)
    
    # one-dimensional arrays of simple positions
    xs = _array([(blob[0] + blob[2]) / 2 for blob in blobs], dtype=float)
    ys = _array([(blob[1] + blob[3]) / 2 for blob in blobs], dtype=float)
    
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
    """
    list1, list2 = [], []
    iterator1, iterator2 = iter(source1), iter(source2)
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
    blobs = [(1, 1, 1, 1), (2, 5, 2, 5), (3, 2, 3, 2)]
    count = len(blobs)
    
    x = lambda a: a[0]
    y = lambda a: a[1]
    a, b, c = blobs[0], blobs[1], blobs[2]
    
    dab = _sqrt((x(b) - x(a)) ** 2 + (y(b) - y(a)) ** 2)
    dbc = _sqrt((x(c) - x(b)) ** 2 + (y(c) - y(b)) ** 2)
    dac = _sqrt((x(c) - x(a)) ** 2 + (y(c) - y(a)) ** 2)
    
    ratios = {(0, 1, 2): dac/dab, (1, 0, 2): dbc/dab, (2, 1, 0): dac/dbc}
    
    tab = _atan2(y(b) - y(a), x(b) - x(a))
    tba = _atan2(y(a) - y(b), x(a) - x(b))
    tac = _atan2(y(c) - y(a), x(c) - x(a))
    tca = _atan2(y(a) - y(c), x(a) - x(c))
    tbc = _atan2(y(c) - y(b), x(c) - x(b))
    tcb = _atan2(y(b) - y(c), x(b) - x(c))
    
    thetas = {
        (0, 1, 2): _atan2((x(c) - x(a)) * _sin(-tab) + (y(c) - y(a)) * _cos(-tab),
                          (x(c) - x(a)) * _cos(-tab) - (y(c) - y(a)) * _sin(-tab)),
        
        (1, 0, 2): _atan2((x(c) - x(b)) * _sin(-tba) + (y(c) - y(b)) * _cos(-tba),
                          (x(c) - x(b)) * _cos(-tba) - (y(c) - y(b)) * _sin(-tba)),
        
        (0, 2, 1): _atan2((x(b) - x(a)) * _sin(-tac) + (y(b) - y(a)) * _cos(-tac),
                          (x(b) - x(a)) * _cos(-tac) - (y(b) - y(a)) * _sin(-tac)),
        
        (2, 0, 1): _atan2((x(b) - x(c)) * _sin(-tca) + (y(b) - y(c)) * _cos(-tca),
                          (x(b) - x(c)) * _cos(-tca) - (y(b) - y(c)) * _sin(-tca)),
        
        (1, 2, 0): _atan2((x(a) - x(b)) * _sin(-tbc) + (y(a) - y(b)) * _cos(-tbc),
                          (x(a) - x(b)) * _cos(-tbc) - (y(a) - y(b)) * _sin(-tbc)),
        
        (2, 1, 0): _atan2((x(a) - x(c)) * _sin(-tcb) + (y(a) - y(c)) * _cos(-tcb),
                          (x(a) - x(c)) * _cos(-tcb) - (y(a) - y(c)) * _sin(-tcb))
      }
    
    
    for (i, j, k, ratio, theta) in blobs2features(blobs, 0, -pi, pi, 0, 1):
        assert round(ratios[(i, j, k)], 9) == round(ratio, 9), '%.9f vs. %.9f in (%d,%d,%d)' % (ratio, ratios[(i, j, k)], i, j, k)
        assert round(thetas[(i, j, k)], 9) == round(theta, 9), '%.9f vs. %.9f in (%d,%d,%d)' % (theta, thetas[(i, j, k)], i, j, k)

    features = [feature(.575, .575, .575, 10.425, 7.925, 10.425),
                feature(.575, .575, 7.925, 10.425, .575, 10.425),
                feature(7.925, 10.425, .575, .575, .575, 10.425)]
    
    for (ratio, theta) in features:
        assert round(ratio, 9) == 0.801462218, '%.9f vs. %.9f' % (ratio, 0.80146221760756842)
        assert round(theta, 9) == 0.641060105, '%.9f vs. %.9f' % (theta, 0.64106010469117158)
