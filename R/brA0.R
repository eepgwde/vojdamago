## weaves

## weaves
##
## Re-classification of AdultHCI table
adult.class0 <- function(df) {
    df[["fnlwgt"]] <- NULL
    df[["education-num"]] <- NULL

    df[[ "age"]] <- ordered(cut(df[[ "age"]], c(15,25,45,65,100)),
                            labels = c("Young", "Middle-aged", "Senior", "Old"))

    df[[ "hours-per-week"]] <- ordered(cut(df[[ "hours-per-week"]],
                                           c(0,25,40,60,168)),
                                       labels = c("Part-time", "Full-time", "Over-time", "Workaholic"))

    df[[ "capital-gain"]] <- ordered(cut(df[[ "capital-gain"]],
                                         c(-Inf,0,median(df[[ "capital-gain"]][df[[ "capital-gain"]]>0]),Inf)),
                                     labels = c("NoGain", "LowGain", "HighGain"))

    df[[ "capital-loss"]] <- ordered(cut(df[[ "capital-loss"]],
                                         c(-Inf,0,
                                           median(df[[ "capital-loss"]][df[[ "capital-loss"]]>0]),Inf)),
                                     labels = c("NoLoss", "LowLoss", "HighLoss"))

    return(df)
}

## More re-classing.
## http://scg.sdsu.edu/dataset-adult_r/
## Set a low value for not-working

adult.workclass <- function(wclass) {
    wclass <- as.character(wclass)
    wclass <- gsub("^Federal-gov","Federal-Govt",wclass)
    wclass <- gsub("^Local-gov","Other-Govt",wclass)
    wclass <- gsub("^State-gov","Other-Govt",wclass)
    wclass <- gsub("^Private","Private",wclass)
    wclass <- gsub("^Self-emp-inc","Self-Employed",wclass)
    wclass <- gsub("^Self-emp-not-inc","Self-Employed",wclass)
    wclass <- gsub("^Without-pay","Not-Working",wclass)
    wclass <- gsub("^Never-worked","Not-Working",wclass)

    wclass <- ordered(as.factor(wclass), 
                      levels = c("Not-Working", "Self-Employed", "Private", "Other-Govt", "Federal-Govt"))
    
    return(wclass)
}

adult.occupation <- function(occ) {
    occ <- as.character(occ)
    occ <- gsub("^Adm-clerical","Admin",occ)
    occ <- gsub("^Armed-Forces","Military",occ)
    occ <- gsub("^Craft-repair","Blue-Collar",occ)
    occ <- gsub("^Exec-managerial","White-Collar",occ)
    occ <- gsub("^Farming-fishing","Blue-Collar",occ)
    occ <- gsub("^Handlers-cleaners","Blue-Collar",occ)
    occ <- gsub("^Machine-op-inspct","Blue-Collar",occ)
    occ <- gsub("^Other-service","Service",occ)
    occ <- gsub("^Priv-house-serv","Service",occ)
    occ <- gsub("^Prof-specialty","Professional",occ)
    occ <- gsub("^Protective-serv","Other-Occupations",occ)
    occ <- gsub("^Sales","Sales",occ)
    occ <- gsub("^Tech-support","Other-Occupations",occ)
    occ <- gsub("^Transport-moving","Blue-Collar",occ)

    occ <- ordered(as.factor(occ), 
                      levels = c("Blue-Collar", "Service", "Admin", "Military", "Sales", "Other-Occupations", "White-Collar", "Professional"))
    
    return(occ)
}

## This helps
## awk -F= '{ print $3, $4 }' t.lst
## sed -e 's/"//g' -e 's/]//g'
## grep Latin | awk '{ print $1 }'

