## weaves
##
## Following petolau
## https://github.com/PetoLau/petolau.github.io.git

## wear to days to next defect model days0
## wear1 - log depreciation curve using mtraffic
## wear3 - logit scaled tcars0; logit uses pri, iscls, lanes2, isurban, spdlimit
## tmin - average minimum temperature over period

rm(list=ls())
gc()

## Key library is mgcv

library(mgcv)
library(car)
library(ggplot2)
library(grid)
library(caret)

library(dplyr)
library(tidyr)

library(cluster)
library(lubridate)

## My personal library has an ewma in it and loads zoo.
library(Rweaves1)

source("../R/brA0.R")

if(length(commandArgs(trailingOnly=TRUE)) <= 0) {
    x.args <- c("hcc2.csv", "hcc3.csv")
}

source("hcc0a.R")

hcc3.data <- data0


## Use this to carry out configurations.
hcc0 <- list()

stopifnot(any(dts == "days0"))

## Just asset wear to defects

## Business logic
## Some are prescient or not available or expensive

hcc0[["x"]] <- "wear1"                    # we always give it this, effectively the time

hcc0[["dts"]] <- dts
hcc0[["outcomen"]] <- "days0"

hcc0[["prescient"]] <- c("ddays0", "dfcts")

hcc0[["corr.cutoff"]] <- 0.45           # not used

## Remove imputed values
## Only when we have defined dfcts1 does it correlate
## Re-calculate the weights
data0 <- subset(data0, (data0$dfcts1 > 1) & is.na(data0$impute0) & is.na(data0$impute1) )
wts0 <- hcc.wts(data0)
wts <- wts0[["flat"]]

x.data0 <- data0

## Key metrics: days0 and wear

p1 <- ggplot(data0, aes_string(hcc0[["outcomen"]])) + geom_histogram()

p2 <- ggplot(data0, aes_string("wear2", hcc0[["outcomen"]])) + geom_point()

p3 <- ggplot(data0, aes_string("wear3", hcc0[["outcomen"]])) + geom_point()

multiplot(p1, p2, p3)

## Key metrics: dfcts and wear

p1 <- ggplot(data0, aes(dfcts)) + geom_histogram()

p2 <- ggplot(data0, aes(x=wear2, y=dfcts)) + geom_point()

p3 <- ggplot(data0, aes(x=wear3, y=dfcts)) + geom_point()

## View three key metrics together
multiplot(p1, p2, p3)


## dfcts chart: collect some examples

y0 <- aggregate(dfcts ~ wrkid, data=data0, FUN=max)
y0 <- y0[ order(-y0$dfcts),]

wrkids <- head(y0$wrkid, n=5)

y0 <- aggregate(dfcts ~ wrkid, data=data0[ data0$pri <= 3 & data0$days0 >= 3000, ], FUN=max)
y0 <- y0[ order(-y0$dfcts),]

wrkids <- append(wrkids, head(y0$wrkid, n=2))
wrkids <- append(wrkids, tail(y0$wrkid, n=3))
hcc0[["egs"]] <- wrkids

x0 <- subset(data0, data0$wrkid %in% unique(wrkids), select=c("cwy0", "wrkid", hcc0[["outcomen"]], "dfcts") )

if(1==0) {

    grp0 <- "cwy0"

    b0 <- hist(data0$dfcts, breaks = "Sturges", plot =  FALSE)
    b0 <- c( b0$breaks[4], b0$breaks[(-2) + length(b0$breaks)] )

    x0 <- subset(data0, data0$dfcts >= b0[2], select=c("cwy0", "wrkid", "dfcts", hcc0[["outcomen"]]))
    x0 <- x0[ order(-x0$dfcts),]
    hcc0[["egs"]] <- head(unique(x0$wrkid))

    x1 <- subset(data0, data0$wrkid %in% head(unique(x0$wrkid)), select=c("cwy0", "wrkid", hcc0[["outcomen"]], "dfcts") )

    x0 <- subset(data0, data0$dfcts <= b0[1], select=c("cwy0", "wrkid", "dfcts", hcc0[["outcomen"]]))
    x0 <- x0[ order(-x0$dfcts),]
    hcc0[["egs"]] <- append(hcc0[["egs"]], tail(unique(x0$wrkid)))

    x2 <- subset(data0, data0$wrkid %in% head(unique(x0$wrkid)), select=c("cwy0", "wrkid", hcc0[["outcomen"]], "dfcts") )

    x0 <- rbind(x1,x2)
}

x.legend=TRUE

grp0 <- "cwy0"

c0 <- colnames(x0)
c0[which(c0 == grp0)] <- "grp0"
colnames(x0) <- c0

x0 <- x0[ order(x0$days0, x0$dfcts), ]

p0 <- ggplot(data = x0, aes(x=days0, y=dfcts, group=grp0, colour=grp0) ) +
    geom_line(size = 0.8, show.legend=x.legend) + 
    geom_point(aes(color=grp0), show.legend=x.legend) +
    theme_bw()


grp0 <- "wrkid"
c0 <- colnames(x0)
c0[which(c0 == grp0)] <- "grp0"
colnames(x0) <- c0

