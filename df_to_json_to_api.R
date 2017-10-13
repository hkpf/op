## input: data frame, output: POST call to server REST Api, transferring data as JSON

library(jsonlite)
library(df2json)
library(httr)

## TO DO: Continue Here, do as in post_call_to_localhost_tryout.R

post.df.to.server <- function(data.frame, url){
    #json.df <- toJSON(data.frame) #, pretty = TRUE
    POST(url = url, body = data.frame, encode = "json") 
}

post.df.to.server <- function(data.frame, url){
    json.df <- toJSON(data.frame) #, pretty = TRUE
    POST(url = url, body = json.df, encode = "json") 
}



# Testing
d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")
undebug(post.df.to.server)
post.df.to.server(d.test[1,-785], "localhost:8000/predict")

post.df.to.server(d.test, "localhost:8000/predict")
json1 <- toJSON(data.frame(a = 4, b = 6))
json2 <- toJSON(d.test[1,1:3])
cat(json1)

debug(post.df.to.server)
post.df.to.server(data.frame(a = 4, b = 6), "localhost:8000/test")


list <- list(a = 4, b = 6)
typeof(df)
res <- POST(url = "localhost:8000/test", body = list, encode = "json", verbose())
res



(d.test.small <- d.test[1:5, 120:124])

json.d.test.small <- toJSON(d.test.small, pretty = TRUE)
d.test.small.fromjson <- fromJSON(json.d.test.small)
str(d.test.small.fromjson)
d.test.small.fromjson - d.test.small