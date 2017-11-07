#'operationalization: SERVER side
#'
#'Takes in a trained model and changes it to JSON by using the plumber, jsonlite and randomForest-packages.
#'
#'@import randomForest jsonlite
#'@return A locally REST Api gateway.
#'@export
#'

create_web_api  <- function() {
    print("Hello, predict.rf!")
    #* @post /predict
    predict.rf <- function(req){
        # access data
        json <- req$postBody # access the json directly
        list <- jsonlite::fromJSON(json)
        data.frame <- as.data.frame(list)
        prediction <- randomForest::predict.randomForest(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class
        return(list(label=as.numeric(as.character(prediction))))
    }

}
