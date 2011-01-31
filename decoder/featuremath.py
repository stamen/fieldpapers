from math import sqrt, atan2, sin, cos
from numpy import array, repeat, reshape, nonzero, transpose, arctan2, sqrt as nsqrt

def blobs2features(blobs, min_hypot=1000, min_theta=0.636, max_theta=0.646, min_ratio=0.796, max_ratio=0.806):
    """ Generate a stream of features cnoforming to the given limits.
    
        A feature is defined as a trio of blobs forming two line segments, with
        a given length ratio and angle from the shorter to the longer segment.
    """
    count = len(blobs)
    
    # one-dimensional arrays of simple positions
    xs = array([(blob[0] + blob[2]) / 2 for blob in blobs], dtype=float)
    ys = array([(blob[1] + blob[3]) / 2 for blob in blobs], dtype=float)
    
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
        theta = atan2(dys[i,j], dxs[i,j])
        
        #
        # rotate each blob[k] around blob[i] by -theta, to get a hypotenuse-relative theta for (i, k)
        #
        ik_xs = dxs[i,:] * cos(-theta) - dys[i,:] * sin(-theta)
        ik_ys = dxs[i,:] * sin(-theta) + dys[i,:] * cos(-theta)
        
        ik_thetas = arctan2(ik_ys, ik_xs)

        ik_thetas[ik_thetas < min_theta] = 0
        ik_thetas[ik_thetas > max_theta] = 0
        
        #
        # cheak each blob[k] for correct distance ratio
        #
        for k in nonzero(ik_thetas)[0]:
            ratio = distances[i,k] / distances[i,j]
            
            if ratio < min_ratio or max_ratio < ratio:
                # outside the bounds.
                continue
            
            yield (i, j, k)

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
    blobs = [(1, 1), (2, 5), (3, 2)]
    count = len(blobs)
    
    x = lambda a: a[0]
    y = lambda a: a[1]
    a, b, c = blobs[0], blobs[1], blobs[2]
    
    dab = sqrt((x(b) - x(a)) ** 2 + (y(b) - y(a)) ** 2)
    dbc = sqrt((x(c) - x(b)) ** 2 + (y(c) - y(b)) ** 2)
    dac = sqrt((x(c) - x(a)) ** 2 + (y(c) - y(a)) ** 2)
    
    ratios = {(0, 1, 2): dab/dac, (1, 0, 2): dab/dbc, (2, 1, 0): dbc/dac}
    
    tab = atan2(y(b) - y(a), x(b) - x(a))
    tba = atan2(y(a) - y(b), x(a) - x(b))
    tac = atan2(y(c) - y(a), x(c) - x(a))
    tca = atan2(y(a) - y(c), x(a) - x(c))
    tbc = atan2(y(c) - y(b), x(c) - x(b))
    tcb = atan2(y(b) - y(c), x(b) - x(c))
    
    thetas = {
        (0, 1, 2): atan2((x(c) - x(a)) * sin(-tab) + (y(c) - y(a)) * cos(-tab),
                         (x(c) - x(a)) * cos(-tab) - (y(c) - y(a)) * sin(-tab)),
        
        (1, 0, 2): atan2((x(c) - x(b)) * sin(-tba) + (y(c) - y(b)) * cos(-tba),
                         (x(c) - x(b)) * cos(-tba) - (y(c) - y(b)) * sin(-tba)),
        
        (0, 2, 1): atan2((x(b) - x(a)) * sin(-tac) + (y(b) - y(a)) * cos(-tac),
                         (x(b) - x(a)) * cos(-tac) - (y(b) - y(a)) * sin(-tac)),
        
        (2, 0, 1): atan2((x(b) - x(c)) * sin(-tca) + (y(b) - y(c)) * cos(-tca),
                         (x(b) - x(c)) * cos(-tca) - (y(b) - y(c)) * sin(-tca)),
        
        (1, 2, 0): atan2((x(a) - x(b)) * sin(-tbc) + (y(a) - y(b)) * cos(-tbc),
                         (x(a) - x(b)) * cos(-tbc) - (y(a) - y(b)) * sin(-tbc)),
        
        (2, 1, 0): atan2((x(a) - x(c)) * sin(-tcb) + (y(a) - y(c)) * cos(-tcb),
                         (x(a) - x(c)) * cos(-tcb) - (y(a) - y(c)) * sin(-tcb))
      }
    
    
    for (i, j, k, ratio, theta) in blobs2features(blobs):
        assert round(ratios[(i, j, k)], 9) == round(ratio, 9), '%.9f vs. %.9f in (%d,%d,%d)' % (ratio, ratios[(i, j, k)], i, j, k)
        assert round(thetas[(i, j, k)], 9) == round(theta, 9), '%.9f vs. %.9f in (%d,%d,%d)' % (theta, thetas[(i, j, k)], i, j, k)
