## weaves
##
## Back-imputing.
## Get a table of imputed values and get them ready to be read back into the database.

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

library(doMC)
registerDoMC(cores = 4)

options(useFancyQuotes = FALSE) 

source("../R/brA0.R")

args = commandArgs(trailingOnly=TRUE)

## Load some data - we load from (TARGET)-3.dat
## ppl1 is scaled and centred. We decide what NZV to remove and go on
## to remove high correlations.

tgt0 <- "impute0.dat"                           # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

cls0 <- unlist(strsplit(tgt0, "\\."), use.names=TRUE)
scls0 <- paste(c(cls0[1], "imp-"), collapse="-")

load(tgt0, envir=.GlobalEnv)

## The idea is we get the centered, scaled and imputed values and match them with the originals.
## They're put into a table and the ids are stored.

## Before R converts factors to numerics, store them
es0 <- unique(ppl0$estatus0)
es1 <- data.frame(es0=as.character(es0), es1=as.integer(es0))

ppl1 <- df1

q0 <- factor.numeric(ppl0)

r0 <- sapply(br0[["enq1"]], function(x) sort(na.omit(unique(q0[[ x ]]), USE.NAMES=TRUE)))

k0 <- sapply(br0[["enq1"]], function(x) sort(unique(ppl1[[ x ]], USE.NAMES=TRUE)))

lapply(r0, length)

lapply(k0, length)

tag0 <- br0[["enq1"]][1]

unique(sort(q0[[ tag0 ]]))

unique(sort(ppl1[[ tag0 ]]))

x0 <- q0[ is.na(q0[[ tag0 ]]), br0[["enq1"]] ]

x1 <- ppl1[ rownames(x0), br0[["enq1"]] ]


x2 <- data.frame(emethod1=as.numeric(r0$emethod1), emethod1.imp=k0$emethod1)

x3 <- data.frame(priority=as.numeric(r0$priority), priority.imp=k0$priority)

x4 <- data.frame(response=as.numeric(r0$response), response.imp=k0$response)

x5 <- data.frame(estatus0=r0$estatus0, estatus0.imp=k0$estatus0)

x6 <- rbind(stack(x2), stack(x3), stack(x4), stack(x5))


q1 <- rownames(ppl0[ is.na(ppl0$emethod1), ])

q2 <- ppl1[ q1, br0[["enq1"]] ]
q2$smpl0 <- rownames(q2)

x.ctr <- 1
x.flnm <- sprintf("%s%03d.csv", scls0, x.ctr)
write.csv(x6, file=x.flnm, row.names=FALSE)

x.ctr <- x.ctr + 1
x.flnm <- sprintf("%s%03d.csv", scls0, x.ctr)
write.csv(q2, file=x.flnm, row.names=FALSE)

x.ctr <- x.ctr + 1
x.flnm <- sprintf("%s%03d.csv", scls0, x.ctr)
write.csv(es1, file=x.flnm, row.names=FALSE)

