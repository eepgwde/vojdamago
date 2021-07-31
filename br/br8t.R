## weaves
##
## Machine learning: RF fit
##
## Load data from named file

rm(list = ls())
if (!is.null(dev.list())) {
    lapply(dev.list(), function(x) dev.off())
}

library(MASS)
library(ranger)
library(randomForest)
library(caret)
library(mlbench)
library(foreach)
library(pROC)

library(doMC)
registerDoMC(cores = 4)

options(useFancyQuotes = FALSE) 

## Load my functions

args = commandArgs(trailingOnly=TRUE)

data(iris)

# Create model with default paramters
control <- trainControl(method="repeatedcv", number=10, repeats=3)
seed <- 7

metric <- "Accuracy"
set.seed(seed)

## caret really won't let any of these parameters through via the grid.
mtry <- 2:4

# tunegrid <- expand.grid(.mtry=mtry, .splitrule = "gini", .min.node.size = c(10, 20) )

tunegrid <- expand.grid(.mtry=mtry)


tunegrid

fit1 <- train(Species  ~ ., data = iris,
              method = "ranger",
              trControl = control,
              tuneGrid = tunegrid,
              num.trees = 100,
              splitrule = "gini", 
              importance = 'impurity')

names(fit1)

print(fit1)

varImp(fit1)
