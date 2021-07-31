## weaves
##
## Snapshots and posting results
##
## sub-make our defs.mk is passed via MAKEFILES

xPWD := $(shell pwd)

X_STAMP ?= $(shell date +%Y-%m-%d-%H%M)


ifeq ($(MAKECMDGOALS),dist-local)

dist-local:: rpart-$(X_STAMP).zip
	$(file >$@.in,$+)

$(TARGET)-$(CLS0)-$(X_STAMP).zip: $(TARGET)-$(CLS0).dat
	for i in $(wildcard $(TARGET)-$(CLS0)-*.txt); do unix2dos $$i; done
	zip $@  $(wildcard $(TARGET)-$(CLS0)-*.tiff) $(wildcard $(TARGET)-$(CLS0)-*.txt) 

$(basename $(X_TREE0))-$(X_STAMP).zip: $(wildcard $(TARGET)-$(CLS0)-*.tiff) $(TARGET)-$(CLS0).dat $(wildcard $(basename $(X_TREE0))-pp-*.csv)
	zip $@ $+ 

rpart-$(X_STAMP).zip: $(wildcard *-*-*.tiff) $(wildcard *-*-*.txt) $(wildcard *-*.dat)
	rm -f $@
	zip $@ $+


dist-local1: all-local1
	rm -f ncas1.zip
	zip ncas1 $(wildcard ncas1-*.jpeg)

endif


ifeq ($(MAKECMDGOALS),dist)

dist::
	test -f dist-local.in

dist:: $(shell cat dist-local.in | xargs)
	$(X_HOST0) m_ sftp put $+



endif

