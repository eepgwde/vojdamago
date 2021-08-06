## weaves

## R modelling

## On my host - cache/out contains the file.

include ../ldr/defs.mk

S_FILE ?= $(TOP)/cache/out/xncas1.csv

X_R = Rscript

H_ = $(TOP)/hcc

all: hcc3.Rout hcc4.Rout hcc5.Rout hcc5.check xncas3.csv

dist-local:
	$(MAKE) MAKEFILES=../ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -f dstr.mk dist-local

dist:
	$(MAKE) MAKEFILES=../ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -f dstr.mk dist


hcc5.check: 
	$(H_) hcc preds $(wildcard hcc?.csv)



check-local:: hcc5.check

## see regimes.csv - put a "-" in front for before, otherwise as is.
S_RGM ?= all

# This produces the Enquiries Repudiations cross-correlations.
hcc00.dat: hcc1.R $(S_FILE) 
	rm -f $(wildcard ncas1-*.jpeg)
	$(X_R) $+ $(S_RGM)

## Bit of a kludge - a blank template is used 
clean-local:
	rm -f hcc2.csv

hcc2.csv: xncas2-blank.csv
	cp $< $@

## weather to Enquiries

hcc3.dat hcc3.csv hcc3.Rout: hcc3.R ../R/brA0.R hcc0a.R hcc2.csv hcc00.dat
	:> all.Rout
	rm -f hcc3-0??.jpeg
	Rscript hcc3.R hcc2.csv hcc3.csv
	mv all.Rout hcc3.Rout
	unix2dos hcc3.Rout

## Enquiries to Repudiations

hcc4.csv hcc4.Rout: hcc4.R ../R/brA0.R hcc0a.R hcc3.csv
	:> all.Rout
	rm -f hcc4-0??.jpeg
	Rscript hcc4.R hcc3.csv hcc4.csv
	mv all.Rout hcc4.Rout
	unix2dos hcc4.Rout

## Repudiations to Claims

hcc5.csv hcc5.Rout: hcc5.R ../R/brA0.R hcc0a.R hcc4.csv
	:> all.Rout
	rm -f hcc5-0??.jpeg
	Rscript hcc5.R hcc4.csv hcc5.csv
	mv all.Rout hcc5.Rout
	unix2dos hcc5.Rout

## Models for enqsX to repudns


define GOAL_template =
all-hcc4a-$(2):: $(1)-$(2)-hcc4a.dat

$(1)-$(2)-hcc4a.dat: hcc4a.R ../R/brA0.R hcc0a.R hcc3.dat 
	:> all.Rout
	rm -f gams.$(1).$(2)-*.jpeg
	Rscript hcc4a.R $(1) $(2)
	mv all.Rout hcc4a.Rout
	unix2dos hcc4a.Rout
	mv hcc4a.Rout gams-$(1)-$(2).Rout
	mv hcc4a.dat $(1)-$(2)-hcc4a.dat

endef

## Build a set of models for each enquiry to repudns

X_ENQS = enqs enq1s enq2s enqrs enqr1s enqr2s 

$(foreach x0,$(X_ENQS), $(eval $(call GOAL_template,$(x0),repudns)))
$(foreach x0,$(X_ENQS), $(eval $(call GOAL_template,$(x0),claims)))

all-hcc4a:: models-repudns-$(S_RGM).csv models-claims-$(S_RGM).csv

models-repudns-$(S_RGM).csv: all-hcc4a-repudns 
	$(H_)  -s repudns hcc models > $@

models-claims-$(S_RGM).csv: all-hcc4a-claims
	$(H_)  -s claims hcc models > $@


hcc4a.dat: hcc4a.R ../R/brA0.R hcc0a.R hcc3.dat
	:> all.Rout
	rm -f gams.repudns.enqrs-*.jpeg
	Rscript hcc4a.R repudns enqrs
	mv all.Rout hcc4a.Rout
	unix2dos hcc4a.Rout


## check target

check:: xncas3.csv

xncas3.csv: hcc5.csv
	Rscript hcc5t.R $(S_FILE) hcc5.csv # S_FILE isn't used.

clean::
	$(SHELL) -c "rm -f *.jpeg *.zip Rplots.pdf hcc?.dat hcc00.dat hcc?.Rout hcc?.csv"
