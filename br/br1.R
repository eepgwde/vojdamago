## weaves
##
## Visual validation using Recursive Partition Trees.
##
## @note
## Uses older version of R, so no caret.

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}
gc()

library(MASS)
library(rpart)
library(rpart.plot)

library(doMC)

registerDoMC(cores = NULL)

options(useFancyQuotes = FALSE) 

## Load up the target given on the command line.

args = commandArgs(trailingOnly=TRUE)

if (length(args) <= 0) {
    args = c("hcc2.dat", "uni0", "modelq3")
    args = c("ppl0.dat", "xroadsc", "enq1")
    args = c("xroadsc-9.dat", "ppl0", "enq1")
}

src0 <- "ppl0.dat"                       # a default
if (length(args) >= 1) {
    src0 <- args[1]
}

tgt0 <- "xroadsc"                       # a default
if (length(args) >= 2) {
    tgt0 <- args[2]
}

cls0 <- "cwy3-fworks"
cls0 <- unlist(strsplit(cls0, "-"), use.names=TRUE)
scls0 <- paste(c(tgt0, cls0), collapse="-")

if (length(args) >= 3) {
    cls0 <- unlist(strsplit(args[3], "-"), use.names=TRUE)
    scls0 <- paste(c(tgt0, cls0), collapse="-")
}

print(cls0)

load(src0, envir=.GlobalEnv)

ppl <- get(tgt0)                        # get indirectly
dim(ppl)                                

ppl00 <- ppl                            # backup

set.seed(br0[["seed"]])                 # helpful for testing

ppl1 <- ppl

df <- ppl[, c("isclm0", "priority")]
df$hipr <- df$priority >= 3.5
table(df[, c("isclm0", "hipr")])
  

## for class models change isclm0 to be a factor - it's prettier to view

ppl1$isclm1 <- factor(ppl1[[ br0[["outcomen"]] ]], labels=c("noclaim", "claim"))

## Build the formula
cls1 <- lapply(cls0, function(x) br0[[x]])
xnam <- unlist(cls1, use.names = FALSE)

## Either isclm1 or outcome1
out0 <- "isclm1 ~ "

fmla <- as.formula(paste(out0, paste(xnam, collapse= "+")))

fit0 <- list()
fit0[["maxcompete"]] <- 12
fit0[["cp"]] <- 0.00005

fit0[["control"]] <- rpart.control(maxcompete=fit0[["maxcompete"]], cp=fit0[["cp"]], 
                                   xval=10, maxdepth=8, surrogatestyle = 1)

fit <- rpart(fmla, method = "class", control=fit0[["control"]], data = ppl1 )

summary(fit)

printcp(fit)

x.ctr <- 1
x.flnm <- sprintf("%s-%03d.txt", scls0, x.ctr)

sink(x.flnm)
print(br0[["source"]])
print(fit)
sink()

if (1==0) {

    plotcp(fit)

    plot(fit, uniform = TRUE, main = scls0)
    text(fit, use.n = TRUE, all = TRUE, cex = .8)

    rpart.plot(fit, type=1, extra=101, main = scls0)

}

tiff(filename=paste(scls0, "-%03d.tiff", sep=""), 
     bg="transparent", width=1280, height=1024)

plotcp(fit)

plot(fit, uniform = TRUE, main = scls0)
text(fit, use.n = TRUE, all = TRUE, cex = .8)

rpart.plot(fit, type=1, extra=3, varlen=0, fallen.leaves=TRUE, main = scls0)
rpart.plot(fit, type=1, extra=109, varlen=0, digits=5, 
           fallen.leaves=TRUE, main = scls0)

dev.off()

## Save all

save(fit0, ppl1, file="ppl1.dat")

