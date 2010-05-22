import sys

import osgeo.gdal as gdal
import PIL.Image
import PIL.ImageStat

src = gdal.Open(sys.argv[1])

print src

print src.RasterXSize, src.RasterYSize

buffer = 25

areas = [(0, 0, src.RasterXSize, buffer),
         (0, 0, buffer, src.RasterYSize),
         (0, src.RasterYSize - buffer, src.RasterXSize, buffer),
         (src.RasterXSize - buffer, 0, buffer, src.RasterYSize)]

def bandaverage(band, x, y, w, h):
    img = PIL.Image.fromstring('L', (w, h), band.ReadRaster(x, y, w, h))
    return PIL.ImageStat.Stat(img).mean[0]

for band in (1, 2, 3):
    band = src.GetRasterBand(band)
    avgs = [(bandaverage(band, x, y, w, h), w * h)
            for (x, y, w, h) in areas]

    area = sum( [size for (mean, size) in avgs] )
    average = sum( [(mean * size / area) for (mean, size) in avgs] )

    print int(average)
