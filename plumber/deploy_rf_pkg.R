## SERVER side

# load packages
library(plumber)
library(jsonlite)
library(randomForest)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

## predict label of new digit image sent as json, (which is a converted dataframe with variables V1,...,V784)
## (image has 28*28 = 784 pixels with values between 0 and 255 (mnist digit, with Pixels organized row-wise))

#* @get /test
hello <- function() {
    return( "Hello, Test" );
}

#* @post /predictemptypkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    #print(cat(json))
    #print(list)
    prediction <- predict_digit_empty(list)
    #return(list(label=as.numeric(as.character(prediction))))
    return(as.numeric(as.character(prediction)))
}

#* @post /predictsmallpkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    #print(cat(json))
    #print(list)
    prediction <- predict_digit_small(list)
    #return(list(label=as.numeric(as.character(prediction))))
    return(as.numeric(as.character(prediction)))
}

#* @post /predictlargepkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    #print(cat(json))
    #print(list)
    prediction <- predict_digit_large(list)
    #return(list(label=as.numeric(as.character(prediction))))
    return(as.numeric(as.character(prediction)))
}
