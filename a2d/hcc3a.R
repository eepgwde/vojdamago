## weaves
##
## Correlations and cut-off
## Takes data0 read-only
## Writes hcc0
## Sorted list of primary correlations. Note, the use of abs
## correlation matrix in hcc0 corr for later charting

## pass df1 <- data0[, colnames(data0) %in% c(types, wthrs, dts, dtypes, dwthrs) ]

## Look for near-zero vars

## First centre and scale and record NZV

method0 <- c("center", "scale")

freqCut0 = 4                            # if greater prune
unique0 = 25                            # if less prune

ml1.imputer <- preProcess(df1, verbose = TRUE, na.remove = TRUE, 
                          method=method0)
df2 <- predict(ml1.imputer, df1)
### Near zero-vars and correlations
## PCA would find these, but for this iteration, we want to validate
## If any at all possible.
nzv0 <- nearZeroVar(df2, saveMetrics = TRUE, allowParallel=TRUE, 
                    freqCut =freqCut0, 
                    uniqueCut=unique0)
hcc0[["nzv"]] <- nzv0
nzv0 <- with(nzv0, nzv0[ order(freqRatio, percentUnique),])
nzv0

nnzv0 <- rownames(nzv0[ !(nzv0$zeroVar | nzv0$nzv), ])

corr1 <- cor(as.matrix(df1[, colnames(df1) %in% nnzv0]))

corrplot::corrplot(corr1, method="number", order="hclust")

## Just the high relative to the target

x0 <- corr1[, hcc0[["outcomen"]] ]

x0 <- abs(corr1[ names(x0), hcc0[["outcomen"]] ])

x0 <- sort(x0, decreasing=TRUE)

## The outcome will be the first so discard it.
x0 <- tail(names(x0), -1)

hcc0[["corr.high1"]] <- setdiff(x0, hcc0[["nzv.vars"]])

hcc0[["corr"]] <- corr1
