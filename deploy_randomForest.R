library(jsonlite)


## predict label of new digit sent as image (image = vector of length 28*28 = 784 with entries = values between 0 and 255 (mnist digit, with Pixels organized row-wise))

## load model 
model <- readRDS(file = "models/model_rf_60000.rds")
#c.names <- c(paste0(rep("X", length(numbs)), numbs),"Y")

#* @post /predict
predict.rf <- function(c.names){ ### CONTINUE HERE
    data.frame <- fromJSON(json) ### daten müssen anders generiert werden! variablennamen im json müssen verwendet werden!
    prediction <- predict(model, newdata = data.frame, type = "response") # alternatively, could also return probabilities for each class 
    return(list(label=as.numeric(as.character(prediction))))
}


#write the following in (new) R Session to generate Web server
# library(plumber)
# r <- plumb("deploy_randomForest.R")
# r$run(port=8000)
