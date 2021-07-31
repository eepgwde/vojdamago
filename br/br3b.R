## weaves
##
## Machine learning preparation: common
##
## This script is a sub-script and finds the Near-Zero Variance
## and highly correlated variables.

library("ipred")

## Do we need to use statistical imputation?
## bagImpute takes ages

## It's imputed and behaves well, no need for this.
## descrCorr <- cor(scale(trainDescr), use = "pairwise.complete.obs")

nulls.df(df1)

descrCorr <- cor(df1)

## This cut-off should be under src.adjust control.
## There should be many of these. Because all derived from r00.
highCorr <- findCorrelation(descrCorr, cutoff = .75, verbose = FALSE)

br0[["highCorr"]] <- colnames(df1)[highCorr]

br0[["descrCorr"]] <- descrCorr
