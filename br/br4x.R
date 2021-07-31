### weaves
## Fitting
##
## TODO 
## Not used.

fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 10,
    ## repeated ten times
    repeats = 10,
    classProbs = TRUE)

## Some trial and error with variables to branch and boost.
## Try all variables

gbmGrid <- expand.grid(interaction.depth = 
                           length(colnames(trainDescr)),
                        n.trees = (1:30)*90,
                        shrinkage = 0.2,
                        n.minobsinnode = 10)

set.seed(seed.mine)
gbmFit1 <- train(trainDescr, trainClass,
                 method = "gbm",
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 tuneGrid = gbmGrid,
                 metric = "Kappa",
                 verbose = FALSE)
gbmFit1

## Training set
## The correlation cut-offs
trainPred <- predict(gbmFit1, trainDescr)
postResample(trainPred, trainClass)
confusionMatrix(trainPred, trainClass, positive = "Weak")

## Test set: 

testPred <- predict(gbmFit1, testDescr)
postResample(testPred, testClass)
confusionMatrix(testPred, testClass, positive = "Weak")


## Get a density and a ROC

x.p <- predict(gbmFit1, testDescr, type = "prob")[2]
test.df <- data.frame(Weak=x.p$Weak, Obs=testClass)
test.roc <- roc(Obs ~ Weak, test.df)


### Final plots

## Variable importance

jpeg(filename=paste(ml0$folio, "%03d.jpeg", sep=""), 
     width=1024, height=768)

modelImp <- varImp(modelFit1, scale = FALSE)
plot(modelImp, top = 20)

## Get a density and a ROC

x.p <- predict(modelFit1, testDescr, type = "prob")[2]
test.df <- data.frame(profit=x.p$profit, Obs=testClass)
test.roc <- roc(Obs ~ profit, test.df)

densityplot(~test.df$profit, groups = test.df$Obs, auto.key = TRUE)

plot.roc(test.roc)

dev.off()



