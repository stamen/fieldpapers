from math import sqrt, atan2, sin, cos
from itertools import izip
from numpy import array, empty, repeat, reshape, nonzero, transpose
from numpy import isnan, isinf, arctan2, sin as nsin, cos as ncos
from numpy import sqrt as nsqrt, hypot as nhypot

def blobs2features(blobs):
    """
    """
    _unnamed(blobs)
    
    ratios, dxs, dys = _blobs2feature_ratios_components(blobs)
    thetas = _components2feature_thetas(dxs, dys)
    
    print '...did the first ugly part'

    #
    # Throw away a bunch we won't need
    #
    ratios[ratios <= 1.0] = 0
    ratios[isnan(ratios)] = 0
    ratios[isinf(ratios)] = 0

    # hardcoded
    ratios[ratios <= 1.23] = 0
    ratios[ratios >= 1.27] = 0
    
    print '...did the second ugly part'
    
    for (i, j, k) in zip(*nonzero(ratios)):
        ratio, theta = ratios[i,j,k], thetas[i,j,k]
        
        # also hardcoded
        if theta < 0.62 or 0.66 < theta:
            continue
            
        yield (i, j, k, ratio, theta)

def _unnamed(blobs, min_hypot=1000):
    """ 
    """
    count = len(blobs)
    
    # one-dimensional arrays of simple positions
    xs = array([blob[0] for blob in blobs], dtype=float)
    ys = array([blob[1] for blob in blobs], dtype=float)
    
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
    
    # just distances eligible as a hypotenuse
    hypoteni = distances.copy()
    hypoteni[distances < min_hypot] = 0
    
    hypot_nonzero = nonzero(hypoteni)
    hypot_indexes = empty((len(hypot_nonzero[0]), 2), dtype=int)
    hypot_ratios = empty((hypot_indexes.shape[0], count), dtype=float)
    
    print hypoteni.shape, 'distances'
    
    ds, ixs, iys = [empty((1, count), dtype=int) for i in range(3)]
    
    for (row, (i, j)) in enumerate(zip(*hypot_nonzero)):
        hypot_indexes[row,:] = i, j
        
        ds.fill(distances[i,j])
        ixs.fill(xs[i])
        iys.fill(ys[i])
        
        hypot_ratios[row,:] = nhypot(xs - ixs, ys - iys) / ds
    
    print hypot_indexes.shape, 'indexes'
    print hypot_ratios.shape, 'ratios'
    print len(hypot_nonzero[0]), 'non-zero of', (hypoteni.shape[0] * hypoteni.shape[1])
    
    hypot_ratios[hypot_ratios < 1.22] = 0
    hypot_ratios[hypot_ratios > 1.26] = 0
    
    print len(nonzero(hypot_ratios)[0]), '???'
    
    exit(1)
    
    #
    # three-dimensional array of distance ratios between blob pairs
    #   ratio = ab / bc
    #
    ab_dist = repeat(reshape(distances, (count, count, 1)), count, 2)
    ac_dist = repeat(reshape(distances, (count, 1, count)), count, 1)
    ratios = ab_dist / ac_dist
    
    return ratios, dxs, dys

def _blobs2feature_ratios_components(blobs, min_hypot=1000):
    """ Convert list of blobs into three-dimensional array of segment length ratios.
    
        For any given index (i, j, k), ratios[i,j,k] will be the ratio
        of the lines connecting blob pair (i, j) and blob pair (i, k).
        
        For good measure and later use, return two two-dimensional
        arrays of blob pair component (x and y) sizes.
    """
    count = len(blobs)
    
    # one-dimensional arrays of simple positions
    xs = array([blob[0] for blob in blobs], dtype=float)
    ys = array([blob[1] for blob in blobs], dtype=float)
    
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
    # three-dimensional array of distance ratios between blob pairs
    #   ratio = ab / bc
    #
    ab_dist = repeat(reshape(distances, (count, count, 1)), count, 2)
    ac_dist = repeat(reshape(distances, (count, 1, count)), count, 1)
    ratios = ab_dist / ac_dist
    
    return ratios, dxs, dys

def _components2feature_thetas(dxs, dys):
    """
    """
    count = dxs.shape[0]
    
    #
    # two-dimensional array of bearings for each blob pair
    #
    thetas = arctan2(dys, dxs)
    
    #
    # pull out sine and cosine for inverse of each blob pair theta
    #
    sins, coss = nsin(-thetas), ncos(-thetas)
    
    #
    # stretch into three dimensional array so we can compare
    #
    ab_thetas = repeat(reshape(thetas, (count, count, 1)), count, 2)
    ab_sins = repeat(reshape(sins, (count, count, 1)), count, 2)
    ab_coss = repeat(reshape(coss, (count, count, 1)), count, 2)
    
    #
    # now do components for complementary pairs.
    #
    ac_dxs = repeat(reshape(dxs, (count, 1, count)), count, 1)
    ac_dys = repeat(reshape(dys, (count, 1, count)), count, 1)
    
    #
    # rotate so that original blob pair theta is at zero
    #
    abc_dxs = ac_dxs * ab_coss - ac_dys * ab_sins
    abc_dys = ac_dxs * ab_sins + ac_dys * ab_coss
    
    thetas = arctan2(abc_dys, abc_dxs)
    
    return thetas

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