x0 <- subset(x.data0, select=c("cwy0", "wrkid", "dfcts", hcc0[["outcomen"]]))
x.legend=FALSE

c0 <- colnames(x0)
c0[which(c0 == grp0)] <- "grp0"
colnames(x0) <- c0

p1 <- ggplot(data = x0, aes(x=days0, y=dfcts, group=grp0, colour=grp0) ) +
    geom_line(size = 0.8, show.legend=x.legend) + 
    geom_point(aes(color=grp0), show.legend=x.legend) +
    theme_bw()

multiplot(p0, p1)                       # and plotted later to JPEG



## end: dfcts plot

## Find only primary highly correlated and note nzvs

c0 <- setdiff(c(types, wthrs, dts, ddts, types1, imputes0), hcc0[["prescient"]])

## Take only those that have a least one 
df1 <- data0[, c0]

source("hcc3a.R")


## Make features in hcc0[["features"]] applying business logic.
## This also removes NZV derived by hcc3a.R
hcc0 <- hcc.ftres1(hcc0)


## theory: GLM: Iteratively Re-weighted Least Squares (IRLS) theory:

## GAM: Penalized Iteratively Re-weighted Least Squares (P-IRLS)
##
## k -> ## (knots) is upper boundery for EDF
##
## how smooth fitted value will be (more knots more overfit (under
## smoothed), less more smooth)

## bs -> basis function..type of smoothing function
##
## dimension can be fixed by fx = TRUE EDF (trace of influence matrix)
## and lambda (smoothing factor) is estimated (tuned) by GCV, UBRE or REML.

## We will use the default GCV (Generalized Cross Validation) (more in
## Woods) basis function.

## I will use "cr" - cubic regression spline or "ps", which
## is P-spline (more in Woods).

## More options: "cc" cyclic cubic regression spline (good too with
## our problem), default is "tp" thin plane spline family.

## How response is fitted -> gaussian, log_norm, gamma, log_gamma is
## our possibilities, but gaussian is most variable in practice
## because gamma distibution must have only positive values gamm -
## possibility to add autocorrelation for errors

## Families and weights

family0 <- gaussian
family0 <- ziP                          # locks up
family0 <- Tweedie                      # needs setting

family0 <- poisson(link="log")          # rank 3
# family0 <- log_norm                     # identical to gaussian with log?
family0 <- gaussian(link="log")         # best

family0 <- gaussian
family0 <- poisson                      # best so far

## Use a generic name for the final ftre

c0 <- colnames(data0)
c0[c0 == hcc0[["outcomen"]] ] <- "value"
colnames(data0) <- c0

## Store GAMs in here

gs <- list()

## Weirdly, the month doesn't help. It seems to deduce it from the weather
## I only use it for the tensor as the basis

## GAM 1

## It doesn't like the deltas or af. af is dropped as a NZV.

ftres <- hcc0[["features"]]
## ftres <- setdiff(ftres, hcc0[["x"]])

