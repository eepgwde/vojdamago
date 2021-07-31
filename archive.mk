## weaves
# from the hcc.zip archive
# Some files are missing, but fortunately not important ones.

# This can be used to install the files as links to /cache/bak and then 
# the links can be reconstructed using top.mk:links1

X_FILES = links.lst links1.lst srcs.lst targets.lst targets1.lst targets2.lst

all: $(X_FILES)

SDIR=/home/build/1/archive

links.lst: archive/local/links.afio
	afio -tv archive/local/links.afio > $@

links1.lst: links.lst
	cut -c63- $< > $@

targets.lst: links1.lst
	sed 's/.* S-> \(.*\)$$/\1/g' $< > $@

srcs.lst: links1.lst
	sed 's/\(.*\) S-> .*$$/\1/g' $< > $@

targets1.lst: targets.lst
	sed -e 's,^/cache/incoming/,,g' $< > $@

targets2.lst: targets1.lst
	cat targets1.lst | while read i; do ls $(SDIR)/"$$i"; done


clean::
	$(RM) $(X_FILES)
