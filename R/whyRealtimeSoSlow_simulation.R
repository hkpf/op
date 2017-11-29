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
colnames(times) <-  c("time.fit", "time.publish", "mean.time.pred.loc", "mean.time.pred.api")

npred <- 100

#TO DO: do API call 100 times each & mittelwert nehmen!




############################################################
# revoScalR functions
############################################################

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
    
    # local 100 predictions
    time.pred.loc <- system.time(
        for(j in 1:npred){
            rxPredict(model, data = d.test[j,cols]) 
        }
    )[3]/npred
    
    # rest call 100 predictions
    time.pred.api <- system.time(
        for(j in 1:npred){
            result <- rt_api$apipredict(d.test[j,cols]) 
        }
    )[3]/npred
  
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
colnames(times)[1:2] <- c("features", "n")
saveRDS(times, file = paste0("../realtimeStudy/mean_times_rxLogit_fit.rds")) 
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
        for(j in 1:npred){
            rxPredict(model, data = d.test[j,cols]) 
        }
    )[3]/npred
    
    # rest call prediction
    time.pred.api <- system.time(
        for(j in 1:npred){
            result <- rt_api$apipredict(d.test[j,cols]) 
        }
    )[3]/npred
   
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
colnames(times)[1:2] <- c("features", "n")
saveRDS(times, file = paste0("../realtimeStudy/mean_times_rxDTree_fit.rds")) 
saveRDS(models, file = paste0("../realtimeStudy/models_rxDTree_fit.rds"))




############################################################
# MicrosoftML functions
############################################################


##############
# bug: 
##############
# bug: rxPredict.mlModel() needs a response column in data set with new observations for which you want to do a prediction
# Conclusion: for now, the MicrosoftML functions cannot be used unless this bug gets fixed.
# Detailed analysis as follows:

## Example 1 from MS -> only working since they use train = test set ####

logitModel <- rxLogisticRegression(isCase ~ age + parity + education + spontaneous + induced,
                                   transforms = list(isCase = case == 1),
                                   data = infert)
# Print a summary of the model
summary(logitModel)

# Score to a data frame
scoreDF <- rxPredict(logitModel, data = infert, 
                     extraVarsToWrite = "isCase")



## Example 2 from MS -> only working because there is a response column ####

testObs <- rnorm(nrow(iris)) > 0
testIris <- iris[testObs,]
trainIris <- iris[!testObs,]

multiLogit <- rxLogisticRegression(
    formula = Species~Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
    type = "multiClass", data = trainIris)

# Score the model
scoreMultiDF <- rxPredict(multiLogit, data = testIris) # 



## Example with our data ####

c <- 8
cols <- sort(sample(1:784, size = c))

model <- rxLogisticRegression(formula = fmla, data = d.train.bin[, c(cols, 785)]) 


# not working with dummy response column (only NAs)
d.test.dummy.response <- d.test
d.test.dummy.response$Y <- rep(NA, nrow(d.test.dummy.response))
rxPredict(model, data = d.test.dummy.response[1,c(cols, 785)]) 

# only using test = train works, so their prediction function indeed uses the response somehow
rxPredict(model, data = d.train.bin[1,c(cols, 785)])

# conclusion: don't use MicrosoftML functions unless this bug is fixed. 

# Nevertheless, we still tried out how fast the prediction would be if it would work correctly
# so we did the simulation study doing a prediction for the training data


##############################
# MicrosoftML: rxLogisticRegression (multiclass) 
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
        for(j in 1:npred){
            rxPredict(model, data = d.test[j,cols]) #### training set !!!!
        }
    )[3]/npred
    
    # rest call prediction
    time.pred.api <- system.time(
        for(j in 1:npred){
            result <- rt_api$apipredict(d.test[j,cols])   #### training set !!!!
        }
    )[3]/npred
    
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
colnames(times)[1:2] <- c("features", "n")
saveRDS(times, file = paste0("../realtimeStudy/mean_times_rxLogisticRegression_fit.rds")) 
saveRDS(models, file = paste0("../realtimeStudy/models_rxLogisticRegression_fit.rds"))




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








