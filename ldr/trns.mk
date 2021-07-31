## weaves

TOP ?= ..

include defs.mk

## Make the target directory - needed early on for paths

all:: $(X_DEST)

$(X_DEST):
	if ! test -d $(X_DEST); then mkdir $(X_DEST); fi


## Odd Source files

all:: $(X_SRCS)

# sources for X_EXTS1 and X_EXTS0

X_CSVS0 ?= fcia CWY-inventory FWY-inventory CWY-enquiries RCI-A RCI-BC defects claims $(X_EXTS0)

# X_EXTS3 - pre-process a CSV or XLS
X_CSVS1 ?= $(addprefix $(X_BASE)/in/, $(addsuffix .csv, $(X_CSVS0)))

# X_EXTS2 - copy CSV
X_CSVS2 = $(addprefix $(X_BASE)/in/, $(addsuffix .csv, $(X_EXTS2)))

# X_EXTS3 - pre-process a CSV or XLS
X_CSVS3 = $(addprefix $(X_BASE)/in/, $(addsuffix .csv, $(X_EXTS3)))

view::
	@echo X_CSVS0 : $(X_CSVS0)
	@echo X_CSVS1 : $(X_CSVS1)
	@echo X_CSVS2 : $(X_CSVS2)
	@echo X_CSVS3 : $(X_CSVS3)

all:: $(X_CSVS2) 

define GOAL_template =
$(X_BASE)/in/$(1): $(X_BASE)/bak/$(1)
	cp $(X_BASE)/bak/$(1) $(X_BASE)/in/$(1)
endef

# These are already CSV

$(X_BASE)/in/traffic0.csv : $(X_BASE)/bak/abc-0.csv
	cp $< $@

# Straight copies

$(foreach file0,$(notdir $(X_CSVS2)), $(eval $(call GOAL_template,$(file0))))


all:: $(X_CSVS1) $(X_CSVS3)

## External data

all-weather: $(X_BASE)/in/weather.csv $(X_BASE)/in/luton.csv

$(X_BASE)/in/weather.txt:
	wget --quiet -O $@ https://www.metoffice.gov.uk/pub/data/weather/uk/climate/stationdata/cambridgedata.txt
	cp $@ bak
	dos2unix $@
	sed -i '1,5d' $@
	sed -i '2d' $@

$(X_BASE)/in/weather.csv: $(X_BASE)/in/weather.txt
	cat $+ | $(H_) 2csv weather $+ | $(H_) 2csv weather0 > $@

$(X_BASE)/in/luton.csv: $(X_BASE)/bak/luton.csv
	cat $+ | $(H_) 2csv luton > $@

$(X_BASE)/in/workscwy0.csv: $(X_BASE)/bak/workscwy0.csv
	cat $+ | $(H_) 2csv works1  > $@

$(X_BASE)/in/dfctcwy.csv: $(X_BASE)/bak/dfctcwy.csv
	cat $+ | $(H_) 2csv dfctcwy  > $@

$(X_BASE)/in/workscwy2.csv: $(X_BASE)/bak/workscwy2.csv
	cat $+ | $(H_) 2csv works1 > $@

## Pre-process the XLS files, fix any date issues and render as CSV.

$(X_BASE)/in/fcia.csv: $(X_BASE)/bak/RCI-fwy.xlsx
	fcia.py $+ $@

$(X_BASE)/in/CWY-inventory.csv: $(X_BASE)/bak/CWY-inventory.xlsx
	2csv.py $+ $@

$(X_BASE)/in/FWY-inventory.csv: $(X_BASE)/bak/FWY-inventory.xlsx
	2csv.py $+ $@

$(X_BASE)/in/CWY-enquiries.csv: enq.py $(X_BASE)/bak/cwy-enquiries.xlsx
	$+ $@

# Lost file
# $(X_BASE)/in/fwyenq0.csv : enq.py $(X_BASE)/bak/fwyenq0.xlsx
#	$+ $@

# sheet 1 is sheet 0
$(X_BASE)/in/RCI-A.csv: $(X_BASE)/bak/RCI.xlsx
	rci.py $+ $@ 0

# sheet 2 is sheet 1
$(X_BASE)/in/RCI-BC.csv: $(X_BASE)/bak/RCI.xlsx
	rci.py $+ $@ 1

# This one is annoying. A couple of the integer fields are coming
# through as floats. Fix it dfct1
$(X_BASE)/in/defects.csv: $(X_BASE)/bak/defects.xlsx
	dfct.py $+ $@

# This is an XLS
$(X_BASE)/in/claims.csv : $(X_BASE)/bak/claims.xls
	clm.py $+ $@

# This is an XLS
$(X_BASE)/in/salting.csv : $(X_BASE)/bak/salting.xls
	2csv.py $+ $@

# No loader for these very simple.

$(X_BASE)/in/speeds.csv : $(X_BASE)/bak/speeds.xlsx
	2csv.py $+ $@

$(X_BASE)/in/mtraffic.csv : $(X_BASE)/bak/mtraffic.xlsx
	2csv.py $+ $@

## permits is 5 files.

X_PERMS = $(wildcard $(X_BASE)/bak/permits*.xlsx)
X_PERMS0 = $(addprefix $(X_BASE)/in/, $(addsuffix .csv, $(basename $(notdir $(X_PERMS)))))

$(X_BASE)/in/permits%.csv: $(X_BASE)/bak/permits%.xlsx
	permit.py $+ $@

permits0: $(X_PERMS0)

$(X_BASE)/in/permits.csv : $(sort $(X_PERMS0))
	cat $(firstword $+) > $@
	for i in $(wordlist 2, $(words $+), $+); do sed '1d' $$i; done >> $@

# and this is big and has odd headers and all the ints are 1.0 or similar
# forcing real, when short would do.

$(X_BASE)/in/poi.csv: $(X_BASE)/bak/poi.csv
	cat $< | sed '1!b;s/</lt/g' | sed 's/\.0,/,/g' > $@

## Re-use earlier data.

$(X_BASE)/in/claims0.csv : $(X_BASE)/bak/claims0.xlsx
	clm0.py $+ $@

clean::
	$(SHELL) -c "rm -rf $(X_BASE)/in/*"
