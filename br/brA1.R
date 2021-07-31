### weaves
## Not just plotting functions, also data unstacking.

### ACF and others 
## quick eye-ball of the variables.

grph.set0 <- function(data0, nm0, jpeg0=NULL, 
                      idx0="dt0", ref0="r00", ntail=60) {
    
    if (!is.null(jpeg0)) {
        nm0.tag <- nm0
        nm0.fspec <- paste(nm0.tag, "-%03d.jpeg", sep ="")
        jpeg(width=1024, height=768, filename = nm0.fspec)
    }

    a0.p1 <- aes_(x = as.name(idx0), y = as.name(ref0))
    a0.p2 <- aes_(x = as.name(idx0), y = as.name(nm0))

    data1 <- tail(data0, n = ntail)

    grid.draw(grph.pair(data1, a0.p1, a0.p2))

### Auto-correlations
    
    acf(data1[, nm0], main=paste("acf: tail: ", nm0))
    acf(data0[, nm0], main=paste("acf: full: ", nm0))

    pacf(data1[, nm0], main=paste("pacf: tail: ", nm0))
    pacf(data0[, nm0], main=paste("pacf: full: ", nm0))

### Try a ccf with the name

    ccf(data1[, ref0], data1[, nm0], 
        main=paste("ccf: tail: ", ref0, nm0))

    ## Full-set

    ccf(data0[, ref0], data0[, nm0],
        main=paste("ccf: full: ", ref0, nm0))

    ## x01 clearly lags by one or two days.
    if (!is.null(jpeg0)) {
        dev.off()
    }
}

## Plots time-series
##
## Used for unstacked data.frame.
ts0.plot <- function(tbl, names0, xtra="r00", 
                     fname="XX0", 
                     ylab0="metric") {
    names.xr <- names0
    if (!is.null(xtra)) {
        names.xr <- append(xtra, names0)
    }

    ts.gpars=list(xlab="day", ylab=ylab0, main=fname,
                  lty=1:4, col=1:length(names.xr) )

    ts.plot(tbl[, names.xr], gpars=ts.gpars)
    legend("topleft", names.xr, lty=ts.gpars$lty, col=ts.gpars$col)
}

folio.marks0 <- function(tbl) {
    s0 <- paste(as.character(c(head(tbl$dt0, 1), 
                               tail(tbl$dt0, 1))), collapse="-")
    return(s0)
}

## Plots to JPEG
##
## Uses globals.
## Specifically for jr0.R

ts0.folio <- function(tbl) {
    nm0.tag <- folio.name
    nm0.marks <- folio.marks0(tbl)
    nm0.fspec <- paste(nm0.tag, nm0.marks, "-%03d.jpeg", sep ="")

    jpeg(width=1024, height=768, filename = nm0.fspec)

    lapply(1:dim(names.idxes)[1], 
           function(y) ts0.plot(tbl, 
                                names.x[names.idxes[y,]], 
                                fname=folio.name))

    dev.off()
}

## Calls the plotter for each group.
ts1.folio.f0 <- function(y, xtra0, ylab0, names.x, 
                         names.idxes, tag0, tbl) {
    x.names <- names.x[names.idxes[y,]]
    x.names <- append(xtra0, x.names)
    x.names <- unique(x.names)
    
    ts0.plot(tbl, x.names,
             ylab0=ylab0,
             fname=tag0, 
             xtra=NULL)
}

## Plots to JPEG
##
## Doesn't use globals, works for jr2.R
##
## names.idxes is a matrix of indices into the column names.

ts1.folio <- function(tbl, names.idxes, 
                      tag0="folios-", xtra0=NULL,
                      names.x=NULL, ylab0="metric") {

    nm0.tag <- tag0
    rs <- rownames(tbl)
    nm0.marks <- paste(rs[1], rs[length(rs)], sep="-")
    nm0.fspec <- paste(nm0.tag, nm0.marks, "-%03d.jpeg", sep ="")

    if (is.null(names.x)) {
        warning("names.x is null")
        names.x <- colnames(tbl)
    }

    jpeg(width=1024, height=768, filename = nm0.fspec)

    lapply(1:dim(names.idxes)[1], ts1.folio.f0, 
           xtra0=xtra0, ylab0=ylab0, names.x=names.x,
           names.idxes=names.idxes,
           tag0=tag0, tbl=tbl)

    dev.off()                           # error trap needed.
}

### Null factor conversion
## This is tricky because you can't rely on the factor ordering
## Convert to character.

