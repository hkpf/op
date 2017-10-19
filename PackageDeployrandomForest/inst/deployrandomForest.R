#'operationalization: SERVER side
#'
#'Takes in a trained model and changes it to JSON by using the plumber, jsonlite and randomForest-packages.
#'
#'@import randomForest jsonlite
#'@return A locally REST Api gateway.
#'@export
#'

## load model
#model <- readRDS(file = "/model_rf_60000.rds")

create_web_api  <- function() {
    print("Hello, predict.rf!")
    #* @post /predict
    predict.rf <- function(req){
        # access data
        json <- req$postBody # access the json directly
        list <- jsonlite::fromJSON(json)
        data.frame <- as.data.frame(list)
        prediction <- predict.randomForest(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class
        return(list(label=as.numeric(as.character(prediction))))
    }

}

# Testing:
# d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")
# json <- toJSON(d.test[1, -785])
# list <- fromJSON(json)
# data.frame <- as.data.frame(list)
# prediction <- predict(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class
