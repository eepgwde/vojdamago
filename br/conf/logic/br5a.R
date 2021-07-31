## weaves
##
## Correlations to remove
## Can be called either at data-prep or before correlation

## Correlation names in br0

## br0 has nzv from earlier stages.


## Flag for removal.

## rh0 is highly correlated to pri and pri2 but not to isdist.
## mtraffic is highly correlated to rh0

x.cremove <- c("pri", "pri2", "area")

x.cremove <- append(x.cremove, 
                    c("a0Xpri2", "a0Xpri", "a0Xrh0", "a0Xdistance", 
                      "a0Xwidth", "a0Xarea" ))

## bworks and fworks

x.cremove <- append(x.cremove, c("prmtb90", "dfctinspctb30", "dfctinspctb90"))

x.cremove <- append(x.cremove, c("prmtf90", "dfctinspctf90", "dfctactionf90", 
                                 "dfctinspctf30"))

## weather - past doesn't help. Prefer tmin over tmax.

x.cremove <- append(x.cremove, c("sun0", "tmin0", "tmax0", "tmax"))

## LSOA

x.cremove <- append(x.cremove, 
                    c("imdk", "ncars00", "tcars0", "mage4", "mage00",
                      "fage00", "tage1", "fage0", "tage2", "fage3", "mage3", "ncars4"))



