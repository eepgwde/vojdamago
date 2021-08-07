## weaves
##
## H??? County Council: samples1 

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

## Load some data

tgt0 <- "xroadsc"                       # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

## A display string, not used here.
cls0 <- "cwy3-fworks"
cls0 <- unlist(strsplit(cls0, "-"), use.names=TRUE)
scls0 <- paste(c(tgt0, cls0), collapse="-")

if (length(args) >= 2) {
    cls0 <- unlist(strsplit(args[2], "-"), use.names=TRUE)
    scls0 <- paste(c(tgt0, cls0), collapse="-")
}

load("ppl0.dat", envir=.GlobalEnv)

ppl0 <- get(tgt0)                        # get indirectly
dim(ppl0)                                

br0[["tgt0"]] <- tgt0

ppl00 <- ppl0                            # backup

set.seed(br0[["seed"]])                 # helpful for testing

## Remove the prescient variable

drops <- unlist(br0["prescient"], recursive = TRUE)
ppl <- ppl0[ , !(colnames(ppl0) %in% drops)]

## check for nulls

nulls.df(ppl)

## Centering, scaling and imputing

## This uses a general script. It drops columns. The stop conditions
## tests if we have accidentally dropped some rows.

## Function in a script: pass df0 and receive df1
## Near-zero variables

factor.numeric <- function(d) 
    modifyList(d, lapply(d[, sapply(d, is.factor)], as.integer))

logical.numeric <- function(d) 
    modifyList(d, lapply(d[, sapply(d, is.logical)], as.integer))

df0 <- factor.numeric(ppl)
df0 <- logical.numeric(df0)

source("br3a.R")

nulls.df(df1)

## This is now scaled and centred.
ppl1 <- df1

nzv0 <- br0[["nzv"]]

br0[["nzv"]] <- nzv0[order(-nzv0$zeroVar, -nzv0$nzv), ]

br0[["nzv.names"]] <- colnames(df1)[nzv0$nzv]

br0[["groups"]] <- c("cwy0", "cwy1", "poi", "bworks", "fworks", "weather", "lsoa")

## NZV by group
br0[["nzv.names"]] <- sapply(br0[["groups"]], function(x) intersect(br0[["nzv.names"]], br0[[x]]), USE.NAMES=TRUE)

## Size of group
x1 <-  sapply(names(br0[["nzv.names"]]), function(x) length(br0[[x]]), USE.NAMES=TRUE)

## Size of nzv group
x2 <-  sapply(names(br0[["nzv.names"]]), function(x) length(br0[["nzv.names"]][[x]]), USE.NAMES=TRUE)

x0 <- as.data.frame(cbind(x1, x2))
colnames(x0) <- c("N", "NZV")

br0[["nzv.summary"]] <- x0

## Save imputed values for loading back into the database
if (any(names(br0) == "imputes")) {
    save(br0, ppl0, df1, df0, file="impute0.dat")
}

x0

save(ppl0, ppl1, br0, file="ppl3.dat")

