from tempfile import mkstemp
from os import close, unlink
from math import hypot
from subprocess import Popen

from osgeo import gdal, osr

try:
    from PIL import Image
except ImportError:
    import Image

from ModestMaps.Geo import Location
from ModestMaps.Core import Coordinate
from ModestMaps.OpenStreetMap import Provider as OpenStreetMapProvider

from matrixmath import triangle2triangle
from imagemath import extract_image
from matrixmath import Point
from dimensions import ptpin

def calculate_gcps(p2s, paper_width_pt, paper_height_pt, north, west, south, east):
    """
    """
    merc = osr.SpatialReference()
    merc.ImportFromEPSG(900913)
    
    latlon = osr.SpatialReference()
    latlon.ImportFromEPSG(4326)
    
    proj = osr.CoordinateTransformation(latlon, merc)
    
    # x, y in mercator meters
    ul_x, ul_y, ul_z = proj.TransformPoint(west, north)
    ur_x, ur_y, ur_z = proj.TransformPoint(east, north)
    lr_x, lr_y, lr_z = proj.TransformPoint(east, south)
    ll_x, ll_y, ll_z = proj.TransformPoint(west, south)
    
    # x, y in printed points
    ll_pt = Point(1 * ptpin - paper_width_pt, 0)
    ul_pt = Point(1 * ptpin - paper_width_pt, 1.5 * ptpin - paper_height_pt)
    ur_pt = Point(0, 1.5 * ptpin - paper_height_pt)
    lr_pt = Point(0, 0)
    
    # x, y in image pixels
    ul_px, ur_px, lr_px, ll_px = [p2s(pt) for pt in (ul_pt, ur_pt, lr_pt, ll_pt)]
    
    ul_gcp = (ul_x, ul_y, ul_px.x, ul_px.y)
    ur_gcp = (ur_x, ur_y, ur_px.x, ur_px.y)
    lr_gcp = (lr_x, lr_y, lr_px.x, lr_px.y)
    ll_gcp = (ll_x, ll_y, ll_px.x, ll_px.y)
    
    return ul_gcp, ur_gcp, lr_gcp, ll_gcp
    
    ul_gcp = gdal.GCP(ul_x, ul_y, ul_z, ul_px.x, ul_px.y)
    ur_gcp = gdal.GCP(ur_x, ur_y, ur_z, ur_px.x, ur_px.y)
    lr_gcp = gdal.GCP(lr_x, lr_y, lr_z, lr_px.x, lr_px.y)
    ll_gcp = gdal.GCP(ll_x, ll_y, ll_z, ll_px.x, ll_px.y)
    
    return ul_gcp, ur_gcp, lr_gcp, ll_gcp

def calculate_geotransform(gcps, full_width, fuller_width, buffer):
    """ Return a geotransform tuple that puts the GCPs into a chosen image size.
    """
    xs, ys = [gcp.GCPX for gcp in gcps], [gcp.GCPY for gcp in gcps]
    xmin, ymin, xmax, ymax = min(xs), min(ys), max(xs), max(ys)

    xspan = xmax - xmin
    yspan = ymin - ymax # reversed because north points up
    
    # calculate the width and height in map units
    
    aspect = xspan / yspan
    
    if aspect > 1.2:
        full_width = fuller_width
    
    width = full_width - buffer * 2
    height = abs(width / aspect)
    
    # calculate the offset and stride in map units - that's the geotransform
    
    xstride = xspan / width
    ystride = yspan / height
    
    xoff = xmin - xstride * buffer
    yoff = ymax - ystride * buffer # ymax because north points up
    
    xform = (xoff, xstride, 0, yoff, 0, ystride)
    
    # finalize the image size in image pixels and image bounds in map units
    
    full_height = int(height + buffer * 2)
    bounds = (xoff, yoff, xoff + full_width * xstride, yoff + full_height * ystride)
    
    return xform, bounds, (full_width, full_height)

