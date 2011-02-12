from sys import argv, stderr
from StringIO import StringIO
from urllib import urlopen

from PIL import Image
from PIL.ImageDraw import ImageDraw

from featuremath import Feature, MatchedFeature, blobs2features, stream_triples, stream_pairs
from imagemath import Point, imgblobs, extract_image
from matrixmath import quad2quad

def blob_match(input):
    """
    """
    blobs = imgblobs(input, 'highpass.jpg', 'preblobs.jpg')
    
    # points, clockwise from top-left
    A = Point(-508.37, -720.33)
    B = Point( -13.56, -720.37)
    C = Point( -13.56, -229.53)
    D = Point(-149.12,  -13.56)
    
    acb = Feature(A, C, B)
    adc = Feature(A, D, C)
    dab = Feature(D, A, B)
    
    acb_matches = blobs2features(blobs, 800, acb.theta-.02, acb.theta+.02, acb.ratio-.04, acb.ratio+.04)
    adc_matches = blobs2features(blobs, 800, adc.theta-.02, adc.theta+.02, adc.ratio-.04, adc.ratio+.04)
    dab_matches = blobs2features(blobs, 800, dab.theta-.02, dab.theta+.02, dab.ratio-.04, dab.ratio+.04)
    
    for dab_match in dab_matches:
        print dab_match
    
    for (acb_tuple, adc_tuple) in stream_pairs(acb_matches, adc_matches):
        
        i0, j0, k0, r0, t0 = acb_tuple
        i1, j1, k1, r1, t1 = adc_tuple
        
        acb_match = MatchedFeature(acb, blobs[i0], blobs[j0], blobs[k0])
        adc_match = MatchedFeature(adc, blobs[i1], blobs[j1], blobs[k1])
        
        if acb_match.fits(adc_match):
            print >> stderr, 'yes:', (i0, j0, k0), (i1, j1, k1)
            
            return acb_match, adc_match
        
        print >> stderr, 'no',
    
    return None

def main(url):
    """
    """
    input = Image.open(StringIO(urlopen(url).read()))
    acb_match, adc_match = blob_match(input)
    
    # transform from scan pixels to print points - TL, TR, BR, BL
    s2p = quad2quad(acb_match.s1, acb_match.p1, acb_match.s3, acb_match.p3,
                    adc_match.s3, adc_match.p3, adc_match.s2, adc_match.p2)
    
    print s2p
    
    extract_image(s2p, (-135.6-9, -135.6-9, 0+9, 0+9), input, (500, 500)).save('qrcode.png')

    return 0

if __name__ == '__main__':

    url = argv[1]
    
    exit(main(url))


    
    print 'opening...'
    input = Image.open(argv[1])

    print 'reading blobs...'
    blobs = imgblobs(input, 'highpass.jpg', 'preblobs.jpg')
    print len(blobs), 'blobs.'
    
    print 'preparing features...'
    tl = Point(41.4, 41.4)
    tr = Point(570.6, 41.4)
    bl = Point(41.4, 750.6)
    br = Point(570.6, 750.6)

    f1 = Feature(tl, tr, bl) # point order: bl, tr, tl
    f2 = Feature(tr, tl, br) # point order: br, tl, tr
    
    matches1 = blobs2features(blobs, 1000, f1.theta-.016, f1.theta+.016, f1.ratio-.036, f1.ratio+.036)
    matches2 = blobs2features(blobs, 1000, f2.theta-.016, f2.theta+.016, f2.ratio-.036, f2.ratio+.036)
    
    found = False
    
    for (match1, match2) in stream_pairs(matches1, matches2):
    
        match1 = MatchedFeature(f1, *[blobs[i] for i in match1[:3]])
        match2 = MatchedFeature(f2, *[blobs[i] for i in match2[:3]])
        
        print >> stderr, '?',

        if match1.fits(match2):
            print >> stderr, 'yes.'
            
            found = True
            break
    
    assert found
    
    #---------------------------------------------------------------------------
    
    # transform from scan pixels to print points - TL, TR, BR, BL
    s2p = quad2quad(match1.s3, match1.p3, match2.s3, match2.p3,
                    match2.s1, match2.p1, match1.s1, match1.p1)
    
    extract_image(s2p, (468-9, 360-9, 576+9, 468+9), input, (500, 500)).save('qrcode.png')
    
    print 'drawing...'
    draw = ImageDraw(input)
    
    for match in (match1, match2):

        s1 = match.s1
        s2 = match.s2
        s3 = match.s3
        
        draw.line((s1.x, s1.y, s2.x, s2.y), fill=(0, 0xCC, 0))
        draw.line((s1.x, s1.y, s3.x, s3.y), fill=(0xCC, 0, 0xCC))
        draw.line((s2.x, s2.y, s3.x, s3.y), fill=(0x99, 0, 0x99))
    
    for blob in blobs:
        draw.rectangle(blob.bbox, outline=(0xFF, 0, 0))

    print 'saving...'
    input.save('out.png')
