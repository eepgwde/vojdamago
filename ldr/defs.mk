## weaves

# Date strings aren't consistent with csvguess.q

# Check format is MM/DD/YYYY HH:MM:SS 12/31/1999 08:45:00

# Load cwy fwy rci and others into a q/kdb database.

# The new claims clm has no feature id.
# The old one clm0 has a big overlap.

SHELL := /bin/bash

T_DIR ?= /cache/incoming/hcc

## Can be set by callers, we use 
TOP ?= $(shell if test -L $(PWD); then echo ../../../../.. ; else echo ..; fi)

## A helper script uses my m_ arrangement.
# H_ = $(TOP)/hcc_
H_ = $(TOP)/hcc

X_BASE ?= $(TOP)/cache
X_DEST ?= $(X_BASE)/csvdb

## Used for sftp - it can be: ssh n1 
X_HOST0 ?= 

## Different types of load

### Simple file load directly to master table and stored or mapped directly
X_EXTS0 ?= speeds mtraffic

### Special database load - no single corresponding CSV or weird name
X_EXTS1 ?= cwy fwy rcia rcib dfct enq clm 

### CSV is fine. But dfctcwy needs a gnumeric CSV save.
X_EXTS2 ?= cars pop income imd tcars fwylsoa cwylsoa 

### CSV needs prep
X_EXTS3 ?= poi workscwy0 workscwy2 dfctcwy weather permits luton traffic0 salting imputes0

# Lost: fwyenq0

X_TARGETS ?= $(addprefix $(X_DEST)/,$(X_EXTS1) $(X_EXTS2) $(X_EXTS3))

view::
	-@echo $(X_SRCS)
	-@echo $(X_TARGETS)
	-@echo $(H_)

distclean:: clean

