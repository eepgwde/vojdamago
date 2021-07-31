## weaves
##
## R predictions collation and chart
## 

rm(list=ls())
gc()

source("../R/brA0.R")

x.args = c("out/xncas1.csv", "hcc5.csv")

source("hcc0a.R")                       # gets data0 - the source data

pred1 <- read.csv(hcc.files[2], stringsAsFactor=FALSE)

pred1$dt0 <- as.POSIXct(pred1$dt0)

c0 <- intersect(colnames(data0), colnames(pred1))
data1 <- data0[ order(data0$dt0), c0]

pred2 <- pred1[ order(pred1$dt0), c0]
pred3 <- rbind(data1, pred2)

write.csv(pred3, "xncas3.csv")

types1 <- intersect(types, colnames(pred3))
pred4 <- pred3[, c(dt0, types1)]
pred5 <- NULL

x0 <- lapply(setdiff(colnames(pred4), "dt0"), function(x) { pred5 <<- rbind(pred5, stack0(pred4, yvar=x)) })

##

jpeg(filename=paste("hcc5t", "-%03d.jpeg", sep=""), 
     width=1024, height=768)


ggplot(data = pred5, aes(dt0, log(values), group=ind, colour=ind) ) + geom_line(size = 0.8) + theme_bw()

x0 <- lapply(dev.list(), function(x) dev.off(x))
