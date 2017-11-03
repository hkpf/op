# before creating REST Api you need to first install the necessary R packages in the correct (Rserver-)library on the VM:

# ssh soga@lin-op-vm.westeurope.cloudapp.azure.com
# cd /usr/lib64/microsoft-r/rserver/o16n/9.1.0/rserve
# sudo R
# install.packages("randomForest")
# library(randomForest)



# Afterwards, you can continue in R on your local machine
library(mrsdeploy)

remoteLogin("http://lin-op-vm.westeurope.cloudapp.azure.com:12800", 
            session = TRUE) 
pause() # resume()
#remoteLogout()

## hack to install the necessary packages ####
# works when this api belongs to same remoteLogin-connection as the prediction apis
install.pkg <- function(num){
    install.packages("randomForest") # NEEDED ALWAYS!!
    library(randomForest)
    0
} 

api_installpkg <- publishService(
    "installpkg",
    code = install.pkg,
    inputs = list(num = "numeric"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)
installres <- api_installpkg$install.pkg(9)
str(installres)
deleteService("modelLarge", "v1.0.0")


## apis for prediction ####
# load models
modellarge <- readRDS(file = "models/model_rf_60000.rds")
modelsmall <- readRDS(file = "models/model_rf_1000.rds")


# create REST Apis for prediction

# Large random Forest Model
predictlarge <- function(dataframe){
    predict(modellarge, newdata = dataframe, type = "response") 
}

api_large <- publishService( # takes a long time
    "modelLarge",
    code = predictlarge,
    model = modellarge,
    inputs = list(dataframe = "data.frame"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelLarge", "v1.0.0")


# Small random Forest Model
predictsmall <- function(dataframe){
    predict(modelsmall, newdata = dataframe, type = "response")
}

api_small <- publishService(
    "modelSmall",
    code = predictsmall,
    model = modelsmall,
    inputs = list(dataframe = "data.frame"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelSmall", "v1.0.0")


# Empty Model
predictempty <- function(dataframe){
    0 
}

api_empty <- publishService(
    "modelEmpty",
    code = predictempty,
    inputs = list(dataframe = "data.frame"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelEmpty", "v1.0.0")


# Testing
dtest <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")

# post call to REST Apis
result <- api_large$predictlarge(dtest[1,-785])
str(result)
result <- api_small$predictsmall(dtest[1,-785])
str(result)
result <- api_empty$predictempty(dtest[1,-785])
str(result)

swagger_small <- api_small$swagger()
write(swagger_small, "swagger_api_small.json")





