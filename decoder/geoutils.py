from tempfile import mkstemp
from os import close, unlink

from osgeo import gdal, osr

from matrixmath import Point
from dimensions import ptpin

def generate_gcps(p2s, paper_width_pt, paper_height_pt, north, west, south, east):
    """
    """
    merc = osr.SpatialReference()
    merc.ImportFromEPSG(900913)
    
    latlon = osr.SpatialReference()
    latlon.ImportFromEPSG(4326)
    
    proj = osr.CoordinateTransformation(latlon, merc)
    
    ul_x, ul_y, ul_z = proj.TransformPoint(west, north)
    ur_x, ur_y, ur_z = proj.TransformPoint(east, north)
    lr_x, lr_y, lr_z = proj.TransformPoint(east, south)
    ll_x, ll_y, ll_z = proj.TransformPoint(west, south)
    
    ll_pt = Point(1 * ptpin - paper_width_pt, 0)
    ul_pt = Point(1 * ptpin - paper_width_pt, 1.5 * ptpin - paper_height_pt)
    ur_pt = Point(0, 1.5 * ptpin - paper_height_pt)
    lr_pt = Point(0, 0)
    
    ul_px, ur_px, lr_px, ll_px = p2s(ul_pt), p2s(ur_pt), p2s(lr_pt), p2s(ll_pt)
    
    ul_gcp = gdal.GCP(ul_x, ul_y, ul_z, ul_px.x, ul_px.y)
    ur_gcp = gdal.GCP(ur_x, ur_y, ur_z, ur_px.x, ur_px.y)
    lr_gcp = gdal.GCP(lr_x, lr_y, lr_z, lr_px.x, lr_px.y)
    ll_gcp = gdal.GCP(ll_x, ll_y, ll_z, ll_px.x, ll_px.y)
    
    return ul_gcp, ur_gcp, lr_gcp, ll_gcp

def generate_geotiff(input, p2s, paper_width_pt, paper_height_pt, north, west, south, east):
    """
    """
    merc = osr.SpatialReference()
    merc.ImportFromEPSG(900913)
    
    gcps = generate_gcps(p2s, paper_width_pt, paper_height_pt, north, west, south, east)
    
    driver = gdal.GetDriverByName('GTiff')
    
    handle, filename = mkstemp(prefix='geotiff-', suffix='.tif')
    dataset = driver.Create(filename, input.size[0], input.size[1], 3, options=['COMPRESS=JPEG', 'JPEG_QUALITY=80'])
    dataset.SetGCPs(gcps, str(merc))
    
    close(handle)
    
    for (i, chan) in enumerate(input.convert('RGB').split()):
        band = dataset.GetRasterBand(i + 1)
        band.WriteRaster(0, 0, input.size[0], input.size[1], chan.tostring())
    
    dataset.FlushCache()
    bytes = open(filename, 'r').read()
    
    unlink(filename)
    return bytes
