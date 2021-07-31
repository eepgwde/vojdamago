## weaves

TOP = ..

include defs.mk

all:: $(X_DEST) $(X_TARGETS) 

$(X_DEST):
	if ! test -d $(X_DEST); then mkdir $(X_DEST); fi

## Load the database
## TODO Some names could be simplified and use a rule

$(X_DEST)/cwy: cwyinventory.load.q $(X_BASE)/in/CWY-inventory.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/fwy: fwyinventory.load.q $(X_BASE)/in/FWY-inventory.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/rcia: rcia.load.q $(X_BASE)/in/RCI-A.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/rcib: rcia.load.q $(X_BASE)/in/RCI-BC.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/dfct: defects.load.q $(X_BASE)/in/defects.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/enq: cwyenquiries.load.q $(X_BASE)/in/CWY-enquiries.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

# An oddity uses cwy
$(X_DEST)/fwyenq0: cwyenquiries.load.q $(X_BASE)/in/fwyenq0.csv
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/clm: claims.load.q $(X_BASE)/in/claims.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/clm0: claims0.load.q $(X_BASE)/in/claims0.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/fci: fcia.load.q $(X_BASE)/in/fcia.csv 
	Qp $+ -bl -bs -savedb $(X_DEST) -savename $(notdir $@) -exit

## Rule-based: CSV file name is same as database
## X_EXTS2

## These are quite uniform, but can't define a rule because it would clash
## with the above

define LOAD_template =
$(X_DEST)/$(1): $(1).load.q $(X_BASE)/in/$(1).csv 
	Qp $(1).load.q $(X_BASE)/in/$(1).csv -bl -bs -savedb $(X_DEST) -savename $(notdir $(1)) -exit
endef

## TODO
## Can use a file loader for some

X_LDS0 = $(X_EXTS2) $(X_EXTS3)
X_LDS1 = workscwy0 workscwy2 weather luton fwyenq0
X_LDS2 = $(filter-out $(X_LDS1), $(X_LDS0))

$(foreach file0,$(X_LDS2), $(eval $(call LOAD_template,$(file0))))

## Externals

## So small don't need a directory

$(X_DEST)/workscwy0: workscwy0.load.q $(X_BASE)/in/workscwy0.csv 
	Qp $+ -af -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/workscwy2: workscwy2.load.q $(X_BASE)/in/workscwy2.csv 
	Qp $+ -af -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/weather: weather.load.q $(X_BASE)/in/weather.csv 
	Qp $+ -af -savedb $(X_DEST) -savename $(notdir $@) -exit

$(X_DEST)/luton: luton.load.q $(X_BASE)/in/luton.csv
	Qp $+ -af -savedb $(X_DEST) -savename $(notdir $@) -exit


clean::
	rm -rf $(X_DEST)
