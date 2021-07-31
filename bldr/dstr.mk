## weaves
##
## Make a zip

PWD0 := $(shell pwd)

ifeq ($(MAKECMDGOALS),dist-local)

dist-local: $(T_DIR)/xweaves.zip 

$(T_DIR)/xweaves.zip: $(wildcard out/x*.csv)
	rm -f $@
	zip $@ $+


endif

ifeq ($(MAKECMDGOALS),dist)

dist::
	@echo $(PWD0)

dist:: $(T_DIR)/README-xweaves.txt $(T_DIR)/xweaves.zip
	$(X_HOST0) m_ sftp put $+

dist:: $(PWD0)/out/xclmprmt0.csv $(PWD0)/out/xclmprmt1.csv $(PWD0)/out/xprmtrisk.csv
	$(X_HOST0) m_ -d /herts/data_derived/permits sftp put $+

endif