descrs <- paste(sapply(ftres, hcc.paste0), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("ps:", ftres, collapse=", ")

gam0 <- gam(fmla,
            weights = wts,
            data = data0,
            family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0, force0=TRUE)       # just to start with

hcc.chart3(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

summary(gam0)$r.sq

## GAM 2 - try cyclic splines - only allowed 2

ftres <- hcc0[["features"]]

descrs <- paste(sapply(ftres, function(x) hcc.paste0(x, bs0="cc")), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("cc:", ftres, collapse=", ")

gam0 <- gam(fmla,
            weights = wts,
            data = data0,
            family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart3(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 4 - try cubic splines

ftres <- head(hcc0[["features"]], n=6)

descrs <- paste(sapply(ftres, function(x) hcc.paste0(x, bs0="cs")), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("cc:", ftres, collapse=", ")

gam0 <- gam(fmla,
            weights = wts,
            data = data0,
            family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart3(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 5 - try a tensor
## Use the input as one half of the tensor basis
## Top two pair it.

ftres <- hcc0[["features"]]
x0 <- setdiff(ftres, hcc0[["x"]])
ftres <- head(x0, n=2)

paste2 <- function(x) hcc.paste1(x, dr0=hcc0[["x"]], bs0="ps", bs1="ps")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", hcc0[["x"]], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart3(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 6 - try a tensor with cr
## Use the input as one half of the tensor basis
## Top two pair it.

ftres <- hcc0[["features"]]
x0 <- setdiff(ftres, hcc0[["x"]])
ftres <- head(x0, n=2)

paste2 <- function(x) hcc.paste1(x, dr0=hcc0[["x"]], bs0="cr", bs1="cr")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", hcc0[["x"]], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart3(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 7 - try a tensor with cc
## Use the input as one half of the tensor basis
## Top two pair it.

ftres <- hcc0[["features"]]
ftres <- setdiff(ftres, hcc0[["x"]])
ftres <- head(ftres, n=3)

paste2 <- function(x) hcc.paste1(x, dr0=hcc0[["x"]], bs0="cc", bs1="cc")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", hcc0[["x"]], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart3(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 8 - try a tensor with ps (cr is bad.)
## basis is tmin

ftres <- hcc0[["features"]]
ftres <- setdiff(ftres, "tmin")
ftres <- head(ftres, n=3)

paste2 <- function(x) hcc.paste1(x, dr0="tmin", bs0="ps", bs1="ps")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", hcc0[["x"]], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart3(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

summary(gam0)$r.sq

## Sort these for later

sapply(gs, AIC)

l0 <- sapply(gs, function(x) summary(x)$r.sq)

l0 <- sort(l0, decreasing=TRUE)

gs <- gs[names(l0)]

## the best fit can be wildly out with fabricated data.
gam0 <- gs[[1]]

## Predict a sample set

hcc0[["egs-sample"]] <- subset(data0, data0$sset == "oct2017", select="wrkid")[["wrkid"]]

splot0 <- hcc.chart3(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]], egs=hcc0[["egs-sample"]])

spdf2 <- hcc.chart3(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]], 
                    egs=hcc0[["egs-sample"]], noplot=TRUE)

spdf2 <- spdf2[ rev(order(spdf2$dfctdt0, spdf2$cwy0)), ]
spdf2 <- head(spdf2, n=length(hcc0[["egs-sample"]]))

spdf2 <- subset(spdf2, select=c(gam0$ftres, "health", "x0", "value", "dfcts", "cwy0", "wt0", "dfctdt0", "surftype"))

c0 <- colnames(spdf2) == "value"
colnames(spdf2)[which(c0)] <- hcc0[["outcomen"]]

c0 <- sort(colnames(spdf2))

spdf2 <- spdf2[ order(spdf2$health), c0]
write.csv(spdf2, file="hcc3-sset.csv", row.names=FALSE, na="")
     
## Build some plots of the errors

pdf2 <- data0[, unique(c(gam0$ftres, "value", "tmin", "dfcts", "cwy0", "wrkid", "pri")) ]

pdf2$x0 <- predict(gam0, pdf2)
if (gam0$family$link == "log") {
    pdf2$x0 = exp(pdf2$x0)
}

## If the prediction is greater than the value, this is bad.
## The road is in a condition where its major work was further back in the past.
## The road has received more wear than expected and is in worse health.

pdf2$health <- - (pdf2$x0 - pdf2[, "value"])

pdf2x <- pdf2

## See the clusters those with bad health to see if we notice what the factor is.

pdf2xerr <- pdf2[ pdf2$health < 0, ]

pdf2$x0 <- NULL
pdf2$value <- NULL

pdf3 <- scale(factor.numeric(pdf2))

wss <- (nrow(pdf3)-1)*sum(apply(pdf3,2,var))

kmeans0 <- function(x, idx) {
    return(kmeans(x, centers=i, iter.max=100, nstart=2))
}

for (i in 2:15) wss[i] <- sum(kmeans0(pdf3, i)$withinss)

plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

## K-Means Cluster Analysis
fit <- kmeans0(pdf3, 9) #

pdf2$cluster <- fit$cluster

x0 <- lapply(dev.list(), function(x) dev.off(x))

jpeg(filename=paste("hcc3", "-%03d.jpeg", sep=""), 
     width=1024, height=768)

print(p0)
print(p1)

print(splot0)

f.filter0 <- function(tbl, c0=c("cwy0", "wrkid", "dfcts1")) subset(tbl, select=setdiff(colnames(tbl), c0))

## error plots
plot(pdf2x$value, pdf2x$health)

## feature plot
plot(f.filter0(pdf2x))

plot(pdf2xerr$value, pdf2xerr$health)

## feature plot - errors only
plot(f.filter0(pdf2xerr))

f.filter1 <- function(x) f.filter0(x, c0=c("cwy0", "wrkid", "dfcts", "x0", "value", "pri"))

## cluster plot
x0 <- f.filter1(pdf2)
clusplot(x0, x0$cluster, color=TRUE, shade=TRUE, labels=3, lines=0)

x0 <- f.filter1(pdf2)
clusplot(x0, x0$cluster, color=TRUE, shade=TRUE, labels=3, lines=0)

x0 <- f.filter1(pdf2)
idx <- pdf2$health < 0
clusplot(x0[idx, ], x0[idx, "cluster"], color=TRUE, shade=TRUE, labels=3, lines=0)

corrplot::corrplot(corr1, method="number", order="hclust")

lapply(gs, function(x) hcc.chart3(x, tbl=data0, name1=hcc0[["outcomen"]]))

type0="pearson"
layout(matrix(1:2, ncol = 2))
acf(resid(gam0, type=type0), lag.max = 18, main = "ACF residuals")
pacf(resid(gam0,type=type0), lag.max = 18, main = "pACF residuals")

## End: asset lifetimes from wear and defects

x0 <- lapply(dev.list(), function(x) dev.off(x))

hcc0[["asset.life.model"]] <- gam0
hcc0[["asset.life.data"]] <- pdf2

hcc3 <- hcc0

save(hcc3, hcc0, file="hcc3.dat")
