from imagemath import Point
from featuremath import Feature

#
# points, clockwise from top-left
#
point_A = Point(-508.37, -720.33, 'A')
point_B = Point(-486.68, -720.33, 'B')
point_C = Point(-13.56, -720.37, 'C')
point_D = Point(-13.56, -229.53, 'D')
point_E = Point(-149.12, -13.56, 'E')

#
# sixth and seventh point, by paper size and orientation
#
point_F_portrait_a3 = Point(-508.37, -126.63, 'F portrait a3')
point_G_portrait_a3 = Point(-508.37, -148.33, 'G portrait a3')
point_F_portrait_a4 = Point(-509.72, -199.48, 'F portrait a4')
point_G_portrait_a4 = Point(-509.72, -221.17, 'G portrait a4')
point_F_portrait_ltr = Point(-565.82, -271.11, 'F portrait ltr')
point_G_portrait_ltr = Point(-565.82, -292.80, 'G portrait ltr')
point_F_landscape_a3 = Point(-1105.00, -213.19, 'F landscape a3')
point_G_landscape_a3 = Point(-1105.00, -234.88, 'G landscape a3')
point_F_landscape_a4 = Point(-1146.04, -300.08, 'F landscape a4')
point_G_landscape_a4 = Point(-1146.04, -321.77, 'G landscape a4')
point_F_landscape_ltr = Point(-1034.82, -155.33, 'F landscape ltr')
point_G_landscape_ltr = Point(-1034.82, -177.02, 'G landscape ltr')

#
# primary feature triangles
#
feature_dbc = Feature(point_D, point_B, point_C)
feature_dab = Feature(point_D, point_A, point_B)
feature_aed = Feature(point_A, point_E, point_D)
feature_eac = Feature(point_E, point_A, point_C)

#
# secondary feature triangles
#
feature_g_portrait_a3 = Feature(point_A, point_E, point_G_portrait_a3)
feature_g_portrait_a4 = Feature(point_A, point_E, point_G_portrait_a4)
feature_g_portrait_ltr = Feature(point_A, point_E, point_G_portrait_ltr)
feature_g_landscape_a3 = Feature(point_A, point_E, point_G_landscape_a3)
feature_g_landscape_a4 = Feature(point_A, point_E, point_G_landscape_a4)
feature_g_landscape_ltr = Feature(point_A, point_E, point_G_landscape_ltr)

feature_f_portrait_a3 = Feature(point_E, point_F_portrait_a3, point_G_portrait_a3)
feature_f_portrait_a4 = Feature(point_E, point_F_portrait_a4, point_G_portrait_a4)
feature_f_portrait_ltr = Feature(point_E, point_F_portrait_ltr, point_G_portrait_ltr)
feature_f_landscape_a3 = Feature(point_E, point_F_landscape_a3, point_G_landscape_a3)
feature_f_landscape_a4 = Feature(point_E, point_F_landscape_a4, point_G_landscape_a4)
feature_f_landscape_ltr = Feature(point_E, point_F_landscape_ltr, point_G_landscape_ltr)

#
# feature tolerances and minimum size for featuremath.blobs2features()
#
ratio_tol = 0.10
theta_tol = 0.09 # approx 5 degrees
min_size = 800

#
# Ratios of homogenous print coordinates above to printed point coordinates
#
ratio_portrait_a3 = 0.677938
ratio_portrait_a4 = 1.000007
ratio_portrait_ltr = 1.0729091
ratio_landscape_a3 = 0.999974
ratio_landscape_a4 = 1.506211
ratio_landscape_ltr = 1.456091

#
# basic conversions between millimeters, points, and inches
#
mmppt = 0.352777778
inppt = 0.013888889

ptpin = 1./inppt
ptpmm = 1./mmppt

#
# paper sizes in printed points
#
paper_size_landscape_a3 = 420 * ptpmm, 297 * ptpmm
paper_size_landscape_a4 = 297 * ptpmm, 210 * ptpmm
paper_size_landscape_ltr = 11 * ptpin, 8.5 * ptpin

paper_size_portrait_a3 = 297 * ptpmm, 420 * ptpmm
paper_size_portrait_a4 = 210 * ptpmm, 297 * ptpmm
paper_size_portrait_ltr = 8.5 * ptpin, 11 * ptpin

#
# preview map sizes
#
preview_size_landscape_a3 = 480, 314.932
preview_size_landscape_a4 = 480, 303.800
preview_size_landscape_ltr = 480, 360 - 24

preview_size_portrait_a3 = 360, 506.200
preview_size_portrait_a4 = 360, 504.897
preview_size_portrait_ltr = 360, 480 - 24