null.factor0 <- function(col0) {
    if (!is.factor(col0)) {
        return(tbl);
    }

    lvls = list()
    lvls$v <- levels(col0)
    lvls$i <- sapply(lvls$v, function(x) (0 == nchar(x)), USE.NAMES=FALSE)

    if (!any(lvls$i)) {
        return(col0)
    }
    lvls$i <- which(!lvls$i)

    lvls$xxx <- as.character(col0)
    lvls$idxes <- which(sapply(lvls$xxx, function(x) (0 == nchar(x)), USE.NAMES=FALSE))
    
    table(addNA(col0, ifany = TRUE))
    col0[lvls$idxes] <- NA
    col0 <- factor(col0)[, drop = TRUE]
    
    return(col0)
}

tbl.factorize <- function(tbl0, null0=FALSE) {
    x.cols <- colnames(tbl0)
    x.idxes <- as.logical(sapply(tbl0,                                                   is.character, USE.NAMES=FALSE))
    tbl1 <- tbl0
    if (any(x.idxes)) {
        ustk.factors <- x.cols[x.idxes]
        lapply(ustk.factors, function(x) tbl1[, x] <<- as.factor(tbl1[, x]));
    }

    if (null0) {
        x.idxes <- as.logical(sapply(tbl1,                                                   is.factor, USE.NAMES=FALSE))
        ustk.factors <- x.cols[x.idxes]
        lapply(ustk.factors, function(x) 
            tbl1[, x] <<- null.factor0(tbl1[, x]));
    }

    return(tbl1)
}

### prototyping code.

## tbl <- folios.ustk0
## tag0 <- "folios"

## nm0.tag <- tag0
## rs <- rownames(tbl)
## nm0.marks <- paste(rs[1], rs[length(rs)], sep="-")
## nm0.fspec <- paste(nm0.tag, nm0.marks, "-%03d.jpeg", sep ="")
## rm("tbl", "tag0", "rs")

### Unstack tbl and return data.frame with renamed columns
## Optionally with merge.

ustk.folio <- function(tbl, merge0=NULL,
                        folios.metric="p00", rename=TRUE, rownames0=NULL) {

    folios.forml <- as.formula(paste(folios.metric, "~", "folio0"))

    ## unstack and find a way of plotting.
    folios.ustk <- unstack(tbl, folios.forml)

    if (!is.null(rownames0)) {
        folios.forml <- as.formula(paste(rownames0, "~", "folio0"))
        folios.rows <- unstack(tbl, folios.forml)
        if (dim(folios.rows)[1] != dim(folios.ustk)[1]) {
            warning("rownames not same length")
        } else {
            ## Just take the first column. Assume all equal.
            x.nm0 <- colnames(folios.ustk)[1]
            rowns <- folios.rows[, x.nm0]
            if (length(unique(rowns)) != length(rowns)) {
                warning("rownames not unique")
            } else {
                rownames(folios.ustk) = rowns
            }
        }
    }

    if (rename) {
        x0 <- sapply(names(folios.ustk), 
                     function(y) paste(y, ".", folios.metric, sep=""), 
                     simplify=TRUE, USE.NAMES=FALSE)
        names(folios.ustk) <- x0
    }

    if (!is.null(merge0)) {
        folios.x00 <- data.frame(folios.ustk, merge0)
        folios.ustk <- folios.x00
    }

    return(tbl.factorize(folios.ustk))
}

### Unstack all metrics matching pattern.
## tbl is now the q/kdb+ data as a data.frame ie. folios.in
## @todo
## Not entirely sure they're merged in the same order!
## @note
## Great feature of R is the <<- operator

ustk.folio1 <- function(tbl, merge0=NULL, patt="[a-z]+[0-9]{2}$",
                        rownames0=NULL) {

    x0.all <- colnames(tbl)
    x0.metrics <- sort(x0.all[grepl(patt, x0.all)], decreasing = TRUE)

    ## Do the first by hand and resolve merge0

    folios.metric <- x0.metrics[1]
    x0.metrics <- x0.metrics[2:length(x0.metrics)]

    ## This is a key global
    t1 <- NULL
    
    if (!is.null(merge0)) {
        t1 <- ustk.folio(tbl, merge0=merge0,
                         folios.metric=folios.metric,
                         rownames0=rownames0)
    } else {
        t1 <- ustk.folio(tbl, 
                         folios.metric=folios.metric,
                         rownames0=rownames0)
    }

    ## Note the global assignment operator, it searches for t1
    ## in an environment; here, it will find t1 in the caller.
    sapply(x0.metrics, function(y)
        t1 <<- ustk.folio(tbl, merge0=t1,
                          folios.metric=y,
                          rownames0=rownames0),
        simplify=TRUE, USE.NAMES=FALSE)

    return(t1)
}

### Find column names of folios matching a pattern.
##
## ustk is an unstacked table with many columns of form KA.r00
## finds all those that match the pattern.
## If you give just metric0="x00", that takes priority and the patt is
## set to "^[A-Z]{2}\\.x00$"
## @note
## Double quote slash for a literal dot '.' \\.

