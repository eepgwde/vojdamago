## weaves
##
## Predict the number of claims from the number of estimated
## repudiations
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

require("caret")
require("corrplot")

## Local config

load(file="hcc4.dat", envir=.GlobalEnv)

stopifnot(exists("hcc0"))

if(length(commandArgs(trailingOnly=TRUE)) <= 0) {
    x.args <- c("hcc4.csv", "hcc5.csv")
}

source("../R/brA0.R")
source("hcc0a.R")

hcc0[["x"]] <- "repudns"

hcc5.data <- data0

## Keep hyper-parameters

corr1 <- cor(as.matrix(data0[, colnames(data0) %in% c(types, wthrs, dts) ]))

## Claims correlates well to tmax and enqs
corrplot::corrplot(corr1, method="number", order="hclust")

corr1 <- cor(as.matrix(data0[, colnames(data0) %in% c(types, dwthrs, dts) ]))

## Claims correlates well to tmax and enqs
corrplot::corrplot(corr1, method="number", order="hclust")

corr1 <- cor(as.matrix(data0[, colnames(data0) %in% c(dtypes, wthrs, types, dts) ]))

## Claims correlates well to tmax and enqs
corrplot::corrplot(corr1, method="number", order="hclust")

stopifnot(any(types == "repudns"))

## And model with x and 

p1 <- ggplot(data0, aes(dt0, repudns)) +
  geom_line() +
  theme(panel.border = element_blank(), panel.background = element_blank(), panel.grid.minor = element_line(colour = "grey90"),
        panel.grid.major = element_line(colour = "grey90"), panel.grid.major.x = element_line(colour = "grey90"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold")) +
    labs(x = "Date", y = "claims")

p2 <- ggplot(data0, aes(dt0, tmax)) +
  geom_line() +
  theme(panel.border = element_blank(), panel.background = element_blank(), panel.grid.minor = element_line(colour = "grey90"),
        panel.grid.major = element_line(colour = "grey90"), panel.grid.major.x = element_line(colour = "grey90"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold")) +
    labs(x = "Date", y = "tmax")

p3 <- ggplot(data0, aes(dt0, enqs)) +
  geom_line() +
  theme(panel.border = element_blank(), panel.background = element_blank(), panel.grid.minor = element_line(colour = "grey90"),
        panel.grid.major = element_line(colour = "grey90"), panel.grid.major.x = element_line(colour = "grey90"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold")) +
    labs(x = "Date", y = hcc0[["x"]])

## View three key metrics together
multiplot(p1, p2, p3)

## Look deeper into correlations

df1 <- data0[, colnames(data0) %in% c(types, wthrs, dts, dtypes, dwthrs) ]
corr1 <- cor(as.matrix(df1))

## Claims correlates well to tmax and enqs
corrplot::corrplot(corr1, method="number", order="hclust")

corr1h <- caret::findCorrelation(corr1, cutoff = .55, verbose = FALSE)

## Just the high relative to the target

hcc0[["outcomen"]] <- "claims"         # business logic

hcc0[["corr.high"]] <- colnames(df1)[corr1h]

hcc0[["corr"]] <- corr1

hcc0[["corr.high1"]] <- NULL

x0 <- corr1[ corr1h, hcc0[["outcomen"]] ]

x0 <- abs(corr1[ names(x0), hcc0[["outcomen"]] ])
x0 <- sort(x0, decreasing=TRUE)

## The outcome will be the first so discard it.
x0 <- tail(names(x0), -1)

hcc0[["corr.high1"]] <- x0

## Just enquiries to repudns - slightly better correlated than claims
## and is available immediately.

## Business logic
## Some are prescient or not available or expensive
## Or we've used them

hcc0 <- hcc.ftres1(hcc0)

## Choose a family

family0 <- gaussian                     # negative values - need link via log
family0 <- ziP                          # locks up
family0 <- Tweedie                      # needs setting

family0 <- poisson(link="identity")
family0 <- gaussian(link="log")

## Use a generic name for the final ftre

c0 <- colnames(data0)
c0[c0 == hcc0[["outcomen"]] ] <- "value"
colnames(data0) <- c0

## Store GAMs in here

gs <- list()

## GAM 1

## I've introduced weights hoping to boost later samples

wts <- 1:dim(data0)[1]

wts <- rev(ewma(c(1, rep(0, length(wts) - 1)), lambda=1-0.90))
wts <- wts / mean(wts)

## default is equally-weighted
## Not for repudiations
## wts <- rep(1, dim(data0)[1])

hcc.paste0 <- function(x, bs0="ps") {
    return(sprintf("s(%s, bs=\"%s\")", x, bs0))
}

hcc.paste1 <- function(x, dr0="mm1", bs0="ps", bs1="cr") {
    return(sprintf("te(%s, %s, bs=c(\"%s\", \"%s\"))", x, dr0, bs1, bs0))
}

## GAM 1

## Make a formula and a tag
## There's a limit of 6 on the formula. I always add the mm1
ftres <- head(hcc0[["features"]], n=5)
ftres <- c(ftres, hcc0[["dts"]])

descrs <- paste(sapply(ftres, hcc.paste0), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste(ftres, collapse=", ")

## Model it
gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- ftres
gs[[tag]] <- gam0

hcc.gamS(gam0, force0=TRUE)       # just to start with
hcc.chart(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

## GAM 2 - use tensors - but only two can be used relative to mm1

## There's a limit of 6 on the formula. 
x0 <- setdiff(hcc0[["features"]], dts[1])
ftres <- head(x0, n=2)

paste2 <- function(x) hcc.paste1(x, dr0=dts[1], bs0="ps", bs1="ps")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", dts[1], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- ftres
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

## GAM 2 - use tensors - but only two can be used relative to mm1

## Make a formula and a tag
## There's a limit of 6 on the formula. I use mm1 as the tensor key
## in paste1
x0 <- setdiff(hcc0[["features"]], dts[1])
ftres <- head(x0, n=2)

paste2 <- function(x) hcc.paste1(x, dr0=dts[1], bs0="ps", bs1="ps")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te: ", dts[1], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- ftres
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

## Summarise

lapply(gs, AIC)

## Pick the best by AIC
## But this is operationally difficult to install
## So we take the next best

l0 <- sapply(gs, function(x) summary(x)$r.sq)
l0 <- sort(l0, decreasing=TRUE)

gs <- gs[names(l0)]
gam0 <- gs[[1]]                         # next best


pdf2 <- hcc.predict1(gam0, ytag=hcc0[["outcomen"]], ftres=NULL, 
                     src0=data0, fls=hcc.files)

r <- TRUE
while (r) {
    tryCatch(dev.off(), error = function(x) r<<-FALSE)
}

## Predict
## Use the hcc3 predictor in wthr.enqs

jpeg(filename=paste("hcc5", "-%03d.jpeg", sep=""), 
     width=800, height=600)

## ggplot() won't do it from in a function
## Use a global, see the function hcc.chart1

ggplot(data = datas, aes(dt0, value, group=type, colour=type) ) + 
    geom_line(size = 0.8) + theme_bw()


corrplot::corrplot(hcc0[["corr"]], method="number", order="hclust")

lapply(gs, function(x) hcc.chart(x, tbl=NULL, nocoef=TRUE, name1=hcc0[["outcomen"]]))

corrplot::corrplot(hcc0[["corr"]], method="number", order="hclust")

r <- TRUE
while (r) {
    tryCatch(dev.off(), error = function(x) r<<-FALSE)
}

hcc0[["repudns.claims.model"]] <- gam0
hcc0[["repudns.claims."]] <- pdf2

save(hcc0, file = "hcc5.dat")

