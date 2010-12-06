all: FPDF Smarty
	#

FPDF:
	curl -sL "http://www.fpdf.org/en/dl.php?v=16&f=tgz" > fpdf.tar.gz
	tar -xzf fpdf.tar.gz
	mv fpdf16 FPDF
	rm -f fpdf.tar.gz

Smarty:
	curl -sL http://www.smarty.net/files/Smarty-2.6.26.tar.gz > Smarty-2.6.26.tar.gz
	tar -xzf Smarty-2.6.26.tar.gz
	mv Smarty-2.6.26/libs Smarty
	rm -rf Smarty-2.6.26 Smarty-2.6.26.tar.gz

clean:
	rm -rf FPDF Smarty
