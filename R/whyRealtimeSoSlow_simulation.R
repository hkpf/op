library(mrsdeploy)
library(RevoScaleR)
library(MicrosoftML)

remoteLogin("http://lin-mlserver.westeurope.cloudapp.azure.com:12800", 
            username = "admin",
            password = "PwF/uOnBo1",
            session = FALSE) 


d.train <- readRDS("../mnist_dataframes/mnist_train_dataframe.rds")
d.test <- readRDS("../mnist_dataframes/mnist_test_dataframe.rds")


# new train set with binary response Ybin to fit models using other rx Functions
d.train.bin <- d.train
d.train.bin$Y <- ifelse(as.numeric(as.character(d.train$Y)) %% 2 == 0 , 0, 1)




combinations <- cbind(c(8, 78, 784, 784), c(60000, 60000, 60000, 6000))
models <- vector(mode = "list", length = nrow(combinations))
times <- matrix(nrow = nrow(combinations), ncol = 4)
colnames(times) <-  c("time.fit", "time.publish", "time.pred.loc", "time.pred.api")


#TO DO: do API call 100 times each & mittelwert nehmen!

##############################
# revoScalR: rxLogit (binary) done
##############################

for(i in 1:nrow(combinations)){
    c <- combinations[i,1]
    n <- combinations[i,2]
    
    cat(combinations[i,])
    
    # sample c columns out of data set (since taking the first few results in cols with only 0's)
    set.seed(1)
    cols <- sort(sample(1:784, size = c))
    
    ## Create a formula for a model with all c variables:
    xnam <- paste0("V", cols)
    (fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
    
    # fit model 
    time.fit <- system.time(
        model <- rxLogit(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
    )[3]
    models[[i]] <- model
    
    # api generation
    time.publish <- system.time(
        rt_api <- publishService(
            serviceType = "Realtime",
            name = paste0("rxLogit_", n,"obs_",c, "columns"),
            code = NULL,
            model = model,
            v = "v1.0.0",
            alias = "apipredict"
        )
    )[3]
    
    # local prediction
    time.pred.loc <- system.time(
        rxPredict(model, data = d.test[1,cols]) 
    )[3]
    
    # rest call prediction
    time.pred.api <- system.time(
        result <- rt_api$apipredict(d.test[1,cols]) 
    )[3]
    result$outputParameters$outputData$Y_Pred
    
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
saveRDS(times, file = paste0("../realtimeStudy/times_rxLogit_fit.rds")) 
saveRDS(models, file = paste0("../realtimeStudy/models_rxLogit_fit.rds"))


##############################
# revoScalR: rxDTree (multiclass) done
##############################

for(i in 1:nrow(combinations)){
    c <- combinations[i,1]
    n <- combinations[i,2]
    
    cat(combinations[i,])
    
    # sample c columns out of data set (since taking the first few results in cols with only 0's)
    set.seed(1)
    cols <- sort(sample(1:784, size = c))
    
    ## Create a formula for a model with all c variables:
    xnam <- paste0("V", cols)
    (fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
    
    # fit model 
    time.fit <- system.time(
        model <- rxDTree(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
    )[3]
    models[[i]] <- model
    
    # api generation
    time.publish <- system.time(
        rt_api <- publishService(
            serviceType = "Realtime",
            name = paste0("rxDTree_", n,"obs_",c, "columns"),
            code = NULL,
            model = model,
            v = "v1.0.0",
            alias = "apipredict"
        )
    )[3]
    
    # local prediction
    time.pred.loc <- system.time(
        rxPredict(model, data = d.test[1,cols]) 
    )[3]
    
    # rest call prediction
    time.pred.api <- system.time(
        result <- rt_api$apipredict(d.test[1,cols]) 
    )[3]
    result$outputParameters$outputData$Y_Pred
    
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
saveRDS(times, file = paste0("../realtimeStudy/times_rxDTree_fit.rds")) 
saveRDS(models, file = paste0("../realtimeStudy/models_rxDTree_fit.rds"))

##############################
# MicrosoftML: rxLogisticRegression (multiclass) # stupid bug: need response column in test set as well for prediction, see below
##############################

for(i in 1:nrow(combinations)){
    c <- combinations[i,1]
    n <- combinations[i,2]
    
    cat(combinations[i,])
    
    # sample c columns out of data set (since taking the first few results in cols with only 0's)
    set.seed(1)
    cols <- sort(sample(1:784, size = c))
    
    ## Create a formula for a model with all c variables:
    xnam <- paste0("V", cols)
    (fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
    
    # fit model 
    time.fit <- system.time(
        model <- rxLogisticRegression(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
    )[3]
    models[[i]] <- model
    
    # api generation
    time.publish <- system.time(
        rt_api <- publishService(
            serviceType = "Realtime",
            name = paste0("rxLogisticRegression_", n,"obs_",c, "columns"),
            code = NULL,
            model = model,
            v = "v1.0.0",
            alias = "apipredict"
        )
    )[3]
    
    # local prediction
    time.pred.loc <- system.time(
        rxPredict(model, data = d.test[1,cols]) 
    )[3]
    
    # rest call prediction
    time.pred.api <- system.time(
        result <- rt_api$apipredict(d.test[1,cols]) 
    )[3]
    result$outputParameters$outputData$Y_Pred
    
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
saveRDS(times, file = paste0("../realtimeStudy/times_rxLogisticRegression_fit.rds")) 
saveRDS(models, file = paste0("../realtimeStudy/models_rxLogisticRegressiont_fit.rds"))

##############################
# MicrosoftML: rxFastTrees (binary) # stupid bug: need response column in test set as well for prediction
##############################

for(i in 1:nrow(combinations)){
    c <- combinations[i,1]
    n <- combinations[i,2]
    
    cat(combinations[i,])
    
    # sample c columns out of data set (since taking the first few results in cols with only 0's)
    set.seed(1)
    cols <- sort(sample(1:784, size = c))
    
    ## Create a formula for a model with all c variables:
    xnam <- paste0("V", cols)
    (fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
    
    # fit model 
    time.fit <- system.time(
        model <- rxFastTrees(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
    )[3]
    models[[i]] <- model
    
    # api generation
    time.publish <- system.time(
        rt_api <- publishService(
            serviceType = "Realtime",
            name = paste0("rxFastTrees_", n,"obs_",c, "columns"),
            code = NULL,
            model = model,
            v = "v1.0.0",
            alias = "apipredict"
        )
    )[3]
    
    # local prediction
    time.pred.loc <- system.time(
        rxPredict(model, data = d.test[1,cols]) 
    )[3]
    
    # rest call prediction
    time.pred.api <- system.time(
        result <- rt_api$apipredict(d.test[1,cols]) 
    )[3]
    result$outputParameters$outputData$Y_Pred
    
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
saveRDS(times, file = paste0("../realtimeStudy/times_rxFastTrees_fit.rds")) 
saveRDS(models, file = paste0("../realtimeStudy/models_rxFastTrees_fit.rds"))



#######################################################################
# stupid bug: need response column in test set as well for prediction
#######################################################################

##########################################
# here example with train = test set :):)
##########################################
logitModel <- rxLogisticRegression(isCase ~ age + parity + education + spontaneous + induced,
                                   transforms = list(isCase = case == 1),
                                   data = infert)
# Print a summary of the model
summary(logitModel)

# Score to a data frame
scoreDF <- rxPredict(logitModel, data = infert, 
                     extraVarsToWrite = "isCase")
scoreDF <- rxPredict(logitModel, data = infert, 
                     extraVarsToWrite = "isCase")

##########################################
# Multi-class logistic regression  
##########################################
testObs <- rnorm(nrow(iris)) > 0
testIris <- iris[testObs,]
trainIris <- iris[!testObs,]

multiLogit <- rxLogisticRegression(
    formula = Species~Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
    type = "multiClass", data = trainIris)

# Score the model
scoreMultiDF <- rxPredict(multiLogit, data = testIris) # working


##########################################
# our code
##########################################
#so the following works (train = test) -> need to make a künstliche response column at y
n <- 60000
c <- 8
model <- rxLogisticRegression(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
rxPredict(model, data = d.train.bin[1,c(cols, 785)])






