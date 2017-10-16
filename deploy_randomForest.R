## SERVER side

library(plumber)
library(jsonlite)
library(randomForest)


## predict label of new digit image sent as json, (which is a converted dataframe with variables V1,...,V784) 
## (image has 28*28 = 784 pixels with values between 0 and 255 (mnist digit, with Pixels organized row-wise))

## load model 
model <- readRDS(file = "models/model_rf_60000.rds")

#* @post /predict
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    data.frame <- as.data.frame(list)
    prediction <- predict(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class 
    return(list(label=as.numeric(as.character(prediction))))
}

# write the following in (new) R Session to generate Web server
# library(plumber)
# r <- plumb("deploy_randomForest.R")
# r$run(port=8000)


# Testing:
# d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")
# json <- toJSON(d.test[1, -785])
# list <- fromJSON(json)
# data.frame <- as.data.frame(list)
# prediction <- predict(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class 
