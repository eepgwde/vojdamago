## weaves
##
## Make the derivative tables

TOP = ..

include $(TOP)/ldr/defs.mk

## Output as CSV

all:: all-local 

$(X_BASE)/out:
	if ! test -d $@; then mkdir $@; fi

## Reports on datasets Configurations
## Not dependent on samples or many datasets

X_CNFS1 = dcover0 dcover1 rh0t pr0t prmtrisk clmprmt0 clmprmt1 usrn2aid cwy1 wrkdfct 
X_CNFS2 = $(addprefix x, $(addsuffix .csv, $(X_CNFS1)))
X_CNFS3 = $(addprefix $(X_BASE)/out/, $(X_CNFS2))

X_DNFS1 = wrkcwy1
X_DNFS2 = $(addprefix x, $(addsuffix .csv, $(X_DNFS1)))
X_DNFS3 = $(addprefix $(X_BASE)/out/, $(X_DNFS2))

all-local:: $(X_BASE)/out $(X_DEST)/wsdcover

$(X_CNFS3) $(X_DEST)/wsdcover: dcover0.q $(X_DEST)/cars $(X_DEST)/imd $(X_DEST)/lsoa2ward $(X_DEST)/tcars $(X_DEST)/pop1 $(X_DEST)/rci1 $(X_DEST)/rci1rag $(X_DEST)/cwy0 $(X_DEST)/poi1 $(X_DEST)/dfct2
	Qp -load "$(X_DEST) dcover0.q"

all-local:: $(X_DNFS3)

$(X_DNFS3): xwrkcwy1.q $(X_DEST)/wrk1 $(X_DEST)/dfctcwy1 $(X_DEST)/cwy0 $(X_DEST)/cwy2
	Qp -load "$(X_DEST) xwrkcwy1.q"


## Generate reports on existing samples1

X_OUTS1 = traffic0 
X_OUTS2 = $(addprefix x, $(addsuffix .csv, $(X_DERIVS) $(X_OUTS1)))
X_OUTS3 = $(addprefix $(X_BASE)/out/, $(X_OUTS2))

## Just reports
X_RPTS1 = dfctsample0 ncas1  dfctsample1 dfctstatus ncas1w weather0
X_RPTS2 = $(addprefix x, $(addsuffix .csv, $(X_RPTS1)))
X_RPTS3 = $(addprefix $(X_BASE)/out/, $(X_RPTS2))


## Make samples 

all:: $(X_DEST)/samples1


$(X_DEST)/samples1: samples1.q $(wildcard samples1?.q) $(X_DEST)/wsdcover 
	Qp -load "$(X_DEST) samples1.q"

clean::
	rm -f $(X_DEST)/samples1


## Make reports

install-local:: $(X_RPTS3)

view3:
	echo $(X_RPTS3)

$(X_RPTS3): tables0.q $(X_DEST)/wsdcover xncas1w.q
	Qp -load "$(X_DEST) tables0.q"

install-local-wrk1: xwrkcwy1.q $(X_DEST)/wsdcover
	Qp -load "$(X_DEST) xwrkcwy1.q"

install:: $(X_OUTS3) install-local

$(X_OUTS3): 2csv.q $(X_DEST)/samples1
	Qp -load "$(X_DEST) 2csv.q"

clean:: 
	$(SHELL) -c "rm -rf $(X_BASE)/out/*"

## Build Zip

dist-local:: $(T_DIR)/README-xweaves.txt $(T_DIR)/xweaves.zip

$(T_DIR)/xweaves.zip:
	$(MAKE) PATH=$(PATH)/.. MAKEFILES=../ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -C $(X_DEST)/.. -f $(PWD)/dstr.mk dist-local


$(T_DIR)/README-xweaves.txt: $(T_DIR)/xweaves.zip
	( cat README-xweaves ; unzip -l $< | sed '/Archive: /d' ) > $@


## Upload it

dist:: dist-local
	$(MAKE) PATH=$(PATH)/.. MAKEFILES=../ldr/defs.mk MAKEFLAGS="$(MAKEFLAGS)" -C $(X_DEST)/.. -f $(PWD)/dstr.mk dist


