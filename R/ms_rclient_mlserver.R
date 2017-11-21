# before creating REST Api you need to first install the necessary R packages in the correct (Rserver-)library on the VM:

# ssh soga@lin-op-vm.westeurope.cloudapp.azure.com

# To install the necessary R-packages on R Server, you need to do the following in the console on the VM:
# start R using sudo R
# using .libPaths() you can find the path of the R libraries:
# "/opt/microsoft/mlserver/9.2.1/libraries/RServer"
# "/opt/microsoft/mlserver/9.2.1/runtime/R/library"

# you need to install it into the 2nd library, because there the apis have access to. (but this is the deep one where the base R packages are installed, maybe there
# is even a better solution for this)
# install.packages("randomForest", lib = "/usr/lib64/microsoft-r/3.3/lib64/R/library") -> persistent

# even better: write this command into an R Skript which is sourced automatically when starting R Server.




# Afterwards, you can continue in R on your local machine
library(mrsdeploy)

remoteLogin("http://lin-mlserver.westeurope.cloudapp.azure.com:12800", 
            username = "admin",
            password = "PwF/uOnBo1",
            session = TRUE) 
#pause() # resume()
#remoteLogout()


## not needed anymore: hack to install the necessary packages ####
# works when this api belongs to same remoteLogin-connection as the prediction apis
# install.pkg <- function(num){
#     install.packages("randomForest") # NEEDED ALWAYS!!
#     library(randomForest)
#     0
# } 
# 
# api_installpkg <- publishService(
#     "installpkg",
#     code = install.pkg,
#     inputs = list(num = "numeric"),
#     outputs = list(answer = "numeric"),
#     v = "v1.0.0"
# )
# installres <- api_installpkg$install.pkg(9)
# str(installres)
#deleteService("installpkg", "v1.0.0")


# load models
modellarge <- readRDS(file = "../models/model_rf_500trees_60000.rds")
modelsmall <- readRDS(file = "../models/model_rf_50trees_60000.rds")

################################################
# create REST Apis for prediction
################################################


################################################
## Empty Model ####
################################################

predictempty <- function(dataframe_transp){
    "0" 
}

