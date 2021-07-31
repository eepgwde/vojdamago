## weaves

PWD0 := $(shell pwd)

X_STAMP ?= $(shell date +%Y-%m-%d-%H%M)


ifeq ($(MAKECMDGOALS),dist-local)

dist-local: hcc3-$(X_STAMP).zip 
	$(file >$@.in,$+)

hcc3-$(X_STAMP).zip: $(wildcard hcc3-*.jpeg) hcc3.Rout $(wildcard hcc3*.csv)
	zip $@ hcc3.dat Rplots.pdf $+

endif


ifeq ($(MAKECMDGOALS),dist)

dist::
	test -f dist-local.in

dist:: $(shell cat dist-local.in | xargs)
	$(X_HOST0) m_ sftp put $+


endif

