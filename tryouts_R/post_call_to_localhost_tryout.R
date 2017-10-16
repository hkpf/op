library(jsonlite)
library(df2json)
library(httr)

list <- list(a = 4, b = 6)

# the following works:

### send data as list:
res <- POST(url = "localhost:8000/test", body = list, encode = "json", verbose(), accept_json())
content(res)

res <- POST(url = "localhost:8000/paste", body = list(text1 = "hello ", text2 = "world"), encode = "json", verbose())
stop_for_status(res)
content(res)


### send data as json:
# from list
js <- toJSON(list) 
cat(js)
res <- POST(url = "localhost:8000/test", body = js, verbose(), accept_json())
content(res)

# from data frame:
df <- data.frame(a = 4, b = 6)  
# js <- toJSON(df) # not working
# cat(js)
# res <- POST(url = "localhost:8000/test", body = js, verbose(), accept_json())

# need to convert the data frame to a list first!
lst <- as.list(df)
lst
js <- toJSON(lst)
res <- POST(url = "localhost:8000/test", body = js, verbose(), accept_json())
content(res)