api_empty <- publishService(
    "modelEmpty",
    code = predictempty,
    inputs = list(dataframe_transp = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelEmpty", "v1.0.0")

################################################
## Models with transposed dataframe ####
################################################
predictlarge_transp <- function(dataframe_transp){
    library(randomForest) # necessary!
    mat <- matrix(nrow = 1, ncol = nrow(dataframe_transp))
    dataframe <- as.data.frame(mat)
    #colnames(dataframe) <- c(...) # not needed, colnames of dataframe are V1,...,V784 autom.
    dataframe[1,] <- dataframe_transp[,1]
    predict(modellarge, newdata = dataframe, type = "response") 
}

api_large_transp <- publishService( # takes a long time
    "modelLarge_transp",
    code = predictlarge_transp,
    model = modellarge,
    inputs = list(dataframe_transp = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelLarge", "v1.0.0")



predictsmall_transp <- function(dataframe_transp){
    library(randomForest)
    mat <- matrix(nrow = 1, ncol = nrow(dataframe_transp))
    dataframe <- as.data.frame(mat)
    #colnames(dataframe) <- c(...) # not needed, colnames of dataframe are V1,...,V784 autom.
    dataframe[1,] <- dataframe_transp[,1]
    predict(modelsmall, newdata = dataframe, type = "response")
}

api_small_transp <- publishService( # takes about 1min
    "modelSmall_transp",
    code = predictsmall_transp,
    model = modelsmall,
    inputs = list(dataframe_transp = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelSmall_transp", "v1.0.0")
#predictsmall_transp(dft)

####################################
## models with normal dataframe ####
####################################
# Large random Forest Model
predictlarge <- function(dataframe){
    library(randomForest) # necessary!
    predict(modellarge, newdata = dataframe, type = "response") 
}

api_large <- publishService( # takes a long time
    "modelLarge",
    code = predictlarge,
    model = modellarge,
    inputs = list(dataframe = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelLarge", "v1.0.0")


# Small random Forest Model
predictsmall <- function(dataframe){
    library(randomForest) # necessary!
    predict(modelsmall, newdata = dataframe, type = "response")
}

api_small <- publishService(
    "modelSmall",
    code = predictsmall,
    model = modelsmall,
    inputs = list(dataframe = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)
#deleteService("modelSmall", "v1.0.0")

########################
## Testing ####
########################
## get the published service
api_large_transp <- getService("modelLarge_transp", "v1.0.0")
api_small_transp <- getService("modelSmall_transp", "v1.0.0")
api_empty <- getService("modelEmpty", "v1.0.0")

## load test data
dtest <- readRDS("../mnist_dataframes/mnist_test_dataframe.rds")

## post calls to REST Apis
result <- api_empty$predictempty(dtest[1,-785]) # works since the empty api does not care about input at all
str(result)
result <- api_empty$predictempty(dft)
str(result)

# call for vector aka transposed dataframe :)
(dft <- data.frame(image = as.numeric(dtest[1,-785])))

result <- api_small_transp$predictsmall_transp(dft)
str(result)
result <- api_small_transp$predictsmall_transp(data.frame(image = rep(0,784)))
str(result)

result <- api_large_transp$predictlarge_transp(dft)
str(result)


# call for dataframe
result <- api_large$predictlarge(dtest[1,-785])
str(result)
result <- api_small$predictsmall(dtest[1,-785])
str(result)

####################################
## Get Swagger files for Postman ####
####################################
# Note: in all calls in Postman need to adjust https:///api with http://lin-op-vm.westeurope.cloudapp.azure.com:12800/api
# Postman Authorization setup: https://blogs.msdn.microsoft.com/mlserver/2017/02/22/rest-calls-using-postman-for-r-server-o16n-2/

swagger_large <- api_large$swagger()
write(swagger_large, "../swaggerFiles/swagger_api_large.json") 
swagger_small <- api_small$swagger()
write(swagger_small, "../swaggerFiles/swagger_api_small.json") 
swagger_empty <- api_empty$swagger()
write(swagger_empty, "../swaggerFiles/swagger_api_empty.json") 
swagger_small_transp <- api_small_transp$swagger()
write(swagger_small_transp, "../swaggerFiles/swagger_api_small_transp.json") 




# paste together post call for postman using modelsmall: 
n <- 784
var.nm <- character(n)
for(i in 1:n){
    var.nm[i] <- paste0(" \"V",i,"\"", ":[", 0, "],")
}
cat(var.nm)
var.nm.collapsed <- paste(var.nm, collapse = "")
cat(var.nm.collapsed)
var.nm.collapsed.fin <- substr(var.nm.collapsed, start = 1, stop = nchar(var.nm.collapsed)-1)
cat(var.nm.collapsed.fin)
call <- paste("{", " \"dataframe\":{ ", var.nm.collapsed.fin, "}}")
cat(call) # copy this output to postman






################################################
## TRYOUTS: model with few variables ####
################################################
## model with 5 variables, and input = data.frame, without rx-functions: -> working ###
fit <- lm(mpg ~ cyl + disp + hp +  wt + qsec, data = mtcars)
pr <- function(dataframe){
    library(stats)
    predict(fit, newdata = dataframe)
}
api.test <- publishService(
    "test1",
    code = pr,
    model = fit,
    inputs = list(dataframe = "data.frame"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)
pr(mtcars[1,])
result <- api.test$pr(mtcars[1,]) 
str(result)
print(result$output("answer"))

# now from POSTMAN
# get swagger file, which can be imported to postman, and where the calls need to be modified to contain the right url
swagger_test <- api.test$swagger()
write(swagger_test, "../swaggerFiles/swagger_api_test.json") 




## data.frame transposed, model with 5 variables -> working ###
dft <- data.frame(x = as.numeric(mtcars[1,]))
dft
colnames(mtcars[1,])

prt <- function(dataframe.transp){
    library(stats)
    mat <- matrix(nrow = 1, ncol = nrow(dataframe.transp))
    dataframe <- as.data.frame(mat)
    colnames(dataframe) <- c("mpg","cyl","disp","hp","drat","wt","qsec","vs","am","gear","carb") # not needed in predictsmall, colnames of dataframe V1,...,V784 autom.
    dataframe[1,] <- dataframe.transp[,1]
    predict(fit, newdata = dataframe)
}
#debug(prt)
prt(dft)

api.test.transp <- publishService(
    "test1_transp",
    code = prt,
    model = fit,
    inputs = list(dataframe = "data.frame"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)

result <- api.test.transp$prt(dft) 
str(result)







