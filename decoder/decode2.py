from sys import argv, stderr

from PIL import Image
from PIL.ImageDraw import ImageDraw

from featuremath import Feature, MatchedFeature, blobs2features, stream_pairs
from imagemath import Point, imgblobs, extract_image
from matrixmath import quad2quad

if __name__ == '__main__':
    
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
