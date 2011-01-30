from math import sqrt, atan2, sin, cos
from numpy import array, repeat, reshape, nonzero, transpose, sqrt as nsqrt
from numpy import isnan, isinf, arctan2, sin as nsin, cos as ncos

blobs = [(1, 1), (2, 5), (3, 2)]
count = len(blobs)

x = lambda a: a[0]
y = lambda a: a[1]
a, b, c = blobs[0], blobs[1], blobs[2]

print blobs

dab = sqrt((x(b) - x(a)) ** 2 + (y(b) - y(a)) ** 2)
dbc = sqrt((x(c) - x(b)) ** 2 + (y(c) - y(b)) ** 2)
dac = sqrt((x(c) - x(a)) ** 2 + (y(c) - y(a)) ** 2)

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



print '-' * 80

tab = atan2(y(b) - y(a), x(b) - x(a))
tba = atan2(y(a) - y(b), x(a) - x(b))
tac = atan2(y(c) - y(a), x(c) - x(a))
tca = atan2(y(a) - y(c), x(a) - x(c))
tbc = atan2(y(c) - y(b), x(c) - x(b))
tcb = atan2(y(b) - y(c), x(b) - x(c))

print 'a-b:', tab
print 'b-a:', tba
print 'a-c:', tac
print 'c-a:', tca
print 'b-c:', tbc
print 'c-b:', tcb

print 'c on a-b (0, 1, 2):', atan2((x(c) - x(a)) * sin(-tab) + (y(c) - y(a)) * cos(-tab),
                                   (x(c) - x(a)) * cos(-tab) - (y(c) - y(a)) * sin(-tab))

print 'c on b-a (1, 0, 2):', atan2((x(c) - x(b)) * sin(-tba) + (y(c) - y(b)) * cos(-tba),
                                   (x(c) - x(b)) * cos(-tba) - (y(c) - y(b)) * sin(-tba))

print 'b on a-c (0, 2, 1):', atan2((x(b) - x(a)) * sin(-tac) + (y(b) - y(a)) * cos(-tac),
                                   (x(b) - x(a)) * cos(-tac) - (y(b) - y(a)) * sin(-tac))

print 'b on c-a (2, 0, 1):', atan2((x(b) - x(c)) * sin(-tca) + (y(b) - y(c)) * cos(-tca),
                                   (x(b) - x(c)) * cos(-tca) - (y(b) - y(c)) * sin(-tca))

print 'a on b-c (1, 2, 0):', atan2((x(a) - x(b)) * sin(-tbc) + (y(a) - y(b)) * cos(-tbc),
                                   (x(a) - x(b)) * cos(-tbc) - (y(a) - y(b)) * sin(-tbc))

print 'a on c-b (2, 1, 0):', atan2((x(a) - x(c)) * sin(-tcb) + (y(a) - y(c)) * cos(-tcb),
                                   (x(a) - x(c)) * cos(-tcb) - (y(a) - y(c)) * sin(-tcb))

#
# two-dimensional array of bearings for each blob pair
#   theta = atan2(dy, dx)
#
thetas = arctan2(dys, dxs)
sins, coss = nsin(-thetas), ncos(-thetas)

print thetas
print sins
print coss

print '-' * 10

print dxs * coss - dys * sins
print dxs * sins + dys * coss

print '-' * 4

ab_thetas = repeat(reshape(thetas, (count, count, 1)), count, 2)
ab_sins = repeat(reshape(sins, (count, count, 1)), count, 2)
ab_coss = repeat(reshape(coss, (count, count, 1)), count, 2)

ac_dxs = repeat(reshape(dxs, (count, 1, count)), count, 1)
ac_dys = repeat(reshape(dys, (count, 1, count)), count, 1)

abc_dxs = ac_dxs * ab_coss - ac_dys * ab_sins
abc_dys = ac_dxs * ab_sins + ac_dys * ab_coss

print '-' * 4

out = arctan2(abc_dys, abc_dxs)

for (i, j, k) in zip(*nonzero(out)):
    if len(set([i, j, k])) == 3:
        print (i, j, k), '-', out[i,j,k]

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

