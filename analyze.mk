## weaves
##
## Top-level makefile

define GOAL_template =
$(3):: 
	$(MAKE) MAKEFLAGS="$(MAKEFLAGS)" -C $(2) -f $(2).mk $(1)
endef

## Set up the links to the remote data.

all:: all-local

all-local:: dirs1 

dirs1::
	test -d cache/bak
	test -d cache/out
	test -d cache/in

## Install my links.

all:: dirs1

SUBDIRS = rp e2c a2d br 
RSUBDIRS = $(shell echo $(SUBDIRS) | xargs -n1 | tac | xargs)

## all and clean
## convert, load, then make derivatives, and samples

$(foreach x0,$(SUBDIRS), $(eval $(call GOAL_template,all,$(x0),all)))

$(foreach x0,$(RSUBDIRS), $(eval $(call GOAL_template,clean,$(x0),clean)))


## install and uninstall
## load, then make derivatives, and samples and reports

$(foreach x0,$(filter-out trns, $(SUBDIRS)), $(eval $(call GOAL_template,all,$(x0),install)))

$(foreach x0,$(filter-out trns, $(RSUBDIRS)), $(eval $(call GOAL_template,clean,$(x0),uninstall)))


$(foreach x0,$(lastword $(SUBDIRS)), $(eval $(call GOAL_template,install,$(x0),install)))

$(foreach x0,$(firstword $(RSUBDIRS)), $(eval $(call GOAL_template,clean,$(x0),uninstall)))

view3:
	echo $(lastword $(SUBDIRS))


## dist
## generate final CSV files

$(foreach x0,bldr, $(eval $(call GOAL_template,install,$(x0),dist)))
