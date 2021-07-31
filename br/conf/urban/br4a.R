## weaves
##
## NZV to remove
## Can be called either at data-prep or before correlation

## NZV in br0

## Inspect the original source data.

## ppl0 is the source data
## br0 has nzv from earlier stages.

## Mark the ppl1 in the field rm0 to be removed.

x0 <- aggregate(ppl0[, "surftype"], list(surftype=ppl0$surftype), FUN=length)
x0 <- as.character(x0[ order(-x0$x),][1,"surftype"])

## Mark ones to remove.
x.rremove <- rownames(ppl0)[ppl0$surftype != x0]

## Flag for removal.

x.cremove <- c("lanes2", "isshared", "surftype", "isdual", "isurban")
x.cremove <- append(x.cremove, br0[["nzv.names"]]$cwy1)
x.cremove <- append(x.cremove, "a0Xisshared")

## Remove prescient variables
source("br4a0.R") 

## The forward and backward works are NZV, but I'll leave them in.

## The PoI are also NZV, but I'll leave them in.
