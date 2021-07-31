## weaves
##
## Herts County Council: samples1 

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

tgt0 <- "xroadsc-3.dat"                           # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

cls0 <- unlist(strsplit(tgt0, "\\."), use.names=TRUE)
scls0 <- paste(c(cls0[1], "corr"), collapse="-")

load(tgt0, envir=.GlobalEnv)

dim(ppl1)                                

ppl00 <- ppl1                            # backup

## Remove NZVs
## And records that might hold their type, eg. surftype.

source("br4a.R")

## Drop columns and rows.
ppl1 <- ppl1[ ! rownames(ppl1) %in% x.rremove, ! colnames(ppl1) %in% x.cremove ]

## From ppl0, do the same but take a snapshot of our outcomes
## Do not sort or delete rows from ppl1 from here.
## Note: I leave it in to spot prescient variables.
br0[["outcomes"]] <- ppl0[ ! rownames(ppl0) %in% x.rremove, br0[["outcomen"]] ]

## We convert it to a factor so we can use the classification features of models.
br0[["outcomes"]] <- factor(br0[["outcomes"]], labels=c("noclaim", "claim"))

colnames(ppl1)

set.seed(br0[["seed"]])                     # helpful for testing

## Same process for correlations now

df0 <- ppl0[ rownames(ppl1),]

df1 <- ppl1

source("br3b.R")

## we now have df1 scaled and centered

source("br4b.R")

save(ppl1, ppl0, br0, file="ppl4.dat")

