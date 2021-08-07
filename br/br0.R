## weaves
##
## Data simplification
## H??? Carriageways.
## Splitting datasets
##   xroadsc - no road conditions
##   xlocalr - xroadsc - no local roads
##   xxwintry - xroadsc - only winter season
##   xenqr - xroadsc - only the claims records

## Assigning features to different classes

## Support methods

source("../R/brA0.R")

## Configuration holder

load("ppl00.dat", envir=.GlobalEnv)

stopifnot(exists("br0"))

print(dim(ppl00))

nulls.df(ppl00)

## Set my lucky seed. This file doesn't use it.
br0[["seed"]] <- 107

ppl <- ppl00

## Key field: smpl0

rownames(ppl) <- ppl[["smpl0"]]

## cwy0 - basic carriageway classes

br0["cwy0"] <- list(c("distance", "width", "area", "isdist", "pri",
                     "iscls", "pri2", "isslip", "isshared", "isdual",
                     "issingle", "isoneway", "isround", "lanes",
                     "lanes2", "rh0", "mtraffic", "spdlimit", "surftype", "isurban" ))

c0 <- colnames(ppl)
idx <- (which(grepl("nassets$", c0))):(which(grepl("a0Xisisolated$", c0)))

## The name of the outcome variable. Follow this.
br0[["outcomen"]] <- "isclm0"
br0[["outcomen0"]] <- "claim"           # a prettier name

### root road 
br0["cwy1"] <- list(c0[idx])

### without distance width and area
br0["cwy2"] <- list( unlist(br0["cwy0"], use.names=FALSE)[-(1:3)] )

### road types
## From cwy roadclass, see xlocalr
## These can be used to exclude lesser records: exclude where iscls = FALSE, pri <= 2
## mtraffic (and distance, width, area) may be a proxy for this, so exclude 
## Refuses to fit.

br0["cwy3"] <- list( setdiff(unlist(br0["cwy2"], use.names=FALSE), c("mtraffic")) )

ppl$islocal <- ppl$pri <= 3
ppl$local <- factor(ppl$islocal, labels=c("non-local", "local"))
ppl$islocal <- NULL

## Simpler
br0[["cwy4"]] <- c("distance0", "nassets", "mtraffic0", "isurban", "local", "isdist")

## Points of interest
## Buses and others

br0["poi"] <- list(c("nbus", "nhospital", "nhotel", "nrail", "nschool", "nsupermkt"))

## works - look-back and look-forward

c0 <- colnames(ppl)
idx <- grepl("^(status|dfct|prmt).*bC[0-9]$", c0)

br0["bworks"] <- list( c0[idx] )

idx <- grepl("^(status|dfct).*bC1$", c0)
br0[["bworks1"]] <- c0[idx]

c0 <- colnames(ppl)
idx <- grepl("^(status|dfct|prmt).*fC[0-9]$", c0)

br0["fworks"] <- list( c0[idx] )

## weather - current and past months

idx <- (which(grepl("tmax$", c0))):(which(grepl("ssn$", c0)))
c1 <- c0[idx]
idx <- (which(grepl("tmax0$", c0))):(which(grepl("ssn0$", c0)))
c1 <- append(c1, c0[idx])

br0["weather"] <- list(c1)

## LSOA

c0 <- colnames(ppl)
idx <- (which(grepl("^ncars0$", c0))):(which(grepl("fage00$", c0)))

br0["lsoa"] <- list(c0[idx])

## Enquiries and Road Hierarchy
## I believe this is how they assign CAT1 and CAT2.

idx <- (which(grepl("^emethod1$", c0))):(which(grepl("estatus0$", c0)))
br0[["enq0"]] <- append(c0[idx], c("pri", "pri2"))

## But estatus0 and priority are prescient so for rpart we use

br0[["enq1"]] <- setdiff(br0[["enq0"]], c("estatus0"))

br0[["enq2"]] <- append(br0[["enq1"]], c("mtraffic", "rh0"))
br0[["enq2"]] <- setdiff(br0[["enq2"]], c("priority"))

## samples history - look-back and look-forward

