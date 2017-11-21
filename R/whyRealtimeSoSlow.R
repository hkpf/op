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
d.train.bin$Y <- ifelse(d.train$Y == 0, 0, 1)

head(d.train[,"Y"], n = 20)
head(d.train.bin[,"Y"], n = 20)





## train different models and create REST APIs
## RevoScaleR-functions:

n <- 60000
c <- 784


#####################################################
## few (=60000/10) observations n (and all columns):
#####################################################
n <- 60000/10
c <- 784

## Create a formula for a model with all 784 variables:
xnam <- paste0("V", 1:c)
(fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))

# fit model 
sys.time <- system.time(
    model <- rxLogit(formula = fmla, data = d.train.bin[1:n, ]) # 79.277 secs.
)[3]

saveRDS(model, file = paste0("../realtimeStudy/model_", n,"obs_",c, "columns_rxLogit_fit.rds")) 
saveRDS(sys.time, file = paste0("../realtimeStudy/sys_time_", n,"obs_",c, "columns_rxLogit_fit.rds")) 

# local prediction
sys.time <- system.time(
    rxPredict(rxLogit_nsmall, data = d.test[1,-785]) #0.050 seconds 
)[3]

saveRDS(sys.time, file = paste0("../realtimeStudy/sys_time_", n,"obs_",c, "columns_rxLogit_pred-local.rds")) 

# api generation
sys.time <- system.time(
    rt_api <- publishService(
        serviceType = "Realtime",
        name = paste0("rxLogit_", n,"obs_",c, "columns"),
        code = NULL,
        model = model,
        v = "v1.0.0",
        alias = "apipredict"
    )
)[3]
saveRDS(sys.time, file = paste0("../realtimeStudy/sys_time_", n,"obs_",c, "columns_rxLogit_publishApi.rds")) 

# rest call prediction
system.time(
    result <- rt_api$apipredict(d.test[1,-785]) # 0.39
)[3]
result$outputParameters$outputData$Y_Pred
saveRDS(sys.time, file = paste0("../realtimeStudy/sys_time_", n,"obs_",c, "columns_rxLogit_pred-api.rds")) 






## few (784/10) columns, c (and all observations) ### this seems to really make a difference
c <- 784 %/% 10
xnam <- paste0("V", 1:c)
(fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
system.time(
    rxLogit_nsmall <- rxLogit(formula = fmla, data = d.train.bin[, c(1:c, 785)]) # 4.22
)[3]

rxPredict(rxLogit_nsmall, data = d.test[1, 1:c]) # 0.004 seconds 









## large data set:
sys.time.seq <- system.time(
    rxLogit <- rxLogit(formula = fmla, data = d.train.bin)
)[3]


n <- 60000
ntree <- 50

sys.time.seq <- system.time(
    sdgg <- rxDForest(formula = fmla, data = d.train.bin, nTree = ntree)
)[3]




















