from tempfile import mkstemp
from os import close, unlink
from math import hypot

from osgeo import gdal, osr

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
    
    ul_gcp = gdal.GCP(ul_x, ul_y, ul_z, ul_px.x, ul_px.y)
    ur_gcp = gdal.GCP(ur_x, ur_y, ur_z, ur_px.x, ur_px.y)
    lr_gcp = gdal.GCP(lr_x, lr_y, lr_z, lr_px.x, lr_px.y)
    ll_gcp = gdal.GCP(ll_x, ll_y, ll_z, ll_px.x, ll_px.y)
    
    return ul_gcp, ur_gcp, lr_gcp, ll_gcp

def create_geotiff(image, p2s, paper_width_pt, paper_height_pt, north, west, south, east):
    """ Return raw bytes of a GCP-based GeoTIFF for this decoded scan.
    """
    #
    # Prepare geographic context - projection and ground control points.
    #
    gcps = calculate_gcps(p2s, paper_width_pt, paper_height_pt, north, west, south, east)
    merc = osr.SpatialReference()
    merc.ImportFromEPSG(900913)
    
    #
    # Start an output file
    #
    driver = gdal.GetDriverByName('GTiff')
    
    handle, filename = mkstemp(prefix='geotiff-', suffix='.tif')
    dataset = driver.Create(filename, image.size[0], image.size[1], 3, options=['COMPRESS=JPEG', 'JPEG_QUALITY=80'])
    dataset.SetGCPs(gcps, str(merc))
    
    close(handle)
    
    #
    # Copy over the pixel data for each channel.
    #
    for (i, chan) in enumerate(image.convert('RGB').split()):
        band = dataset.GetRasterBand(i + 1)
        band.WriteRaster(0, 0, image.size[0], image.size[1], chan.tostring())
    
    #
    # Close out and return.
    #
    dataset.FlushCache()
    bytes = open(filename, 'r').read()
    
    unlink(filename)
    return bytes

def generate_tiles(image, s2p, paper_width_pt, paper_height_pt, north, west, south, east):
    """ Yield a stream of coordinates and tile images for a full set of zoom levels.
    
        Internal work is done by generate_tiles_for_zoom().
    """
    osm = OpenStreetMapProvider()
    
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
        
        for (coord, tile_img) in generate_tiles_for_zoom(image, s2c, zoom):
            yield (coord, tile_img)
    
def generate_tiles_for_zoom(image, scan2coord, zoom):
    """ Yield a stream of coordinates and tile images for a given zoom level.
    """
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
            coord_bbox = col, row, col + 1, row + 1
            tile_img = extract_image(scan2coord, coord_bbox, image, (256, 256), 256/8)
            
            yield (coord, tile_img)
