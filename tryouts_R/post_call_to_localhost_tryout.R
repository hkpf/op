library(jsonlite)
library(df2json)
library(httr)

## Conversion data frame to json to data frame: ####

# nice data frame
(df <- data.frame(name=c("a", "b", "c"), y=c(10, 20, 4), show=c(TRUE, FALSE, TRUE)))
js <- toJSON(df)
cat(js)
(df2 <- fromJSON(js))
as.data.frame(df2)

## Achtung: das funktioniert nicht richtig bei NAs und -Inf -> abfangen!!
(df <- data.frame(name=c("a", "b", "c"), x=c(NA, 2 ,3), y=c(10, 20, -Inf), show=c(TRUE, FALSE, TRUE)))
js <- toJSON(df)
cat(js)
(df2 <- fromJSON(js))
as.data.frame(df2)



## POST call to localhost: ####

### send data as json:

# from data frame:
df <- data.frame(a = 5, b = 6)  
js <- toJSON(df)
cat(js)
res <- POST(url = "localhost:8000/names", body = js, verbose(), accept_json())
content(res)









# from list
js <- toJSON(list) 
cat(js)
res <- POST(url = "localhost:8000/test", body = js, verbose(), accept_json())
content(res)

# need to convert the data frame to a list first!
# lst <- as.list(df)
# lst
# js <- toJSON(lst)
# cat(js)
# res <- POST(url = "localhost:8000/test", body = js, verbose(), accept_json())
# content(res)





### send data as list:
list <- list(a = 4, b = 6)
res <- POST(url = "localhost:8000/test", body = list, encode = "json", verbose(), accept_json())
content(res)

res <- POST(url = "localhost:8000/paste", body = list(text1 = "hello ", text2 = "world"), encode = "json", verbose())
stop_for_status(res)
content(res)