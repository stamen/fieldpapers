all: ModestMaps bin
	#

ModestMaps:
	svn co http://modestmaps.googlecode.com/svn/trunk/py/ModestMaps

bin:
	curl -O http://www.vlfeat.org/download/vlfeat-0.9.3-bin.tar.gz
	tar -xzf vlfeat-0.9.3-bin.tar.gz
	mv vlfeat/bin/mac bin
	rm -rf vlfeat vlfeat-0.9.3-bin.tar.gz

clean:
	rm -rf ModestMaps
	rm -rf bin
