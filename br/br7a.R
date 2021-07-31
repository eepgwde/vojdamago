## weaves
## Output and store from a fit
## You need
##  br0 (w)
## then read 
##  fit1 ppl0 
##  trainPred trainClass testPred testClass ...
##  scls0

## Training set

trainPred <- predict(fit1, trainDescr)
postResample(trainPred, trainClass)
br0[["confusion.train"]] <- confusionMatrix(trainPred, trainClass, positive = br0[["outcomen0"]] )
br0[["confusion.train"]]

## Re-construct the data frame with predictions and outcomes - and rownames
ppl2 <- ppl0[rownames(trainDescr),]
ppl2[[ "predicted" ]] <- trainPred
ppl2[[ "actual" ]] <- trainClass

br0[["train.results"]] <- ppl2

## Test set

testPred <- predict(fit1, testDescr)
postResample(testPred, testClass)
br0[["confusion.test"]] <- confusionMatrix(testPred, testClass, positive = br0[["outcomen0"]] )
br0[["confusion.test"]]

ppl2 <- ppl0[rownames(testDescr),]
ppl2[[ "predicted" ]] <- testPred
ppl2[[ "actual" ]] <- testClass

br0[["test.results"]] <- ppl2

### Images

nvars <- floor(length(colnames(trainDescr)) * 2/3)

jpeg(filename=paste(scls0, "%03d.jpeg", sep=""), 
     width=1024, height=768)

modelImp <- varImp(fit1, scale = FALSE)
plot(modelImp, top = min(dim(modelImp$importance)[1], nvars) )

## Get a density and a ROC
## You need twoClassSummary for this

x.p <- predict(fit1, testDescr, type = "prob")[2]

test.df <- data.frame(true0=x.p[[ br0[["outcomen0"]] ]], Obs=testClass)
test.roc <- roc(Obs ~ true0, test.df)

densityplot(~test.df$true0, groups = test.df$Obs, auto.key = TRUE)

plot.roc(test.roc)

dev.off()


br0[["model.importance"]] <- modelImp

if (fit1$method == "gbm") {
    
    stopifnot( any(names(fit1$control) == "seeds") )
    
}

## ctrl$sampling <- "smote"
## 
## ctrl$seeds <- gbmFit1$control$seeds
## ctrl$sampling <- "smote"
