## weaves
##
## Make the derivative tables

## Do we or don't we have imputed values from R.
## Assume that we do. And they are a CSV file in cache/in

## I copied out/ximputes0.csv to in/imputes0.csv
## and it is loaded as imputes0 by ldr.mk

## A new imputes can be loaded as imputes2. It overwrites imputes1 and
## the bldr stage has to re-run

TOP = ..

include $(TOP)/ldr/defs.mk

## The $(PWD) is from the parent make in the directory above.
xPWD := $(shell pwd)

## Make derivative tables
X_DERIVS ?= rci1 rci1rag ftre cwy0 enq1 clm1 traffic1 traffic2 weather1 lsoa2ward salting1 salting2 lsoa1 imd2ward imd1 pop1 pop1w cars1 cars1w permit1 permit2 poi1 usrn2aid dfct1 dfct2 cwy2 dfctcwy1 wrk1 imputes1

## TODO dfct1 samples1 

X_DERIVS1 = $(addprefix $(X_DEST)/, $(X_DERIVS) )

all:: all-local $(X_DERIVS1)

install-local: $(addprefix $(X_DEST)/, imputes2)

## Install references
## Also we have the imputes - these are now in the archive and can be used in
## the first pass. 

X_CSVS = $(wildcard *.csv)
X_CSVS1 = $(addprefix $(X_BASE)/in/, $(X_CSVS))

view2:
	echo $(xPWD)
	echo $(X_CSVS)
	echo $(X_CSVS1)

X_SUPPORT = $(X_DEST)/hcc.q $(X_CSVS1)

all-local: $(X_DEST)/hcc.q $(X_CSVS1)

$(X_DEST)/hcc.q: hcc.q
	if ! test -L $@; then cd $(X_DEST); ln -s $(xPWD)/hcc.q .; fi

$(X_BASE)/in/%.csv: %.csv
	if ! test -L $@; then cd $(X_BASE)/in; ln -s $(xPWD)/$< . ; fi

## Write to a serialized table files in csvdb

## rci1 and cwy0 are the main tables.

$(X_DEST)/usrn2aid $(X_DEST)/cwy0: cwy1.q $(X_DEST)/cwy $(X_BASE)/in/speeds.csv $(X_BASE)/in/mtraffic.csv
	Qp -load "$(X_DEST) cwy1.q"

$(X_DEST)/rci1 $(X_DEST)/rci1rag: rci1.q $(X_DEST)/rcia $(X_DEST)/rcib $(X_DEST)/cwy0 $(X_DEST)/usrn2aid $(X_DEST)/cwy0
	Qp -load "$(X_DEST) rci1.q"

$(X_DEST)/weather1 $(X_DEST)/luton1: weather1.q $(X_DEST)/weather $(X_DEST)/luton
	Qp -load "$(X_DEST) weather1.q"

$(X_DEST)/fwy0 $(X_DEST)/ftre: ftre.q $(X_DEST)/cwy0 $(X_DEST)/fwy
	Qp -load "$(X_DEST) ftre.q"

$(X_DEST)/fwyenq1 $(X_DEST)/enq1: enq1.q $(X_DEST)/cwy0 $(X_DEST)/ftre 
	Qp -load "$(X_DEST) enq1.q"

$(X_DEST)/dfct2 $(X_DEST)/dfct1 : dfct1.q dfct1a.q dfct1b.q hcc.q $(X_DEST)/dfct $(X_DEST)/ftre 
	Qp -load "$(X_DEST) dfct1.q"

$(X_DEST)/traffic2 $(X_DEST)/traffic1 : traffic1.q $(X_DEST)/traffic0 $(X_DEST)/ftre 
	Qp -load "$(X_DEST) traffic1.q"

$(X_DEST)/salting2 $(X_DEST)/salting1 : salting1.q $(X_DEST)/salting $(X_DEST)/ftre 
	Qp -load "$(X_DEST) salting1.q"

$(X_DEST)/lsoa2ward $(X_DEST)/lsoa1: lsoa1.q $(X_DEST)/fwylsoa $(X_DEST)/cwylsoa $(X_DEST)/ftre 
	Qp -load "$(X_DEST) lsoa1.q"

$(X_DEST)/imd2ward $(X_DEST)/imd1: imd1.q $(X_DEST)/imd $(X_DEST)/ftre $(X_DEST)/lsoa1 $(X_DEST)/lsoa2ward
	Qp -load "$(X_DEST) imd1.q"

$(X_DEST)/pop1w $(X_DEST)/pop1: pop1.q $(X_DEST)/pop $(X_DEST)/ftre $(X_DEST)/lsoa1 $(X_DEST)/lsoa2ward
	Qp -load "$(X_DEST) pop1.q"

$(X_DEST)/cars1w $(X_DEST)/cars1: cars1.q $(X_DEST)/cars $(X_DEST)/lsoa1 $(X_DEST)/lsoa2ward $(X_DEST)/tcars
	Qp -load "$(X_DEST) cars1.q"

$(X_DEST)/permit2 $(X_DEST)/permit1: permit1.q $(X_DEST)/permits ptype.csv $(X_DEST)/usrn2aid
	Qp -load "$(X_DEST) permit1.q"

$(X_DEST)/clm1 : clm1.q $(X_DEST)/clm $(X_DEST)/ftre $(X_DEST)/permit2
	Qp -load "$(X_DEST) clm1.q"

$(X_DEST)/poi1 : poi1.q $(X_DEST)/poi $(X_DEST)/ftre $(X_DEST)/cwy0 
	Qp -load "$(X_DEST) poi1.q"

$(X_DEST)/cwy2: cwy2.q $(X_DEST)/cwy0 $(X_DEST)/usrn2aid $(X_DEST)/lsoa2ward $(X_DEST)/imd1 $(X_DEST)/cars1 $(X_DEST)/cars1w
	Qp -load "$(X_DEST) cwy2.q"


$(X_DEST)/dfctcwy1: dfctcwy1.q $(X_DEST)/ftre 
	Qp -load "$(X_DEST) dfctcwy1.q"

$(X_DEST)/wrk1: wrk1.q $(X_DEST)/ftre $(X_DEST)/usrn2aid
	Qp -load "$(X_DEST) wrk1.q"

$(X_DEST)/imputes1: imputes1.q $(X_DEST/imputes0)
	Qp -load "$(X_DEST) imputes1.q"

$(X_DEST)/imputes2: imputes2.q 
	Qp -load "$(X_DEST) imputes2.q"

clean::
	rm -f $(X_SUPPORT)

clean::
	rm -f $(X_DERIVS1)

## $(SHELL) -c "rm -rf out/*"
