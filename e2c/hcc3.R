## weaves
##
## Following petolau
## https://github.com/PetoLau/petolau.github.io.git

rm(list=ls())
gc()

## Key library is mgcv

library(mgcv)
library(car)
library(ggplot2)
library(grid)
library(caret)

source("../R/brA0.R")

if(length(commandArgs(trailingOnly=TRUE)) <= 0) {
    x.args <- c("hcc2.csv", "hcc3.csv")
}

source("hcc0a.R")

hcc3.data <- data0

## Use this to carry out configurations.
hcc0 <- list()

hcc0[["dts"]] <- dts

## Let's look at some data chunk of consumption and try do some regression analysis.

stopifnot(any(types == "enqs"))

p1 <- ggplot(data0, aes(dt0, enqs)) +
  geom_line() +
  theme(panel.border = element_blank(), panel.background = element_blank(), panel.grid.minor = element_line(colour = "grey90"),
        panel.grid.major = element_line(colour = "grey90"), panel.grid.major.x = element_line(colour = "grey90"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold")) +
    labs(x = "Date", y = "count")

p2 <- ggplot(data0, aes(dt0, tmin)) +
  geom_line() +
  theme(panel.border = element_blank(), panel.background = element_blank(), panel.grid.minor = element_line(colour = "grey90"),
        panel.grid.major = element_line(colour = "grey90"), panel.grid.major.x = element_line(colour = "grey90"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold")) +
    labs(x = "Date", y = "tmin")

p3 <- ggplot(data0, aes(dt0, af)) +
  geom_line() +
  theme(panel.border = element_blank(), panel.background = element_blank(), panel.grid.minor = element_line(colour = "grey90"),
        panel.grid.major = element_line(colour = "grey90"), panel.grid.major.x = element_line(colour = "grey90"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold")) +
    labs(x = "Date", y = "af")

## View three key metrics together
multiplot(p1, p2, p3)

hcc0[["outcomen"]] <- "enqs"
hcc0[["corr.cutoff"]] <- 0.45           # not used

## Find only primary highly correlated and note nzvs
source("hcc3a.R")

## Just weather to enqs

## Business logic
## Some are prescient or not available or expensive

hcc0[["x"]] <- "mm1"                    # we always give it this

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
ftres <- setdiff(ftres, dwthrs)

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
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 2 - try cyclic splines - only allowed 2

ftres <- hcc0[["features"]]
ftres <- setdiff(ftres, dwthrs)

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
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 4 - try cubic splines

ftres <- head(hcc0[["features"]], n=6)
ftres <- setdiff(ftres, dwthrs)

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
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 5 - try a tensor
## Use the input as one half of the tensor basis
## Top two pair it.

ftres <- hcc0[["features"]]
ftres <- setdiff(ftres, dwthrs)
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
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 6 - try a tensor with cr
## Use the input as one half of the tensor basis
## Top two pair it.

ftres <- hcc0[["features"]]
ftres <- setdiff(ftres, dwthrs)
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
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 7 - try a tensor with cc
## Use the input as one half of the tensor basis
## Top two pair it.

ftres <- hcc0[["features"]]
ftres <- setdiff(ftres, dwthrs)
x0 <- setdiff(ftres, hcc0[["x"]])
ftres <- head(x0, n=2)

paste2 <- function(x) hcc.paste1(x, dr0=hcc0[["x"]], bs0="cc", bs1="cc")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", hcc0[["x"]], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## GAM 8 - try a tensor with ps (cr is bad.)
## basis is tmin

ftres <- hcc0[["features"]]
ftres <- head(x0, n=2)
ftres <- setdiff(ftres, "tmin")
ftres <- c(ftres, dts)

paste2 <- function(x) hcc.paste1(x, dr0="tmin", bs0="ps", bs1="ps")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", hcc0[["x"]], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart(gam0, tbl=data0, ctr0=tag)

summary(gam0)$r.sq

## Sort these for later

sapply(gs, AIC)

l0 <- sapply(gs, function(x) summary(x)$r.sq)

l0 <- sort(l0, decreasing=TRUE)

gs <- gs[names(l0)]

## the best fit can be wildly out with fabricated data.
gam0 <- gs[[1]]

pdf2 <- hcc.predict1(gam0, ytag=hcc0[["outcomen"]], ftres=NULL, 
                                    src0=data0, fls=hcc.files)

x0 <- lapply(dev.list(), function(x) dev.off(x))

jpeg(filename=paste("hcc3", "-%03d.jpeg", sep=""), 
     width=1024, height=768)

corrplot::corrplot(corr1, method="number", order="hclust")

lapply(gs, function(x) hcc.chart(x, tbl=NULL, nocoef=TRUE, name1=hcc0[["outcomen"]]))

layout(matrix(1:2, ncol = 2))
acf(resid(gam0), lag.max = 18, main = "ACF")
pacf(resid(gam0), lag.max = 18, main = "pACF")

## Try out predict()

pdf2 <- hcc.predict1(gam0, ytag=hcc0[["outcomen"]], ftres=NULL, 
                     src0=data0, fls=hcc.files)

## ggplot() won't do it from in a function
## Use a global, see the function hcc.chart1

ggplot(data = datas, aes(dt0, value, group=type, colour=type) ) + 
    geom_line(size = 0.8) + theme_bw() + 
    labs(x = "date", y = hcc0[["outcomen"]],
         title = sprintf("Predictions from GAM - %s", gam0$name))


## End: enquiries from temperature, month and frost

x0 <- lapply(dev.list(), function(x) dev.off(x))

hcc0[["wtr.enqs.model"]] <- gam0
hcc0[["wthr.enqs"]] <- pdf2

hcc3 <- hcc0

save(hcc3, hcc0, file="hcc3.dat")
