## weaves
##
## Machine learning: GBM fit 
##
## Loads data from named file

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

library(MASS)
library(caret)
library(mlbench)
library(pROC)
library(gbm)

library(doMC)
registerDoMC(cores = 4)

options(useFancyQuotes = FALSE) 

## Load my functions

args = commandArgs(trailingOnly=TRUE)

## Load some data - we load from (TARGET)-3.dat
## ppl1 is scaled and centred. We decide what NZV to remove and go on
## to remove high correlations.

tgt0 <- "xroadsc-5.dat"                           # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

cls0 <- unlist(strsplit(tgt0, "\\."), use.names=TRUE)
scls0 <- paste(c(cls0[1], "ml-"), collapse="-")

load(tgt0, envir=.GlobalEnv)

dim(ppl1)

ppl00 <- ppl1                           # backup

set.seed(br0[["seed"]])                 # helpful for testing

ppl00 <- ppl1

print(sprintf("source: %s", br0[["source"]]))

## Sanity check - make sure we have the right length of outcomes.
stopifnot( length(ppl1[[ br0[["outcomen"]] ]]) == length(br0[["outcomes"]]))

## Remove the outcome from the dataset          
if (any(colnames(ppl1) == br0[["outcomen"]])) {
    ppl1[[ br0[["outcomen"]] ]] <- NULL
}

df <- ppl1

## Partitioning
## Because we are use GBM in classification mode, we have to use
## the outcome as a separate list (no formula). br0[["outcomes"]] contains them.

set.seed(br0[["seed"]])

inTrain <- createDataPartition(br0[["outcomes"]], p = 0.77, list = FALSE)

trainDescr <- df[inTrain,]
testDescr <- df[-inTrain,]

trainClass <- br0[["outcomes"]][ inTrain ]
testClass <- br0[["outcomes"]][ -inTrain ]

prop.table(table(trainClass))
dim(trainDescr)

prop.table(table(testClass))
dim(testDescr)

## Grid

fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 5,
    ## repeated a few times
    repeats = 5,
    summaryFunction = twoClassSummary,
    classProbs = TRUE)

## Some trial and error

gbmGrid <- expand.grid(interaction.depth = c(1, 2, 3),
                       n.trees = (1:20)*10,
                       shrinkage = 0.1,
                       n.minobsinnode = 20)

set.seed(br0[["seed"]])
gbmFit1 <- train(trainDescr, trainClass,
                 method = "gbm",
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 metric = "Kappa",
                 tuneGrid = gbmGrid,
                 verbose = FALSE)
gbmFit1

## For charting, set fit1, backup br00, call br7a.R

fit1 <- gbmFit1

source("br7a.R", verbose=TRUE)

br0[["confusion.train"]]

br0[["confusion.test"]]

save(br0, fit1, fitControl, gbmGrid, ppl1, ppl0, file="ppl7.dat")
