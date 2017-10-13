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

# funktionieren beide von Postman aus, und neu auch von R direkt