adult.country <- function(country) {
    cc <- as.character(country)
    cc[which(cc %in% c("England", "India", "Ireland", "Scotland", "Canada"))] <- "Commonwealth"

    cc[which(cc %in% c("Japan", "Hong", "Taiwan", "China"))] <- "ChinaJapan"

    cc[which(cc %in% c("France", "Germany", "Holand-Netherlands", "Italy"))] <- "Euro1"

    cc[which(cc %in% c("Iran", "Greece", "Hungary", "Poland", "Portugal", "South", "Yugoslavia"))] <- "Euro2"

    cc[which(cc %in% c("Cuba", "Dominican-Republic","Guatemala","Haiti","Honduras","Jamaica","Mexico","Nicaragua","Outlying-US(Guam-USVI-etc)","Puerto-Rico","Trinadad&Tobago"))] <- "Latin-America"

    cc[which(cc %in% c("Cambodia","Laos","Philippines","Thailand","Vietnam"))] <- "SE-Asia"

    cc[which(cc %in% c("Peru","El-Salvador","Columbia","Ecuador"))] <- "South-America"

    return(as.factor(cc))
}

adult.education <- function(edu) {
    edu <- as.character(edu)
    
    edu = gsub("^Preschool","Dropout",edu)
    edu = gsub("^10th","Dropout",edu)
    edu = gsub("^11th","Dropout",edu)
    edu = gsub("^12th","Dropout",edu)
    edu = gsub("^1st-4th","Dropout",edu)
    edu = gsub("^5th-6th","Dropout",edu)
    edu = gsub("^7th-8th","Dropout",edu)
    edu = gsub("^9th","Dropout",edu)
    edu = gsub("^Assoc-acdm","Associates",edu)
    edu = gsub("^Assoc-voc","Associates",edu)
    edu = gsub("^Bachelors","Bachelors",edu)
    edu = gsub("^Doctorate","Doctorate",edu)
    edu = gsub("^HS-grad","HS-Graduate",edu)
    edu = gsub("^Masters","Masters",edu)
    edu = gsub("^Prof-school","Prof-School",edu)
    edu = gsub("^Some-college","HS-Graduate",edu)
    
    edu <- ordered(as.factor(edu), 
                      levels = c("Dropout", "HS-Graduate", 
                                 "Associates", "Bachelors",
                                 "Masters", "Prof-School",
                                 "Doctorate"))
    return(edu)
}
    
adult.capital <- function(df) {
    df$capital <- as.integer(df[["capital-gain"]])
    nloss <- df[["capital-loss"]] != "NoLoss"
    gain <- df[["capital-gain"]] == "NoGain"
    marks <- intersect(which(gain), which(nloss))
    df[marks, "capital"] <- -as.integer(df[marks, "capital-loss"])
    df$capital <- ordered(df$capital, labels=c("HighLoss", "LowLoss", "None", "LowGain", "HighGain"))

    df[["capital-loss"]] <- NULL
    df[["capital-gain"]] <- NULL
    
    return(df)
}

nulls.df <- function(df) {
    ## idxes <- sapply(colnames(df), function(x) { sum(as.integer(is.na(df[[ x ]]))) }, simplify="array", USE.NAMES=FALSE) > 0

    nulls0 <- sapply(colnames(df), function(x) { sum(as.integer(is.na(df[[ x ]]))) }, USE.NAMES=TRUE)
    nulls0 <- as.data.frame(as.matrix(nulls0[which(nulls0 > 0)]))
    colnames(nulls0) <- "nnulls"
    if (dim(nulls0)[1] == 0) {
        return(nulls0)
    }
    nulls0$c0 <- rownames(nulls0)
    rownames(nulls0) <- 1:dim(nulls0)[1]
    return(nulls0)
}

if (!exists("factor.numeric")) {
    factor.numeric <- function(d) 
        modifyList(d, lapply(d[, sapply(d, is.factor), drop=FALSE], as.integer))
}

if (!exists("factor.numeric")) {
    logical.numeric <- function(d) 
        modifyList(d, lapply(d[, sapply(d, is.logical), drop=FALSE], as.integer))
}

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

if (!exists("ewma")) {
    require("zoo")

    ewma <- function(x,lambda = 1, init = x[1]) {

        rval<-stats::filter(lambda * coredata(x),
                     filter=(1-lambda), method="recursive",
                     init=init)
        rval<-zoo(coredata(rval),index(x))
        rval
    }
}

stack0 <- function(tbl, xvar="dt0", yvar=colnames(tbl)[1]) {
    df1 <- stack(tbl[, yvar, drop = FALSE])
    df1[[ xvar ]] <- tbl[[ xvar ]]
    return(df1)
}

    
