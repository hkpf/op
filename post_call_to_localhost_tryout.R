library(jsonlite)
library(df2json)
library(httr)

list <- list(a = 4, b = 6)

# the following works:
res <- POST(url = "localhost:8000/test", body = list, encode = "json", verbose(), accept_json())
content(res)

res <- POST(url = "localhost:8000/paste", body = list(text1 = "hello ", text2 = "world"), encode = "json", verbose())
stop_for_status(res)
content(res)

js <- toJSON(list)
cat(js)
res <- POST(url = "localhost:8000/test", body = js, verbose(), accept_json())
content(res)
