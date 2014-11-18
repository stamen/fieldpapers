# totally swiped from http://www.python.org/doc/2.5.2/ext/building.html
from distutils.core import setup, Extension

blobs = Extension('_blobs', sources=['blobs.cpp'])
version = '1.0.0'

setup(name = 'BlobDetector',
      version = version,
      description = 'A small package that detects and categorizes blobs in images.',
      author = 'Michal Migurski',
      author_email = 'mike@stamen.com',
      url = 'https://github.com/migurski/Blobdetector',
      packages = ['BlobDetector'],
      ext_modules = [blobs],
      download_url = 'https://github.com/downloads/migurski/Blobdetector/BlobDetector-%s.tar.gz' % version,
      license = 'BSD')
