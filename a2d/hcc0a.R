## weaves

## GAM functions

require("mgcv")
require("car")
require("ggplot2")
require("grid")

## Chart some samples
hcc.chart3 <- function(gam0, tbl=data0, ctr0="none", name1="none", egs=NULL, noplot=FALSE) {

    if (is.null(egs)) {
        egs <- hcc0[["egs"]]
    }
    
    pdf2 <- subset(tbl, tbl$wrkid %in% egs )

    pdf2$x0 <- predict(gam0, pdf2)
    if (gam0$family$link == "log") {
        pdf2$x0 = exp(pdf2$x0)
    }

    ## If the prediction is greater than the value, this is bad.
    ## The road is in a condition where its major work is further back in the past.
    ## The road has received more wear than expected and is in worse health.
    
    pdf2$health <- - ( pdf2$x0 - pdf2[, "value"] )

    if (noplot) {
        return(pdf2)
    }

    grp0 <- "cwy0"
    x.legend=FALSE

    c0 <- colnames(pdf2)
    c0[which(c0 == grp0)] <- "grp0"
    colnames(pdf2) <- c0

    pdf2 <- pdf2[ order(pdf2$value, pdf2$dfcts), ]

    ## In the chart we plot the true value, and the health metric as a horizontal error bar.
    ## If the health is negative, it makes the road older, so we extend the effective age
    ## out to the right
    p0 <- ggplot(data = pdf2, aes(x=value, y=dfcts, group=grp0, colour=grp0) ) +
        geom_errorbarh(aes(xmax = value-health, xmin = value)) +
        geom_line(show.legend=x.legend, linetype="dashed") + 
        geom_point(aes(color=grp0), show.legend=x.legend) +
        theme_bw()

    return(p0)
}

## Some functions

hcc.chart <- function(gam1, ctr0="unknown", nocoef=FALSE, tbl=data0,
                      c0=c("value", "date0"), name1="enqs") {

    ## Number of coefficients
    if (!nocoef) {
    l0 <- length(unique(gsub("\\.[0-9]+$", "", names(gam1$coefficients))))

    layout(matrix(1:l0, nrow = 1))
    plot(gam1)
    }

    x.df1 <- tbl
    if (is.null(tbl)) {
        x.df1 <- (gam1$model)[, 1, drop = FALSE]
        x.df1[, c0[[2]] ] <- rownames(x.df1)
        colnames(x.df1)[1] <- c0[1]
    } else {
        x.df1 <- tbl[, c0]
    }
    x.df1$type <- "Real"

    x.df2 <- data.frame(value = gam1$fitted.values, 
                        date0 = x.df1[, c0[[2]] ] )
    x.df2$type <- "Fitted"

    datas <- rbind(x.df1, x.df2)

    ggplot(data = datas, aes(dt0, value, group = type, colour = type)) +
        geom_line(size = 0.8) +
        theme_bw() +
        labs(x = "date", y = name1,
             title = sprintf("Fit from GAM - %s", gam1[["name0"]]))

}

hcc.chart1 <- function(real0, fitted0, c0=c("value", "date0"), 
                       name0="Predictions", name1="days-from-work") {

    x.df1 <- real0[, c0]
    x.df1$type <- "Real"

    x.df2 <- fitted0[, c0]
    x.df2$type <- "Predicted"

    datas <<- rbind(x.df1, x.df2)

    ## TODO could this use aes_string()?

    ggplot(data = datas, aes(dt0, value, group = type, colour = type)) +
        geom_line(size = 0.8) +
        theme_bw() +
        labs(x = "date", y = name1,
             title = sprintf("Predictions from GAM - %s", name0))

}

## Loads a set of weather predictions with blanks for other quantities.
## Writes it back with the predictions.
## Can't use deltas on the denqs
##
## Relies on ytag to name the column to predict. hcc0[["outcomen"]]
hcc.predict1 <- function(gam0, ytag="enqs", ftres=NULL,
                         src0=data0, fls=c("left.csv", "right.csv")) {
    if (is.null(ftres)) {
        ftres <- gam0$ftres
    }

    ## Blanks just weather
    pdf2 <- read.csv(fls[1])
    c00 <- colnames(pdf2)
    c0 <- colnames(pdf2)
    c0[c0 == ytag] <- "value"
    colnames(pdf2) <- c0

    dtag <- sprintf("d%s", ytag)

    pdf2[["value"]] <- predict(gam0, pdf2)

    if (gam0$family$link == "log") {
        pdf2$value <- exp(pdf2$value)
    }

    hcc.chart1(src0, pdf2, name0=gam0$name, name1=ytag)

    ## Write it back with the predictions.
    colnames(pdf2) <- c00

    write.csv(pdf2, file=fls[2], row.names=FALSE)

    return(pdf2)
}

