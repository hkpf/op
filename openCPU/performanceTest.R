library(RCurl)
library(jsonlite)
library(digiterLarge)

#train <- read.csv("modelbuilder/train.csv")
#d.test
train <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")

get_prediction_from_openCPU <- function(image) {
    
    json <- postForm("http://localhost/ocpu/library/digiterLarge/R/predict_digit_large/json",
                     .params = list(image=paste('c(', paste(image,collapse = ","), ')', sep = "")))
    
    as.numeric(fromJSON(json))
    
}

get_prediction_local <- function(image) {
    as.numeric(as.character(predict_digit_large(as.numeric(image))))
}

system.time({
    #correct <- 0
    n <- 10
    p <- numeric(n)
    for(i in 1:n) {
        p[i] <- get_prediction_local(train[i,-785])
        #if(p[i]==train[i,1]) correct <- correct + 1
    }
    p
    #correct / 100}
)


system.time({
    #correct <- 0
    n <- 10
    p <- numeric(n)
    for(i in 1:10) {
        p[i] <- get_prediction_from_openCPU(train[i,-785])
        #if(p[i]==train[i,1]) correct <- correct + 1
    }
    p
    #correct / 100}
)
