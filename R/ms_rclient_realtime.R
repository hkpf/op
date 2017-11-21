# Real-time web service

# for R Server 9.1.0: Real-time web service only available for Windows
# for ML Server (9.2.1): Real-time web service available for Windows and Linux

# https://docs.microsoft.com/en-us/machine-learning-server/whats-new-in-r-server
# Scoring perform boosts with real time scoring: Web services that are published with a supported R model object 
# on *Windows* platforms 
# can now benefit from an extra realtime performance boost and lower latency. Simply use a supported model object 
# and set the serviceType = Realtime argument at publish time. Expanded platform support in future releases. 
# Learn more about Realtime web services.


library(mrsdeploy)
library(RevoScaleR)
library(MicrosoftML)

remoteLogin("http://lin-mlserver.westeurope.cloudapp.azure.com:12800", 
            username = "admin",
            password = "PwF/uOnBo1",
            session = FALSE) 

# fit model using functions of RevoScaleR or MicrosoftML
# as described in https://docs.microsoft.com/de-de/machine-learning-server/operationalize/concept-what-are-web-services
# (functions of "normal" R packages not possible)

# There are additional restrictions on the input dataframe format for microsoftml models:
#     
# The dataframe must have the *same number of columns* as the formula specified for the model.
# The dataframe must be *in the exact same order* as the formula specified for the model.
# The *columns* must be of the *same data type as the training data*. Type casting is not possible.

# There are two functions available for fitting a random forest: RevoScaleR::rxDForest and MicrosoftML::rxFastForest
# But rxFastForest from MicrosoftML-> only regression or binary classification possible
# so we use rxDForest





# empty model
rxDModelempty <- rxDForest(formula = Y ~ , data = d.train, nTree = 1)

?rxFastLinear
# as the closest represtentation of an empty model, use a linear model with only intercept (returns always one number)
rxDLinearIntercept <- rxLinMod(Y ~ 1, data = d.train) # not working, need to use rxSummary instead, see https://docs.microsoft.com/en-us/machine-learning-server/r/how-to-revoscaler-linear-model
rxDLinearIntercept <- rxSummary( ~ Y, data = d.train) # hmm but Y is categorical, need a classifier, which e.g. always predicts the same class
rxPredict(rxDLinearIntercept, data = d.test[1,-785])


############################
# load trained models
############################

#baseline ???
rxDModelsmall <- readRDS(file = "../models/model_rxDf_50trees_60000.rds")
rxDModellarge <- readRDS(file = "../models/model_rxDf_500trees_60000.rds")


############################
# prediction local
############################

d.test <- readRDS("../mnist_dataframes/mnist_test_dataframe.rds")
rxPredict(rxDModelsmall, data = d.test[1,-785]) # 0.618 seconds 
rxPredict(rxDModellarge, data = d.test[1,-785]) # 6.124 seconds (10x so lange wie bei model small)

############################
# Create Realtime Rest API
############################

realtimeApi_small <- publishService(
    serviceType = "Realtime",
    name = "rxDModelsmall",
    code = NULL,
    model = rxDModelsmall,
    v = "v1.0.0",
    alias = "rxDModelsmallService"
)

realtimeApi_large <- publishService(
    serviceType = "Realtime",
    name = "rxDModellarge",
    code = NULL,
    model = rxDModellarge,
    v = "v1.0.0",
    alias = "rxDModellargeService"
)

# 
# rxPredict(rxDModelsmall, data = d.test[1,-785]) 
# 
# 
# rxpredictsmall <- function(dataframe){
#     rxPredict(rxDModelsmall, data = dataframe) 
# }
# 
# 
# 
# standardApi_small <- publishService(
#     serviceType = "Standard",
#     name = "rxDModelsmall",
#     code = rxpredictsmall,
#     model = rxDModelsmall,
#     inputs = list(dataframe = "data.frame"),
#     outputs = list(label = "numeric")
#     v = "v1.0.0",
#     alias = "rxDModelsmallStandard"
# )
# 
# 
# predict(modellarge, data = d.test[1,-785])