c0 <- colnames(ppl)
idx <- grepl("^(ss|s)mpl.*bC[0-9]$", c0)

br0["bsmpls"] <- list( c0[idx] )

c0 <- colnames(ppl)
idx <- grepl("^(ss|s)mpl.*fC[0-9]$", c0)

br0["fsmpls"] <- list( c0[idx] )


## Road conditions

br0["xroadsc"] <- list( c("ln","lreds","lambers","lgreens","rn","rreds","rambers","rgreens") )


## Columns to drop

## Junk
## ddate0 ddate1 src0

## Identity
## lsoa enq0, claim0, cwy0, siteid

## Too specific
## yyyy date0 month0

## Optional
## aid0

## Prescient
## outcome1 cost0 enq1:estatus0

br0["xcols0"] <- list( c("ddate0", "ddate1", "src0") )
br0["xcols1"] <- list( c("lsoa", "enq0", "claim0", "smpl0", "cwy0", "siteid") )
br0["xcols2"] <- list( c("yyyy", "date0", "month0", "yyyy0", "mm0", "month00") )
br0["xcols3"] <- list( c("aid0") )
## Not removed here, see br4a0.R
## priority is their method of classing enquiries. Very effective, see gbm9.zip
br0["prescient"] <- list( c("outcome1", "cost0", "estatus0", "smplfC1") )

## And remove these.

idx <- grepl("xcols[0-9]", names(br0))

x0 <- sapply(names(br0)[idx], function(x) br0[[x]], simplify=TRUE, USE.NAMES=FALSE )
drops <- unlist(x0, recursive = TRUE)

ppl0 <- ppl[ , !(names(ppl) %in% drops)]
ppl <- ppl0

## Check for nulls
nulls0 <- nulls.df(ppl)
nulls0


## xlsoar
## Drop the records where we have incomplete LSOA data - cars and pop

tag0 <- intersect(nulls0[,"c0"], br0[["lsoa"]])

tag0

ppl1 <- ppl
if (length(tag0) > 0) {
    ## Just select those rows where we don't have nulls in any of the LSOA columns
    x0 <- lapply(tag0, function(x) { 
        idx <- is.na(ppl1[[ x ]])
        if (length(idx) <= 0) return;
        ppl1 <<- ppl1[ !idx, ]
    })

}

print("here")

br0["xlsoar"] <- list(setdiff(rownames(ppl), rownames(ppl1)))

nulls1 <- nulls.df(ppl1)
nulls1

xlsoar <- ppl1

## xroadsc
## From xlsoar: no road condition 

xroadsc <- xlsoar[ is.na(ppl1[["ln"]]), !(names(ppl1) %in% br0[["xroadsc"]]) ]
xroadsc <- xroadsc[ xroadsc$surftype == "BITM", ]

setdiff(colnames(ppl1) , colnames(xroadsc))

nulls1 <- nulls.df(xroadsc)
print("xroadsc")
nulls1

## xlocalr
## From xroadsc: no local roads

table( xroadsc[, c("pri", "isclm0")])
table( xroadsc[, c("iscls", "isclm0")])

ppl1 <- xroadsc[xroadsc$iscls, colnames(xroadsc) ]

table( ppl1[, c("pri", "isclm0")])
table( ppl1[, c("iscls", "isclm0")])

xlocalr <- ppl1

br0["xlocalr"] <- list(setdiff(rownames(xroadsc), rownames(xlocalr)))

nulls.df(xlocalr)

## xxwintryr

ppl2 <- xroadsc

xxwintryr <- ppl2[ ppl2$ssn == "wintry", ]

br0["xxwintryr"] <- list(setdiff(rownames(ppl2), rownames(xxwintryr)))

## xenqr
## Only the claims records

ppl2 <- xroadsc
xenqr <- ppl2[ ppl2$outcome1 != "noaction", ]
xenqr$isclm0 <- xenqr$outcome1 == "settled"

table( xenqr[, c("outcome1", "isclm0")])

## Save all

save(xenqr, xxwintryr, xroadsc, xlocalr, ppl0, br0 , file="ppl0.dat")

