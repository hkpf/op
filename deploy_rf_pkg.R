## SERVER side

# # install our own packages from github repo
# # to load models and predict functions from within the packages
# install.packages("C:/Users/soga/Desktop/op/digiterEmpty.zip", repos = NULL, type = "win.binary")
# install.packages("C:/Users/soga/Desktop/op/digiterLarge.zip", repos = NULL, type = "win.binary")
# install.packages("C:/Users/soga/Desktop/op/digiterSmall.zip", repos = NULL, type = "win.binary")
# 
# 
# # install packages from CRAN
# install.packages("plumber")
# install.packages("randomForest")
# install.packages("jsonlite")

# load packages
library(plumber)
library(jsonlite)
library(randomForest)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

## predict label of new digit image sent as json, (which is a converted dataframe with variables V1,...,V784)
## (image has 28*28 = 784 pixels with values between 0 and 255 (mnist digit, with Pixels organized row-wise))

## load models automatically within the packages

#* @post /predictemptypkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    data.frame <- as.data.frame(list)
    prediction <- predict_digit_empty(data.frame)
    return(list(label=as.numeric(as.character(prediction))))
}

#* @post /predictsmallpkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    data.frame <- as.data.frame(list)
    prediction <- predict_digit_small(data.frame)
    return(list(label=as.numeric(as.character(prediction))))
}

#* @post /predictlargepkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    data.frame <- as.data.frame(list)
    prediction <- predict_digit_large(data.frame)
    return(list(label=as.numeric(as.character(prediction))))
}

# write the following in (new) R Session to generate Web server
# library(plumber)
# r <- plumb("deploy_rf_pkg.R")
# r$run(port=8000)


# Testing:
# d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")
# json <- toJSON(d.test[1, -785])
# list <- fromJSON(json)
# data.frame <- as.data.frame(list)
# prediction <- predict(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class