def create_geotiff(image, p2s, paper_width_pt, paper_height_pt, north, west, south, east):
    """ Return raw bytes of a GCP-based GeoTIFF for this decoded scan.
    """
    #
    # Prepare geographic context - projection and ground control points.
    #
    gcps = calculate_gcps(p2s, paper_width_pt, paper_height_pt, north, west, south, east)
    merc = osr.SpatialReference()
    merc.ImportFromEPSG(900913)
    
    handle, vrt_filename = mkstemp(dir='.', prefix='geotiff-', suffix='.vrt')
    handle, png_filename = mkstemp(dir='.', prefix='geotiff-', suffix='.png')
    image.save(png_filename)
    
    translate = 'gdal_translate -of VRT'.split()
    
    for (e, n, x, y) in gcps:
        translate += ('-gcp %(x)d %(y)d %(e)d %(n)d' % locals()).split()
    
    translate += ['-a_srs', 'EPSG:900913']
    translate += [png_filename, vrt_filename]
    
    print ' '.join(translate)
    
    translate = Popen(translate)
    translate.wait()
    
    handle, tif_filename = mkstemp(dir='.', prefix='geotiff-', suffix='.tif')
    
    warp = 'gdalwarp -tps -co COMPRESS=JPEG -co QUALITY=80'.split()
    warp += [vrt_filename, tif_filename]
    
    print ' '.join(warp)
    
    warp = Popen(warp)
    warp.wait()
    
    unlink(png_filename)
    unlink(vrt_filename)
    
    #
    # Read the raw bytes of the GeoTIFF for return.
    #
    geotiff_bytes = open(tif_filename).read()
    
    exit(1)
    
    #
    # Do another one, smaller this time for the projected JPEG.
    #
    xform, img_bounds, img_size = calculate_geotransform(gcps, 760, 960, 100)
    
    handle, geojpeg_filename = mkstemp(prefix='geojpeg-', suffix='.tif')
    geojpeg_ds = driver.Create(geojpeg_filename, img_size[0], img_size[1], 3)
    close(handle)

    geojpeg_ds.SetProjection(merc.ExportToWkt())
    geojpeg_ds.SetGeoTransform(xform)
    
    gdal.ReprojectImage(geotiff_ds, geojpeg_ds, None, None, gdal.GRA_Cubic)
    
    channels = []
    
    for b in (1, 2, 3):
        band = geojpeg_ds.GetRasterBand(b)
        chan = Image.fromstring('L', img_size, band.ReadRaster(0, 0, *img_size))
        channels.append(chan)
    
    geojpeg_img = Image.merge('RGB', channels)
    
    #
    # Project image bounds to geographic coordinates
    #
    latlon = osr.SpatialReference()
    latlon.ImportFromEPSG(4326)
    
    proj = osr.CoordinateTransformation(merc, latlon)
    
    x1, y1, x2, y2 = img_bounds
    lon1, lat1, z1 = proj.TransformPoint(x1, y1)
    lon2, lat2, z2 = proj.TransformPoint(x2, y2)
    img_bounds = min(lat1, lat2), min(lon1, lon2), max(lat1, lat2), max(lon1, lon2)
    
    #
    # Close out and return.
    #
    unlink(geotiff_filename)
    unlink(geojpeg_filename)

    return geotiff_bytes, geojpeg_img, img_bounds

def list_tiles_for_bounds(image, s2p, paper_width_pt, paper_height_pt, north, west, south, east):
    """ Return a list of coordinates and scan-to-coord functions for a full set of zoom levels.
    
        Internal work is done by list_tiles_for_bounds_zoom().
    """
    osm = OpenStreetMapProvider()
    coords = []
    
    for zoom in range(19):
        #
        # Coordinates of three print corners
        #
        
        ul = osm.locationCoordinate(Location(north, west)).zoomTo(zoom)
        ur = osm.locationCoordinate(Location(north, east)).zoomTo(zoom)
        lr = osm.locationCoordinate(Location(south, east)).zoomTo(zoom)
        
        #
        # Matching points in print and coordinate spaces
        #
        
        ul_pt = Point(1 * ptpin - paper_width_pt, 1.5 * ptpin - paper_height_pt)
        ul_co = Point(ul.column, ul.row)
    
        ur_pt = Point(0, 1.5 * ptpin - paper_height_pt)
        ur_co = Point(ur.column, ur.row)
    
        lr_pt = Point(0, 0)
        lr_co = Point(lr.column, lr.row)
        
        scan_dim = hypot(image.size[0], image.size[1])
        zoom_dim = hypot((lr_co.x - ul_co.x) * 256, (lr_co.y - ul_co.y) * 256)
        
        if zoom_dim/scan_dim < .05:
            # too zoomed-out
            continue
        
        if zoom_dim/scan_dim > 3.:
            # too zoomed-in
            break
        
        #
        # scan2coord by way of scan2print and print2coord
        #

        p2c = triangle2triangle(ul_pt, ul_co, ur_pt, ur_co, lr_pt, lr_co)
        s2c = s2p.multiply(p2c)
        
        coords += list_tiles_for_bounds_zoom(image, s2c, zoom)
    
    return coords
    
def list_tiles_for_bounds_zoom(image, scan2coord, zoom):
    """ Return a list of coordinates and scan-to-coord functions for a given zoom level.
    """
    coords = []
    
    ul = scan2coord(Point(0, 0))
    ur = scan2coord(Point(image.size[0], 0))
    lr = scan2coord(Point(*image.size))
    ll = scan2coord(Point(0, image.size[1]))
    
    minrow = min(ul.y, ur.y, lr.y, ll.y)
    maxrow = max(ul.y, ur.y, lr.y, ll.y)
    mincol = min(ul.x, ur.x, lr.x, ll.x)
    maxcol = max(ul.x, ur.x, lr.x, ll.x)
    
    for row in range(int(minrow), int(maxrow) + 1):
        for col in range(int(mincol), int(maxcol) + 1):
            coord = Coordinate(row, col, zoom)
            coords.append((coord, scan2coord))
    
    return coords
    
def extract_tile_for_coord(image, coord, scan2coord):
    """ Return an image for a given coordinate.
    """
    coord_bbox = coord.column, coord.row, coord.column + 1, coord.row + 1
    tile_img = extract_image(scan2coord, coord_bbox, image, (256, 256), 256/8)
    
    return tile_img