##############################################
# Get already created Realtime Rest API
##############################################

realtimeApi_small <- getService("rxDModelsmall", "v1.0.0")
realtimeApi_large <- getService("rxDModellarge", "v1.0.0")


##########################################################
#           Consume Realtime Service in R                #
##########################################################

result_small <- realtimeApi_small$rxDModelsmallService(d.test[1,-785])
str(result_small)
result_small$outputParameters
result_small$outputParameters$outputData$Y_Pred

result_large <- realtimeApi_large$rxDModellargeService(d.test[1,-785])
result_large$outputParameters$outputData$Y_Pred


##########################################################
#         Get Service-specific Swagger File in R         #
##########################################################

# During this authenticated session, download the  
# Swagger-based JSON file that defines this service

rtSwagger_small <- realtimeApi_small$swagger()
write(rtSwagger_small, "../swaggerFiles/swagger_realtime_api_small.json") 

rtSwagger_large <- realtimeApi_large$swagger()
write(rtSwagger_large, "../swaggerFiles/swagger_realtime_api_large.json") 



# Share Swagger-based JSON with those who need to consume it




## tryout mit bsp von HP: #### # beide nur 81 Beob. und nur 2 variablen
# from https://docs.microsoft.com/de-de/machine-learning-server/operationalize/how-to-deploy-web-service-publish-manage-in-r
kyphosisModel <- rxLogit(Kyphosis ~ Age, data=kyphosis)
testData <- data.frame(Kyphosis=c("absent"), Age=c(71), Number=c(3), Start=c(5))
rxPredict(kyphosisModel, data = testData)  # Kyphosis_Pred: 0.1941938
serviceName <- paste0("kyphosis", round(as.numeric(Sys.time()), 0))

# Publish as service using publishService() function. 
# Use the variable name for the service and version `v1.0`
# Assign service to the variable `realtimeApi`.

realtimeApi <- publishService( # --> geht nicht: 
    serviceType = "Realtime",
    name = serviceName,
    code = NULL,
    model = kyphosisModel,
    v = "v1.0",
    alias = "kyphosisService"
)

result <- realtimeApi$kyphosisService(testData)
result$outputParameters$outputData$Kyphosis_Pred



## another code example from MS ####
# from https://blogs.msdn.microsoft.com/mlserver/2017/10/15/1-million-predictionssec-with-machine-learning-server-web-service/
library(RevoScaleR)
library(rpart)
library(mrsdeploy)
form <- Kyphosis ~ Number + Start
parms <- list(prior = c(0.8, 0.2), loss = c(0, 2, 3, 0), split = 'gini');
method <- 'class'; parms <- list(prior = c(0.8, 0.2), loss = c(0, 2, 3, 0), split = 'gini');
control <- rpart.control(minsplit = 5, minbucket = 2, cp = 0.01, maxdepth = 10,
                         maxcompete = 4, maxsurrogate = 5, usesurrogate = 2, surrogatestyle = 0, xval = 0);
cost <- 1 + seq(length(attr(terms(form), 'term.labels')));
myModel <- rxDTree(formula = form, data = kyphosis, pweights = 'Age', method = method, parms = parms,
                   control = control, cost = cost, maxNumBins = 100, maxRowsInMemory = if(exists('.maxRowsInMemory')) .maxRowsInMemory else -1)
myData <- data.frame(Number=c(70), Start=c(3))
op1 <- rxPredict(myModel, data = myData)

print(op1)
# absent_Pred present_Pred
# 1 0.925389 0.07461104


# Let's publish the model as a 'Realtime' web-service
name <- 'rtService'
ver <- '1.0'
svc <- publishService(serviceType='Realtime',name= name, code=NULL,  model=myModel, v=ver, alias = "testService")
# error: 400 	Unauthorized 	This Web Node does not support that runtime
op2 <- svc$consume(myData)
print(op2$outputParameters$outputData)










