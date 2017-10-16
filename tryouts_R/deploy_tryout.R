library(jsonlite)
library(plumber)

#* @post /test
f.test <- function(a,b){
    res <- (a + b)/2
    return(paste("mean of a and b is:", res ))   #return(unbox(res)) 
}

#* @post /paste
f.paste <- function(text1, text2){
    return(paste(text1, text2))
}

## the following is what we need:

#* @post /names
f.test <- function(req){
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    df <- as.data.frame(list)
    res <- apply(df, 1, mean)
    return(paste("mean of a and b is:", res ))   #return(unbox(res)) 
}

# funktionieren beide von Postman aus, und neu auch von R direkt

# write the following in (new) R Session to generate Web server
# library(plumber)
# r <- plumb("deploy_tryout.R")
# r$run(port=8000)
