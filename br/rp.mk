## weaves

## R modelling

## On my site cache/out up the tree

include ../ldr/defs.mk

X_R = Rscript

S_FILE ?= $(X_BASE)/out/xsamples1.csv
S_FILE1 ?= $(X_BASE)/out/xe2c.csv

## TARGET allows you to specify the data set.
## CLS0 allows you to use a different class of assets.

TARGET ?= xroadsc
CLS0 ?= cwy0

X_MODEL ?= gbm

## rpart trees are the all goal

all: rp2.txt $(TARGET)-$(CLS0).dat

## Rules

# CSV to .Rdat. logicals. br0 added
ppl00.dat: br00.R $(S_FILE)	
	test -f $(S_FILE)
	$(X_R) $+

# data splitting. br0 populated with feature groups, outcome

ppl0.dat: br0.R ppl00.dat	
	$(X_R) br0.R

## Not a model - partition trees

X_TREE ?= ppl0.dat

$(TARGET)-$(CLS0).dat: rp1.R $(X_TREE)
	$(X_R) rp1.R $(X_TREE) $(TARGET) $(CLS0)
	mv ppl1.dat $(TARGET)-$(CLS0).dat

rp2.txt: rp2.R $(S_FILE1)
	$(X_R) rp2.R $(S_FILE1)

## Snapshotting

dist-local::
	$(MAKE) MAKEFILES=$(TOP)/ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -f dstr.mk dist-local


dist: dist-local 