ustk.patt <- function(ustk, patt="^[A-Z]{2}\\.p00$", metric0=NULL) {
    x0.all <- colnames(ustk)
    if (!is.null(metric0)) {
        patt <- paste("^[A-Z]{2}\\.", metric0, "$", sep="")
    }
    
    return(x0.all[grepl(patt, x0.all)])
}

### Plot to jpeg file.
## @todo
## I haven't implemented the mnames logic, just use metric0
## be careful not to re-use globals as arguments.
## Change the names.cols, but try not to have more than 6 on a
## chart.

jpeg.ustk <- function(ustk, metric0="p00", xtra0="KA", 
                      names.cols = 5, mnames = NULL, tag0=NULL) {
    f.metric <- NULL
    f.mnames <- NULL

    if (!is.null(mnames)) {
        f.mnames <- mnames
        if (!is.null(metric0)) {
            f.metric <- "Metric"
        }
    } else {
        if (!is.null(metric0) && is.null(mnames)) {
            f.metric <- metric0
            f.mnames <- ustk.patt(ustk, metric0=f.metric)
        } else {
            warning("no metrics")
            return
        }
    }

    names.x <- f.mnames
    names.rows <- length(names.x) %/% names.cols
    if ((length(names.x) %% names.cols) != 0) {
        names.rows <- names.rows + 1
    }
    names.dim <- c(names.cols, names.rows)
    names.idxes <- t(array(1:length(names.x), dim=names.dim ))

    f.xtra0 <- NULL
    if (!is.null(xtra0) && !is.null(metric0)) {
        f.xtra0 <- paste(xtra0, f.metric, sep=".")
    }

    x.tag0 <- metric0
    if (is.null(x.tag0)) {
        if (!is.null(tag0)) {
            x.tag0 <- tag0
        } else {
            x.tag0 <- "metric"
        }
    }

    ## The composite folio
    ts1.folio(ustk, names.idxes, names.x = f.mnames,
              ylab0=f.metric, xtra0=f.xtra0, 
              tag0=paste(x.tag0, "-", sep=""))
}

### Remove a metric from an unstacked frame, mark outcome as an attribute
## 
## Two attributes are added ("outcomes" and "folio"), the outcomes is
## the folio's value for that metric.
## All metrics of that name are removed.
ustk.outcome <- function(df, folio="KF", metric0="fp05", patt=NULL) {
    outcomec <- paste(folio, metric0, sep=".")
    outcomes <- df[, outcomec]

    if (is.null(patt)) {
        patt <- paste("K[A-Z]\\.", metric0, sep="")
    }

    df0 <- df[, ! grepl(patt, colnames(df))]
    attr(df0, "outcomes") <- outcomes
    attr(df0, "folio") <- folio
    return(df0)
}

ustk.xfolios0 <- function(cols, folio=NULL) {
    patt <- paste(folio, "\\..+$", sep="");
    return(cols[which(grepl(patt, cols))])
}

### Delete all columns except for those of the named folios.
ustk.xfolios <- function(df, folios=c("KF")) {
    cols <- colnames(df)
    names <- lapply(folios, function(x) ustk.xfolios0(cols, folio=x))

    names <- unlist(names, use.names = FALSE)
    return(df[,names])
}

## Remove a null factor
ustk.factorize <- function(tbl, fmetric0="fp05") {
    if (length(levels(tbl[, fmetric0])) == 2) {
        return(tbl)
    }
    
    warning("Non binary results: forcing")
    x.factors <- unique(factor(tbl[, fmetric0]))
    x.idxes <- which(tbl[, fmetric0] == unique(factor(tbl[, fmetric0]))[1])
    tbl[x.idxes, fmetric0] <- x.factors[2]

    return(tbl)
}

pnl.calc0 <- function(v0) {
    v1 <- na.omit(v0)
    l0 <- as.list(summary(v1))
    l0$nas <- sum(is.na(v0))
    l0$n <- length(v0)
    
    l0$sd <- sd(v1)
    l0$sum <- sum(v1)
    return(as.data.frame(l0))
}

## Given a Profit and Lost table calculate the different profits.
pnl.calc <- function(tbl, folio0, metric0="pnl") {
    idxes <- which(tbl$pred == "profit")
    v0 <- pnl.calc0(tbl[idxes, metric0])
    v0$type0 <- "all"

    df <- v0

    idxes <- which(tbl$pred == "profit" & tbl$strat == "strat")
    v0 <- pnl.calc0(tbl[idxes, metric0])
    v0$type0 <- "strat"
    
    df <- rbind(df, v0)

    idxes <- which(tbl$pred == "profit" & tbl$strat == "nstrat")
    v0 <- pnl.calc0(tbl[idxes, metric0])
    v0$type0 <- "nstrat"

    df <- rbind(df, v0)

    df$folio <- folio0

    return(df)
}