hcc.gamS <- function(gam1, zz="all.Rout", force0=FALSE) {
    if (force0) {
        unlink(zz, force=force0)
        fl <- file(zz, "wt")
    }
    
    x.gam <- gam1
    zz <- file(zz, open = "at")
    sink(zz)
    cat("\n\n")
    cat(sprintf("start: %s", x.gam$name), "\n")
    ## what to look at: summary: EDF, p-values, R^2, GCV; AIC, magic
    cat("summary: ")
    print(summary(x.gam))

    cat("R^2: ", summary(x.gam)$r.sq, "; ")

    cat("GCV: ", summary(x.gam)$sp.criterion, "; ")

    cat("AIC: ", x.gam$aic, "; ")

    cat("BIC: ", BIC(x.gam))
    cat("\n")

    # sink(zz, type = "message")
    ## revert output back to the console -- only then access the file!
    ## sink(type = "message")
    sink()
    return(zz)
}

## From Rscript get the script name
hcc.rscript <- function() {
    args = commandArgs(trailingOnly=FALSE) # "--file=cargs.R"

    idx <- grepl("^--file=", args)
    if (!any(idx)) {
        return("")
    }
    snm <- args[ which(idx) ]
    snm <- strsplit(snm, "=")
    snm <- snm[[1]][[2]]
    return(snm)
}

hcc.paste0 <- function(x, bs0="ps") {
    return(sprintf("s(%s, bs=\"%s\")", x, bs0))
}

hcc.paste1 <- function(x, dr0="mm1", bs0="ps", bs1="cr") {
    return(sprintf("te(%s, %s, bs=c(\"%s\", \"%s\"))", x, dr0, bs1, bs0))
}

## Build a feature set with our dependent income at the start.
hcc.ftres1 <- function(hcc0) {
    nzv0 <- hcc0[["nzv"]]
    hcc0[["nzv.vars"]] <- rownames(with(nzv0, nzv0[ nzv | zeroVar, ]))

    hcc0[["discard"]] <- c(hcc0[["outcomen"]], hcc0[["nzv.vars"]])
    hcc0[["discard"]] <- setdiff(hcc0[["discard"]], hcc0[["x"]])

    hcc0[["features"]] <- setdiff(hcc0[["corr.high1"]], hcc0[["discard"]])
    hcc0[["features"]] <- append(hcc0[["x"]], hcc0[["features"]])
    hcc0[["features"]] <- unique(hcc0[["features"]])
    return(hcc0)
}


### Defects from Assets degradation

## This is generated by 2csv. Joins in the weather.
## Pre-processed 
load("hcc00.dat", envir=.GlobalEnv)

stopifnot(exists("hcc"))
data0 <- hcc
rm("hcc")

## There are two prescient variables wrt days0
## ddays0 the number of days since last dfct
## dfcts the number of defects since last dfct

## ddays1 is the prev value with a default
## dfcts1 is the prev value with a default
## wear3 uses ddays0 in its calculation

## Generic classes for attributes
c0 <- colnames(data0)
idx <- which(grepl("^distance", c0)):which(grepl("^isurban", c0))
types <- c0[idx]
types <- setdiff(types, c("siteid", "surftype", "isshared"))

types <- c("wear1", "dfcts", "dfcts1")

c0 <- colnames(data0)
idx <- which(grepl("^imd", c0)):which(grepl("^tcars0", c0))
types1 <- c0[idx]

types1 <- c("wear3")

wthrs <- c("tmin", "tmin0", "dtmin0")

dts <- c("days0")
ddts <- c("ddays0", "ddays1")

dt0 <- c("date0")

imputes0 <- c("impute0", "impute1")

## Just to check
xcld <- c(types, wthrs, types1, dts, dt0, ddts)
xcld <- setdiff(colnames(data0), xcld)
xcld

types2 <- xcld

hcc.files <- NULL

## if you want to pass custom arguments, place before the script.

if (!exists("x.args")) {
    x.args = commandArgs(trailingOnly=TRUE)
}

if (length(x.args) >= 2) {
    hcc.files <- c(x.args[1], x.args[2])
}

## Oddly, these don't need to be reversed. This suggests, the enquiries are
## becoming more independent from the weather.
hcc.wts <- function(tbl) {
    wts <- list()
    wts[["flat"]] <- rep(1, dim(tbl)[1])

    wts[["exp"]] <- ewma(c(1, rep(0, length(wts[["flat"]]) - 1)), lambda=1-0.90)
    wts[["expmean"]] <- wts[["exp"]] / mean(wts[["exp"]])

    return(wts)
}

