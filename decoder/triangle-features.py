from math import sqrt
from numpy import array, repeat, reshape, nonzero, transpose, sqrt as nsqrt, isnan, isinf

blobs = [(1, 1), (2, 5), (3, 2)]
count = len(blobs)

print blobs

dab = sqrt((blobs[1][0] - blobs[0][0]) ** 2 + (blobs[1][1] - blobs[0][1]) ** 2)
dbc = sqrt((blobs[2][0] - blobs[1][0]) ** 2 + (blobs[2][1] - blobs[1][1]) ** 2)
dac = sqrt((blobs[2][0] - blobs[0][0]) ** 2 + (blobs[2][1] - blobs[0][1]) ** 2)

print 'a-b:', dab
print 'b-c:', dbc
print 'a-c:', dac

print 'ab-bc (0, 1, 2):', (dab / dbc)
print 'ba-ac (1, 0, 2):', (dab / dac)
print 'bc-ca (1, 2, 0):', (dbc / dac)

# one-dimensional arrays of simple positions
xs = array([blob[0] for blob in blobs], dtype=float)
ys = array([blob[1] for blob in blobs], dtype=float)

#
# two-dimensional array of distances between each blob
#   distance = sqrt((bx - ax)^2 + (by - ay)^2)
#
xs_ = repeat(reshape(xs, (1, count)), count, 0)
ys_ = repeat(reshape(ys, (1, count)), count, 0)
distances = nsqrt((transpose(xs_) - xs_) ** 2 + (transpose(ys_) - ys_) ** 2)

print distances

#
# three-dimensional array of distance ratios between blob pairs
#   ratio = ab / bc
#
ab_dist = repeat(reshape(distances, (count, count, 1)), count, 2)
bc_dist = repeat(reshape(distances, (1, count, count)), count, 0)
ratios = ab_dist / bc_dist

print ratios

ratios[ratios <= 1.0] = 0
ratios[isnan(ratios)] = 0
ratios[isinf(ratios)] = 0

for (i, j, k) in zip(*nonzero(ratios)):
    print (i, j, k), '-', ratios[i,j,k]

exit(0)

a = array(range(4))

print a

print repeat(reshape(a, (1, 4)), 4, 0)
print repeat(reshape(a, (4, 1)), 4, 1)

print '-' * 20

a = array(range(3))

print a
print reshape(a, (1, 1, 3))
print repeat(repeat(reshape(a, (1, 1, 3)), 3, 0), 3, 1)

print reshape(a, (1, 3, 1))
print repeat(repeat(reshape(a, (1, 3, 1)), 3, 0), 3, 2)

print reshape(a, (3, 1, 1))
print repeat(repeat(reshape(a, (3, 1, 1)), 3, 1), 3, 2)

b = repeat(repeat(reshape(a, (1, 1, 3)), 3, 0), 3, 1)
c = repeat(repeat(reshape(a, (1, 3, 1)), 3, 0), 3, 2)
d = repeat(repeat(reshape(a, (3, 1, 1)), 3, 1), 3, 2)

bcd = b * c * d

for (i, j, k) in zip(*nonzero(bcd)):
    print (i, j, k), '-', bcd[i,j,k]

print '-' * 20

a = array(range(9))

print repeat(reshape(a, (3, 3, 1)), 3, 2)
print repeat(reshape(a, (3, 1, 3)), 3, 1)
print repeat(reshape(a, (1, 3, 3)), 3, 0)

