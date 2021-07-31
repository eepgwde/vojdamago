## weaves

## After stripping correlations, this plots them

## Corr by group
br0[["corr.names"]] <- sapply(br0[["groups"]], function(x) intersect(br0[["highCorr"]], br0[[x]]), USE.NAMES=TRUE)

## Size of group
x1 <-  sapply(names(br0[["nzv.names"]]), function(x) length(br0[[x]]), USE.NAMES=TRUE)

## Size of nzv group
x2 <-  sapply(names(br0[["nzv.names"]]), function(x) length(br0[["nzv.names"]][[x]]), USE.NAMES=TRUE)

x0 <- as.data.frame(cbind(x1, x2))
colnames(x0) <- c("N", "NZV")

br0[["nzv.summary"]] <- x0

jpeg(filename=paste(scls0, "-%03d.jpeg", sep=""), 
     width=1024, height=768)

c0 <- sapply(br0[["corr.names"]], function(x) length(x), USE.NAMES=TRUE)

c0 <- names(c0[c0 > 0])

lapply(c0,
       function(x) {
           c0 <- br0[["corr.names"]][[x]]
           if (length(c0) <= 1) return();
           corrplot::corrplot(br0[["descrCorr"]][ c0, c0], method="number", order="hclust")
           })

dev.off()
