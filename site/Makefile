all:
	mkdir -p templates/cache
	chmod a+rwX templates/cache
	mkdir -p tmp
	chmod a+rwX tmp
	cd lib && make all
	cd www && make all

clean:
	rm -rf templates/cache
	rm -rf tmp
	cd lib && make clean
