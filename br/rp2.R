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
library(cluster)
library(Rweaves1)

library(doMC)

registerDoMC(cores = NULL)

options(useFancyQuotes = FALSE)

df.factors <- function(df0, names0 = list()) {
  if (length(names0) <= 0) {
    names0 = colnames(df0)[sapply(df0, class) == "factor"]
  }
  return(names0)
}

df.unfactor <- function(df0, names0 = list()) {
  if (length(names0) <= 0) {
    names0 = df.factors(df0)
  }

  for (i in names0)
    df0[[i]] <- as.numeric(df0[[i]])
  return(df0)
}

# https://www.statmethods.net/advstats/cluster.html

cluster.make0 <- function(mydata, plot0=FALSE, title="Untitled", c0=5, m0=15) {
  df0 <- df.unfactor(mydata)
  df0 <- scale(df0)
  
  wss <- (nrow(df0) - 1) * sum(apply(df0, 2, var))
  for (i in 2:m0) {
    wss[i] <- sum(kmeans(df0,
      centers = i
    )$withinss)
  }
  if (plot0) {
    plot(1:m0, wss,
      type = "b", xlab = "Number of Clusters",
      ylab = "Within groups sum of squares"
    ) # Determine number of clusters
  }

  # K-Means Cluster Analysis
  fit <- kmeans(df0, c0) # 5 cluster solution
  # get cluster means
  aggregate(df0, by = list(fit$cluster), FUN = mean)
  # append cluster assignment
  mydata <- data.frame(mydata, fit$cluster) # K-Means Cluster Analysis

  if (plot0) {
    require(cluster)

    clusplot(df0, fit$cluster,
      color = TRUE, shade = TRUE,
      labels = 2, lines = 0
    )
  }
  
  return(mydata)
}

## Load up the target given on the command line.

args = commandArgs(trailingOnly=TRUE)

if (length(args) <= 0) {
    args = c("../cache/out/xe2c.csv", "uni0", "modelq3")
}

tgt0 <- ""                       # a default
if (length(args) >= 1) {
    tgt0 <- args[1]
}

e2c <- read.csv(tgt0, 
                stringsAsFactors=TRUE, strip.white=TRUE,
                header=TRUE, na.strings=c(""))


pdf <- e2c[, ! colnames(e2c) %in% c("cwy0")]

jpeg(filename=paste("rp2", "-%03d.jpeg", sep=""), 
     width=1280, height=1024)

set.seed(107)
r0 <- cluster.make0(pdf, plot0=TRUE, title="Claims clusters")

dev.off()

pdf <- r0

zz <- "rp2.txt"

zz <- file(zz, open = "wt")
sink(zz)

cat("\n\n")
cat("most populated clusters, descending order\n")
sort(table(pdf$fit.cluster), decreasing=TRUE)

cat("\nBy road priority\n")
table(pdf$fit.cluster, pdf$pri)

cat("\nBy prior history - clm is no prior defects, enquiries or major works\n")
table(pdf$fit.cluster, pdf$type1)

cat("\nBy number of other assets with same asset prefix\n")
table(pdf$fit.cluster, pdf$nassets)

cat("\nBy log of distance\n")
table(pdf$fit.cluster, pdf$distance)

cat("\nBy log of model traffic\n")
table(pdf$fit.cluster, pdf$mtraffic)

sink()

## Save all

# save(fit0, ppl1, file="ppl1.dat")

