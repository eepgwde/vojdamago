## weaves
##
## Machine learning: post-processing
##
## Load data from named file

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

options(useFancyQuotes = FALSE) 

## Load my functions

args = commandArgs(trailingOnly=TRUE)

## Load some data - from previous fit in br7.R use its seeds for SMOTE.

tgt0 <- "xroadsc-7.dat"                           # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

cls0 <- unlist(strsplit(tgt0, "\\."), use.names=TRUE)
scls0 <- paste(c(cls0[1], "pp-"), collapse="-")

load(tgt0, envir=.GlobalEnv)

## data
stopifnot(exists("br0"))

print(sprintf("source: %s", br0[["source"]]))

dim(ppl1)

## This is the scaled version
ppl01 <- ppl1                           # backup

set.seed(br0[["seed"]])                 # helpful for testing

## This is unscaled, the number of rows might not match.
ppl00 <- ppl0

## Sanity check - make sure we have the right length of outcomes.
stopifnot( dim(ppl1)[1] == length(br0[["outcomes"]]))

df <- ppl1

## Things to do.

## Compare predicted true records

trn0 <- br0[["train.results"]]
trn0$type0 <- "train"
tst0 <- br0[["test.results"]]
tst0$type0 <- "test"

uni0 <- rbind(trn0, tst0)

uni0$type0 <- factor(uni0$type0)

## Check the actual is correct
uni0$actual0 <- factor(uni0[[ br0[["outcomen"]] ]], labels=c("noclaim", "claim"))

stopifnot(all(uni0$actual0 == uni0$actual))

uni0$actual0 <- NULL
uni0$src0 <- br0[["source"]]

uni1 <- uni0[, c("outcome1", "predicted", "actual", "src0", "type0")]
uni1$smpl0 <- rownames(uni1)

x.ctr <- 1
x.flnm <- sprintf("%s%03d%s", scls0, x.ctr, ".csv")

## Prepare records to be read back into database for geo-location work.

write.csv(uni1, file=x.flnm, row.names=FALSE)

## A confusion matrix

tptn <- uni0[ uni0$predicted == uni0$actual, c("outcome1", "predicted", "actual") ]

with(tptn, table(predicted, actual))

fpfn <- uni0[ uni0$predicted != uni0$actual, c("outcome1", "predicted", "actual") ]

with(fpfn, table(predicted, actual))

head(rownames(fpfn))

with(fpfn[ fpfn$predicted == "claim", ], table(outcome1, predicted))

## Generate a set of variables for recursive partition tree analysis

v0 <- br0[["model.importance"]]$importance

v0 <- v0[ order(-v0$Overall), , drop=FALSE ]
v0$var0 <- rownames(v0)

x.ctr <- x.ctr + 1
x.flnm <- sprintf("%s%03d%s", scls0, x.ctr, ".csv")

write.csv(v0, file=x.flnm, row.names=FALSE)


## Generate input for an RPart Tree.

## This is the set of variables to partition on.
## Get rid of the zero importance
v1 <- v0[ v0$Overall > 0, ]
s0 <- summary(v1$Overall)

m0 <- s0[["1st Qu."]]
v1 <- v1[ v1$Overall > m0, ]

br0[["modelq1"]] <- rownames(v1)

m0 <- s0[["Median"]]
v1 <- v1[ v1$Overall > m0, ]
br0[["modelmdn"]] <- rownames(v1)

m0 <- s0[["Mean"]]
v1 <- v1[ v1$Overall > m0, ]
br0[["modelmn"]] <- rownames(v1)

m0 <- s0[["3rd Qu."]]
v1 <- v1[ v1$Overall > m0, ]
br0[["modelq3"]] <- rownames(v1)


br0[["outcomen"]] <- "actual"

uni0[[ br0[["outcomen"]] ]] <- uni0[[ br0[["outcomen"]] ]] == br0[["outcomen0"]]

save(br0, uni0, file="hcc2.dat")
