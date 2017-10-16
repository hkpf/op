## CLIENT side

library(jsonlite)
library(httr)

## input: data frame with one observation with 784 = 28x28 values between 0 and 255 (= 1 image, without label)
## translates data frame to JSON, sends a POST request to REST Api where a prediction of the label of this digit is made
## output: predicted label of the image
## Error handling für NAs: Falls data.frame NAs hat, gibt in predict.randomForest() error

post.df.to.server <- function(data.frame, url){
    json <- toJSON(data.frame)
    res <- POST(url = url, body = json, verbose(), accept_json()) 
    return(content(res))
}



# Testing
d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")
post.df.to.server(d.test[1,-785], "localhost:8000/predict")

# NAs
post.df.to.server((is.na(d.test[1,-785]) <- 1), "localhost:8000/predict")

