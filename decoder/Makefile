all: ModestMaps ws-decode bin
	#

ModestMaps:
	svn co http://modestmaps.googlecode.com/svn/trunk/py/ModestMaps

ws-decode:
	curl -O http://aaronland.info/java/ws-decode/ws-decode-0.1.tar.gz
	tar -xzf ws-decode-0.1.tar.gz
	rm -f ws-decode-0.1.tar.gz
	mv ws-decode-0.1 ws-decode
	
bin:
	curl -O http://www.vlfeat.org/download/vlfeat-0.9.3-bin.tar.gz
	tar -xzf vlfeat-0.9.3-bin.tar.gz
	mv vlfeat/bin/mac bin
	rm -rf vlfeat vlfeat-0.9.3-bin.tar.gz

clean:
	rm -rf ModestMaps
	rm -rf ws-decode
	rm -rf bin
