## weaves

## R modelling

## On my site cache/out up the tree

include ../ldr/defs.mk

X_R = Rscript

S_FILE ?= $(X_BASE)/out/xsamples1.csv

## TARGET allows you to specify the data set.
## CLS0 allows you to use a different class of assets.

TARGET ?= xroadsc
CLS0 ?= cwy0

X_MODEL ?= gbm

## rpart trees are the all goal

all-local: $(TARGET)-$(CLS0).dat


all-local00: 
	$(MAKE) MAKEFLAGS="$(MAKEFLAGS)" -f rp.mk ppl00.dat

all-local0: all-local00 
	$(MAKE) MAKEFLAGS="$(MAKEFLAGS)" -f rp.mk ppl0.dat

all-local3: all-local0 $(TARGET)-3.dat 

all-local4: all-local3 $(TARGET)-4.dat

all-local5: all-local4 $(TARGET)-5.dat


all-gbm0: all-local5 $(TARGET)-7.dat 

all-rf: all-local5 $(TARGET)-8.dat

all-gbm: all-gbm0 $(TARGET)-9.dat

all: all-local all-$(X_MODEL)


X_TREE0 ?= xroadsc-7.dat
X_TREE1 ?= $(basename $(X_TREE0))r.dat

view0:
	echo $(X_TREE1) $(X_TREE0)


## Complicated one
## make -f br.mk TARGET=uni0 CLS0=modelq1 X_TREE0=xroadsc-8.dat all-local10

all-local10: $(X_TREE1)
	$(MAKE) MAKEFILES=$(lastword $(MAKEFILE_LIST)) MAKEFLAGS=$(MAKEFLAGS) X_TREE=$(X_TREE1) $(TARGET)-$(CLS0).dat


## Not a model

## This puts NZV into the br0 list.
## Run br4.R manually and adjust br4a.R to remove the NZV
$(TARGET)-3.dat: br3.R br3a.R ../R/brA0.R ppl0.dat
	$(X_R) br3.R $(TARGET)
	mv ppl3.dat $@

## This removes NZV and finds correlations
## br4a.r is the set of NZV to remove
$(TARGET)-4.dat: br4.R br4a.R br4a0.R ../R/brA0.R $(TARGET)-3.dat
	$(X_R) br4.R $(TARGET)-3.dat
	mv ppl4.dat $@

## This removes correlations and creates another correlation plot
## br5a.r is the set of correlations to remove
$(TARGET)-5.dat: br5.R br5a.R ../R/brA0.R $(TARGET)-4.dat
	$(X_R) br5.R $(TARGET)-4.dat
	mv ppl5.dat $@

## Model: plain GBM
$(TARGET)-7.dat: br7.R $(TARGET)-5.dat
	$(X_R) $+
	mv ppl7.dat $@

## Model: sampled GBM uses br7 for its seeds
$(TARGET)-9.dat: br9.R $(TARGET)-7.dat
	$(X_R) $+
	mv ppl9.dat $@

## Model: Random forest
## Because it is slow and fair, use this last.
## TODO: try and speed it up by using PCA
$(TARGET)-8.dat: br8.R $(TARGET)-5.dat
	$(X_R) $+
	mv ppl8.dat $@

clean::
	rm -f $(wildcard *-*.jpeg) $(wildcard *-*.tiff $(wildcard *-*.log) $(wildcard *-check.flag) $(wildcard *-*.dat)


check: $(TARGET)-check.flag


$(TARGET)-check.flag:: br1.R ppl0.dat
	$(H_) -f $(TARGET) rpart all0
	touch $@


## Snapshotting

dist-local::
	$(MAKE) MAKEFILES=$(TOP)/ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -f dstr.mk dist-local


dist: dist-local 

## Test: checking 

cargs: cargs.R ppl0.dat
	$(X_R) cargs.R xroadsc

