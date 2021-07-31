## weaves
##
## Machine learning: RF fit
##
## Load data from named file

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

library(MASS)
library(ranger)
library(caret)
library(mlbench)
library(foreach)
library(pROC)
library(DMwR) # for smote implementation

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

## Sanity check - make sure we have the right length of outcomes.
stopifnot( length(ppl1[[ br0[["outcomen"]] ]]) == length(br0[["outcomes"]]))

## Remove the outcome from the dataset          
if (any(colnames(ppl1) == br0[["outcomen"]])) {
    ppl1[[ br0[["outcomen"]] ]] <- NULL
}

df <- ppl1

## Partitioning
## We now use a Random Forest - rf parRF and ranger

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
## This does not work - mtry not recognised issue.

rfGrid <- expand.grid(.mtry=50, ntree = 1000, sampsize =90000, 
                      nodesize = 1, importance = TRUE, 
                      nPerm =2, oob.prox = TRUE)

## Create model with default paramters

control <- trainControl(
    method="repeatedcv", number=10, repeats=3,
    summaryFunction = twoClassSummary, classProbs=TRUE )

## Add upsampling or smote

control$sampling <- "up"
control$sampling <- "smote"

## Very, very slow - make sure you have PCAs in there.
x.ntrees <- 500
mtry.max <- floor(sqrt(length(colnames(trainDescr))))

## For testing - and for bad data.
x.ntrees <- 100
mtry.max <- 5

metric <- "ROC"
mtry <- 2:mtry.max
tunegrid <- expand.grid(.mtry=mtry)


set.seed(br0[["seed"]])

rfFit1 <- train(trainDescr, trainClass,
                method = "ranger",
                tuneGrid = tunegrid,
                trControl = control,
                metric = metric,
                num.trees = x.ntrees, importance = "permutation",
                verbose = FALSE)
rfFit1

fit1 <- rfFit1

source("br7a.R", verbose = TRUE)

br0[["confusion.train"]]

br0[["confusion.test"]]

save(br0, fit1, ppl1, ppl0, file="ppl8.dat")
