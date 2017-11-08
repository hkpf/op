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
obs <- 8
d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")

## post request to localhost ####
# on laptop
#post.df.to.server(d.test[obs,-785], "localhost:8000/predict")
post.df.to.server(d.test[obs,-785], "localhost:8000/predictlargepkg")
post.df.to.server(d.test[obs,-785], "localhost:8000/predictsmallpkg")
post.df.to.server(d.test[obs,-785], "localhost:8000/predictemptypkg")
d.test[obs,785]

# on VM
#post.df.to.server(d.test[obs,-785], "localhost:80/predict")
post.df.to.server(d.test[obs,-785], "localhost:80/predictlargepkg")
post.df.to.server(d.test[obs,-785], "localhost:80/predictsmallpkg")
post.df.to.server(d.test[obs,-785], "localhost:80/predictemptypkg")


## post request from laptop to Azure VM ####
post.df.to.server(d.test[obs,-785], "lin-op-vm.westeurope.cloudapp.azure.com:80/predictlargepkg")
post.df.to.server(d.test[obs,-785], "lin-op-vm.westeurope.cloudapp.azure.com:80/predictsmallpkg")
post.df.to.server(d.test[obs,-785], "lin-op-vm.westeurope.cloudapp.azure.com:80/predictemptypkg")

# more general, to switch ports:
port <- 80
post.df.to.server(d.test[obs,-785], paste0("lin-op-vm.westeurope.cloudapp.azure.com:", port, "/predictlargepkg"))
post.df.to.server(d.test[obs,-785], paste0("lin-op-vm.westeurope.cloudapp.azure.com:", port, "/predictsmallpkg"))
post.df.to.server(d.test[obs,-785], paste0("lin-op-vm.westeurope.cloudapp.azure.com:", port, "/predictemptypkg"))


# NAs
post.df.to.server((is.na(d.test[1,-785]) <- 1), "localhost:8000/predict")
















