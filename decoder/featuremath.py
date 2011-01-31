from math import sqrt, atan2, sin, cos
from numpy import array, repeat, reshape, nonzero, transpose, sqrt as nsqrt
from numpy import isnan, isinf, arctan2, sin as nsin, cos as ncos

def blobs2features(blobs):
    """
    """
    ratios, dxs, dys = _blobs2featureratios(blobs)

    #
    # Throw away a bunch we won't need
    #
    ratios[ratios <= 1.0] = 0
    ratios[isnan(ratios)] = 0
    ratios[isinf(ratios)] = 0
    
    for (i, j, k) in zip(*nonzero(ratios)):
        yield (i, j, k, ratios[i,j,k])

def _blobs2featureratios(blobs):
    """ Convert list of blobs into three-dimensional array of segment length ratios.
    
        For any given index (i, j, k), ratios[i,j,k] will be the ratio
        of the lines connecting blob pair (i, j) and blob pair (i, k).
        
        For good measure and later use, return two two-dimensional
        arrays of blob pair component (x and y) sizes.
    """
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
    
    for (i, j, k, ratio) in blobs2features(blobs):
        assert ratios[(i, j, k)] == ratio
