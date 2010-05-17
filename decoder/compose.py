import sys

import osgeo.gdal as gdal
import PIL.Image
import PIL.ImageStat

src = gdal.Open(sys.argv[1])

print src

print src.RasterXSize, src.RasterYSize

areas = [(0, 0, src.RasterXSize, 50),
         (0, 0, 50, src.RasterYSize),
         (0, src.RasterYSize - 50, src.RasterXSize, 50),
         (src.RasterXSize - 50, 0, 50, src.RasterYSize)]

def bandaverage(band, x, y, w, h):
    img = PIL.Image.fromstring('L', (w, h), band.ReadRaster(x, y, w, h))
    return PIL.ImageStat.Stat(img).mean[0]

for band in (1, 2, 3):
    avgs = [(bandaverage(src.GetRasterBand(band), x, y, w, h), w * h)
            for (x, y, w, h) in areas]

    total = sum( [size for (mean, size) in avgs] )
    average = sum( [(mean * size / total) for (mean, size) in avgs] )
    print int(average)
