## weaves
##
## Machine learning preparation: common
##
## This script is a sub-script and finds the Near-Zero Variance
## Store results in ml0 list.

library("ipred")

## First centre and scale and record NZV

method0 <- c("center", "scale")

ml1.imputer <- preProcess(df0, verbose = TRUE, na.remove = TRUE, 
                          method=method0)

## Transform
df1 <- predict(ml1.imputer, df0)

### Near zero-vars and correlations
## PCA would find these, but for this iteration, we want to validate
## If any at all possible.

nzv0 <- nearZeroVar(df1, saveMetrics = TRUE, allowParallel=TRUE, freqCut =95/5, uniqueCut=10)

br0[["nzv"]] <- nzv0


## Do we need to use statistical imputation?
## bagImpute takes ages

nulls0 <- nulls.df(df0)

if (dim(nulls0)[1] > 0) {

    method0 <- "knnImpute"

    ## Now impute, allow it to remove zv and nzv

    method0 <- append(c("zv", "nzv"), method0)

    ## Center, scale, remove any NA using nearest neighbours.
    ## PCA as "pca" is useful here. Their defaults are as good as any I come up with.
    ml1.imputer <- preProcess(df0, verbose = TRUE, na.remove = TRUE, 
                              method=method0, knnSummary = median)

    ## Apply the imputations.
    df2 <- predict(ml1.imputer, df0)

    ## And put the NZV columns back in

    c0 <- setdiff(colnames(df1), colnames(df2))

    df1 <- cbind(df2, df1[, c0])

    br0[["imputes"]] <- "impute0.dat"

}


## clean up

rm(nzv0)

