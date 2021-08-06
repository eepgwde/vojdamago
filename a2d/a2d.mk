## weaves

## R modelling

## On my host - cache/out contains the file.

include ../ldr/defs.mk 

S_FILE ?= $(TOP)/cache/out/xwrkcwy1.csv

X_R = Rscript

T_DIR ?= /cache/incoming/hcc

H_ = $(TOP)/hcc

all: hcc3.Rout 

dist-local:
	$(MAKE) MAKEFILES=../ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -f dstr.mk dist-local

dist:
	$(MAKE) MAKEFILES=../ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -f dstr.mk dist


## see regimes.csv - put a "-" in front for before, otherwise as is.
S_RGM ?= dress2

# This produces the Enquiries Repudiations cross-correlations.
hcc00.dat: hcc1.R $(S_FILE) 
	rm -f $(wildcard ncas1-*.jpeg)
	$(X_R) $+ $(S_RGM)

## Bit of a kludge - a blank template is used 
clean-local:
	rm -f hcc2.csv

## works + defects to lifetime

hcc3.csv hcc3.dat hcc3.Rout: hcc3.R ../R/brA0.R hcc0a.R hcc00.dat
	:> all.Rout
	rm -f hcc3-0??.jpeg
	Rscript hcc3.R 
	mv all.Rout hcc3.Rout
	unix2dos hcc3.Rout
	$(H_) hcc models0 hcc3.Rout > hcc3.csv


clean::
	$(SHELL) -c "rm -f *.jpeg Rplots.pdf hcc?.dat hcc00.dat hcc?.Rout hcc?.csv"
