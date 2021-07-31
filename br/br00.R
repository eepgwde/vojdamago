## weaves
##
## Data simplification
## Herts Carriageways. Samples as git tag v1.5-samples1

## Get started with a load and save to binary.

x.args = commandArgs(trailingOnly=TRUE)

tgt0 <- "/misc/build/0/hcc/cache/out/xsamples1.csv"
if (length(x.args) >= 1) {
    tgt0 <- x.args[1]
}

br0 <- list()
br0[["source"]] <- tgt0

ppl00 <- read.csv(tgt0, 
                  stringsAsFactors=TRUE, strip.white=TRUE,
                  header=TRUE, na.strings=c(""))

## Do some data fixing here
## read.csv doesn't recognize booleans.
## I explicitly name them "is" so I can.

c0 <- colnames(ppl00)

idx <- grepl("^is.+", colnames(ppl00))

bools0 <- sapply(c0[idx], function(x) "logical" != class(ppl00[[ x ]]), USE.NAMES=TRUE)

x0 <- lapply(names(which(bools0)), function(x) { ppl00[[ x ]] <<- as.logical(ppl00[[x]]) } )

save(br0, ppl00, file="ppl00.dat")




