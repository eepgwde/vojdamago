## weaves
##
## Herts County Council: samples1
## Remove over-correlated

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

library(MASS)
library(caret)

library(doMC)
registerDoMC(cores = 4)

options(useFancyQuotes = FALSE)

## Load my functions

source("../R/brA0.R")

args = commandArgs(trailingOnly=TRUE)

## Load some data - we load from (TARGET)-3.dat
## ppl1 is scaled and centred. We decide what NZV to remove and go on
## to remove high correlations.

tgt0 <- "xroadsc-4.dat"                           # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

cls0 <- unlist(strsplit(tgt0, "\\."), use.names=TRUE)
scls0 <- paste(c(cls0[1], "corr1"), collapse="-")

load(tgt0, envir=.GlobalEnv)

dim(ppl1)

ppl00 <- ppl1                            # backup

## Remove highly-correlated
## No records removed with this.

source("br5a.R")

ppl1 <- ppl1[, ! colnames(ppl1) %in% x.cremove ]

br0[["corr.xnames"]] <- x.cremove

colnames(ppl1)

br00 <- br0

df1 <- ppl1
source("br3b.R")

jpeg(filename=paste(scls0, "-%03d.jpeg", sep=""), 
     width=1024, height=768)

c0 <- br0[["highCorr"]]
corrplot::corrplot(br0[["descrCorr"]][ c0, c0 ], method="number", order="hclust")

dev.off()


br0 <- br00

save(ppl1, ppl0, br0, file="ppl5.dat")
