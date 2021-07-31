## weaves
##
## Data analysis
## Herts Carriageways. 

rm(list=ls())
gc()

## Get started with a load and save to binary.

require(zoo)

library(cluster)
library(Rweaves1)                       # my personal library

source("../R/brA0.R")

x.args = commandArgs(trailingOnly=TRUE)

if (length(x.args) <= 0) {
    x.args <- c("out/xwrkcwy1.csv", "dress2")
}

tgt0 <- "out/xncas1.csv"
if (length(x.args) >= 1) {
    tgt0 <- x.args[1]
}

rgm0 <- NULL
if (length(x.args) >= 2) {
    rgm0 <- x.args[2]
}

scls0 <- sprintf("%s-%s", gsub("\\..+$", "", basename(tgt0)), rgm0)

hcc00 <- read.csv(tgt0, 
                  stringsAsFactors=TRUE, strip.white=TRUE,
                  header=TRUE, na.strings=c(""))

hcc00$wrkdt0 <- as.Date(hcc00$wrkdt0)
hcc00$dfctdt0 <- as.Date(hcc00$dfctdt0)
hcc00$date0 <- hcc00$date0

hcc.data = list()

## BITM only - some tcars0 are missing
## Full-set including
hcc.data[["src"]] <- scls0

## Only BITM roads    
hcc0 <- subset(hcc00, !(mtraffic < 100) & surftype == "BITM" & !is.na(tcars0) & wt0 == rgm0 )
hcc.data[[sprintf("%s-%s", rgm0, "full")]] <- hcc0

hcc.data[[rgm0]] <- hcc0

hcc <- hcc0

nulls.df(hcc)



## Check stats
hcc1 <- subset(hcc, is.na(hcc$impute0) & is.na(hcc$impute1), select=c("tmin", "days0", "mtraffic", "pri2"))

hcc3 <- scale(factor.numeric(hcc1))

wss <- (nrow(hcc3)-1)*sum(apply(hcc3,2,var))

for (i in 2:15) wss[i] <- sum(kmeans(hcc3, centers=i)$withinss)

plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

## K-Means Cluster Analysis
fit <- kmeans(hcc3, 5) # 5 cluster solution
## get cluster means
aggregate(hcc3, by=list(fit$cluster), FUN=mean)

## append cluster assignment and aggregate - lines up dates with traffic flow.

hcc1 <- data.frame(hcc1, fit$cluster) 

aggregate(. ~ fit.cluster, data = hcc1, summary)

# Ward Hierarchical Clustering
d <- dist(hcc3, method = "euclidean") # distance matrix
fit1 <- hclust(d, method="ward.D2")
groups <- cutree(fit1, k=5) # cut tree into 5 clusters


jpeg(filename=paste(scls0, "-%03d.jpeg", sep=""), 
     width=1024, height=768)

clusplot(hcc3, fit$cluster, color=TRUE, shade=TRUE, labels=2, lines=0)

plot(fit1) # display dendogram
# draw dendogram with red borders around the 5 clusters
rect.hclust(fit1, k=5, border="red")

dev.off()

save(hcc00, hcc, hcc.data, file="hcc00.dat")
