## weaves
##
## Machine learning: GBM fit - second stage up/down/SMOTE
##
## Load data from named file

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

library(MASS)
library(caret)
library(mlbench)
library(pROC)
library(gbm)
library(DMwR) # for smote implementation

library(doMC)
registerDoMC(cores = 4)

options(useFancyQuotes = FALSE) 

## Load my functions

args = commandArgs(trailingOnly=TRUE)

## Load some data - from previous fit in br7.R use its seeds for SMOTE.

tgt0 <- "xroadsc-7.dat"                           # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

cls0 <- unlist(strsplit(tgt0, "\\."), use.names=TRUE)

load(tgt0, envir=.GlobalEnv)

## need a fit, fitControl and gbmGrid
stopifnot(exists("fit1"))

print(sprintf("source: %s", br0[["source"]]))

dim(ppl1)

ppl00 <- ppl1                           # backup

set.seed(br0[["seed"]])                 # helpful for testing

ppl00 <- ppl1

## Sanity check - make sure we have the right length of outcomes.
stopifnot( dim(ppl1)[1] == length(br0[["outcomes"]]))

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

## Some trial and error
## To start with use the one from the previous run.

if (1 == 0) {
    gbmGrid <- expand.grid(interaction.depth = c(1, 2, 3),
                           n.trees = (1:20)*10,
                           shrinkage = 0.1,
                           n.minobsinnode = 20)
}

## Finally add some SMOTE
fitControl$seeds <- fit1$control$seeds
fitControl$sampling <- "smote"
fitControl$sampling <- "down"
fitControl$sampling <- "up"

set.seed(br0[["seed"]])

gbmFit1 <- train(trainDescr, trainClass,
                 method = "gbm",
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 metric = "Accuracy",
                 tuneGrid = gbmGrid,
                 verbose = FALSE)
gbmFit1

## For charting, set fit1, backup br00, call br7a.R

fit1 <- gbmFit1

## Set the tag for output.
scls0 <- sprintf("%s-%s-", cls0[1], fitControl$sampling)

source("br7a.R", verbose=TRUE)

br0[["confusion.train"]]

br0[["confusion.test"]]

save(br0, fit1, fitControl, gbmGrid, ppl1, ppl0, file="ppl9.dat")
