## SERVER side

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

#* @get /test
hello <- function() {
    sprintf( "Hello, Test" );
}

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
