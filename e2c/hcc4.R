## weaves
##
## Predict the number of repudiations from the number of estimated
## enquiries.
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

load(file="hcc3.dat", envir=.GlobalEnv)

x.args <- c("hcc3.csv", "hcc4.csv")

source("../R/brA0.R")
source("hcc0a.R")

stopifnot(any(types == "enqs"))

hcc0[["x"]] <- "enqs"

hcc4.data <- data0

## And plot the x, the y (outcomen) and a temp
## Fiddly to functionate

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

hcc0[["outcomen"]] <- "repudns"         # business logic


## Just enquiries to repudns - slightly better correlated than claims
## and is available immediately.

## Business logic
## Some are prescient or not available or expensive

hcc0 <- hcc.ftres1(hcc0)

## Choose a family

family0 <- gaussian                     # negative values - need link via log
family0 <- ziP                          # locks up
family0 <- Tweedie                      # needs setting

family0 <- poisson(link="identity")
family0 <- gaussian(link="log")

## Use a generic name for the final ftre

cc0 <- colnames(data0)
c0[c0 == hcc0[["outcomen"]] ] <- "value"
colnames(data0) <- c0


## Store GAMs in here

gs <- list()

## GAM 1

## I've introduced weights hoping to boost later samples


## Make a formula and a tag
## There's a limit of 6 on the formula. I always add the mm1
ftres <- head(hcc0[["features"]], n=5)
ftres <- unique(c(ftres, dts[1]))

descrs <- paste(sapply(ftres, hcc.paste0), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("ps:", ftres, collapse=", ")

## Model it
gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag 
gam0[["ftres"]] <- ftres
gs[[tag]] <- gam0

hcc.gamS(gam0, force0=TRUE)       # just to start with
hcc.chart(gam0, tbl=data0, name1=hcc0[["outcomen"]], ctr0=tag)

## GAM 2 - cyclic cubic

## There's a limit of 6 on the formula.
ftres <- head(hcc0[["features"]], n=5)
ftres <- unique(c(ftres, dts[1]))

paste2 <- function(x) hcc.paste0(x, bs0="cc")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("cc:", ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

## GAM 3 - use tensors - but only two can be used relative to mm1

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
gam0[["ftres"]] <- unique(ftres)
gs[[tag]] <- gam0

hcc.gamS(gam0)
hcc.chart(gam0, tbl=data0, ctr0=tag, name1=hcc0[["outcomen"]])

## GAM 4 - tensor with ps

x0 <- setdiff(hcc0[["features"]], dts[1])
ftres <- head(x0, n=2)

paste2 <- function(x) hcc.paste1(x, dr0=dts[1], bs0="cc", bs1="cc")

descrs <- paste(sapply(ftres, paste2), collapse=" + ")
fmla <- as.formula(paste("value ~ ", descrs))
tag <- paste("te:cc: ", dts[1], ftres, collapse=", ")

gam0 <- gam(fmla, weights = wts, data = data0, family = family0)

gam0[["name0"]] <- tag
gam0[["ftres"]] <- unique(ftres)
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
gam0 <- gs[[1]]                         # best

## Predict
## We already have enqs predictions.

pdf2 <- hcc.predict1(gam0, ytag=hcc0[["outcomen"]], ftres=NULL, 
                     src0=data0, fls=hcc.files)


jpeg(filename=paste("hcc4", "-%03d.jpeg", sep=""), 
     width=800, height=600)

corrplot::corrplot(hcc0[["corr"]], method="number", order="hclust")

lapply(gs, function(x) hcc.chart(x, tbl=NULL, nocoef=TRUE, name1=hcc0[["outcomen"]]))

layout(matrix(1:2, ncol = 2))
acf(resid(gam0), lag.max = 18, main = "ACF")
pacf(resid(gam0), lag.max = 18, main = "pACF")

pdf2 <- hcc.predict1(gam0, ytag=hcc0[["outcomen"]], ftres=NULL, 
                     src0=data0, fls=hcc.files)

## ggplot() won't do it from in a function
## Use a global, see the function hcc.chart1

ggplot(data = datas, aes(dt0, value, group=type, colour=type) ) + 
    geom_line(size = 0.8) + theme_bw() +
    labs(x = "date", y = hcc0[["outcomen"]],
         title = sprintf("Predictions from GAM - %s", gam0$name))

dev.off()

hcc0[["enqs.repudns.model"]] <- gam0
hcc0[["enqs.repudns"]] <- pdf2

hcc4 <- hcc0

save(hcc4, hcc0, file = "hcc4.dat")

