#
# Auto-detect architecture so we can build SIFT
#

Darwin_PPC_ARCH             := mac
Darwin_Power_Macintosh_ARCH := mac
Darwin_i386_ARCH            := maci
Linux_i386_ARCH             := glx
Linux_i686_ARCH             := glx
Linux_unknown_ARCH          := glx
Linux_x86_64_ARCH           := a64
Linux_armv5tel_ARCH         := arm

UNAME := $(shell uname -sm)
ARCH  ?= $($(shell echo "$(UNAME)" | tr \  _)_ARCH)

ifeq ($(ARCH),)
die:=$(error I am unable to figure what kind of machine you are running)
endif

#
# Do the actual thing with the stuff
#

all: bin/sift
	#

bin/sift: vlfeat/bin/$(ARCH)/sift
	cp -r vlfeat/bin/$(ARCH) bin

vlfeat/bin/$(ARCH)/sift:
	cd vlfeat && make

clean:
	rm -rf bin
	rm -rf vlfeat/bin/$(ARCH)
