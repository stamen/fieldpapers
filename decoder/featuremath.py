from math import sqrt, atan2, sin, cos
from numpy import array, repeat, reshape, nonzero, transpose, sqrt as nsqrt
from numpy import isnan, isinf, arctan2, sin as nsin, cos as ncos

def blobs2features(blobs):
    """
    """
    ratios, dxs, dys = _blobs2feature_ratios_components(blobs)
    thetas = _components2feature_thetas(dxs, dys)

    #
    # Throw away a bunch we won't need
    #
    ratios[ratios <= 1.0] = 0
    ratios[isnan(ratios)] = 0
    ratios[isinf(ratios)] = 0
    
    for (i, j, k) in zip(*nonzero(ratios)):
        yield (i, j, k, ratios[i,j,k], thetas[i,j,k])

def _blobs2feature_ratios_components(blobs):
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
