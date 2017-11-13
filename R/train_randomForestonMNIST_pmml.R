setwd("~/02_Projekte/00_Operationalisierung/operationalisierung/R")


## Preprocess Data ####
# functions for reading in MNIST data set
source("../utilitiy_functions/readMNISTintoR.R")
l.mnist <- load_mnist() # a list

# extract following matrices from the list
m.train.predictors <- l.mnist$train$x$x
m.train.labels <- l.mnist$train$y
m.test.predictors <- l.mnist$test$x$x
m.test.labels <- l.mnist$test$y

# Generate train data frame 
m.train <- cbind(m.train.predictors, m.train.labels)
d.train <- as.data.frame(m.train)
colnames(d.train)[785] <- "Y"
d.train$Y <- as.factor(d.train$Y)
saveRDS(d.train, file = "../mnist_dataframes/mnist_train_dataframe.rds")

# generate test data frame analogously
m.test <- cbind(m.test.predictors, m.test.labels)
d.test <- as.data.frame(m.test)
colnames(d.test)[785] <- "Y"
d.test$Y <- as.factor(d.test$Y)
saveRDS(d.test, file = "../mnist_dataframes/mnist_test_dataframe.rds")

############################################################

## Train Model on train data with ntree=500 ####
library(randomForest)
n <- nrow(d.train) #1000 schnell, 10000 ca. 1h, 
ntrees <- 50 # 50 or 500
set.seed(1)
sys.time.seq <- system.time( 
    model.rf <- randomForest( Y ~ . , d.train, do.trace = TRUE, ntree = ntrees) # need formula interface 
)[3]


# load xml and pmml library
library(XML)
library(pmml)

# convert model to pmml
model_rf.pmml <- pmml(model.rf,name = "MNIST Random Forest", data = model.rf)

# save to file "model_rf.pmml" in same workspace
saveXML(model_rf.pmml, file = paste0("../models/pmml/model_rf_", ntrees, "trees_", n, ".pmml"))

####################################################

## How good is the model? ####
pred <- predict(model.rf, newdata = d.test[,-785], type = "response") # test set as data frame
confusion.matrix <- table(true = d.test$Y, predicted = pred)
diag(confusion.matrix) <- 0
(error.rate <- sum(confusion.matrix)/nrow(d.test))
(accuracy <- (1-error.rate))


# default: ntree = 500