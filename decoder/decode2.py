from sys import argv
from math import e

from PIL import Image
from PIL.Image import ANTIALIAS
from PIL.ImageOps import autocontrast
from PIL.ImageDraw import ImageDraw
from PIL.ImageFilter import MinFilter, MaxFilter
from numpy import array, fromstring, ubyte, convolve

from BlobDetector import detect

def highpass(img, radius):
    """ Perform a high-pass with a given radius on the image, return a new image.
    """
    #
    # Convert image to arrays
    #
    orig = img2arr(img)
    blur = orig.copy()
    
    #
    # Build a convolution kernel based on
    # http://en.wikipedia.org/wiki/Gaussian_function#Two-dimensional_Gaussian_function
    #
    kernel = range(-radius, radius + 1)
    kernel = [(d ** 2) / (2 * (radius * .5) ** 2) for d in kernel]
    kernel = [e ** -d for d in kernel]
    kernel = array(kernel, dtype=float) / sum(kernel)
    
    #
    # Convolve in two dimensions.
    #
    for row in range(blur.shape[0]):
        blur[row,:] = convolve(blur[row,:], kernel, 'same')
    
    for col in range(blur.shape[1]):
        blur[:,col] = convolve(blur[:,col], kernel, 'same')
    
    #
    # Combine blurred with original, see http://www.gimp.org/tutorials/Sketch_Effect/
    #
    high = .5 * orig + .5 * (1 - blur)
    
    return arr2img(high)

def arr2img(ar):
    """ Convert Numeric array to PIL Image.
    """
    return Image.fromstring('L', (ar.shape[1], ar.shape[0]), ar.astype(ubyte).tostring())

def img2arr(im):
    """ Convert PIL Image to Numeric array.
    """
    return fromstring(im.tostring(), ubyte).reshape((im.size[1], im.size[0]))

if __name__ == '__main__':
    
    input = Image.open(argv[1])
    input.thumbnail((1600, 1600), ANTIALIAS)

    output = autocontrast(input.convert('L'))
    output = highpass(output, 16)
    output = output.point(lambda p: (p < 120) and 0xFF or 0x00)
    output = output.filter(MinFilter(3)).filter(MaxFilter(3))
    
    draw = ImageDraw(input)
    
    for bbox in detect(output):
        draw.rectangle(bbox, outline=(0xFF, 0, 0))
    
    input.save('out.png')
