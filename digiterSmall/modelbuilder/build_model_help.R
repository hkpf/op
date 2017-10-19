library(devtools)

modelsmall <- readRDS(file = "C:/Users/vepo/Documents/GitRepo/operationalisierung/models/model_rf_1000.rds")
devtools::use_data(modelsmall,modelsmall, internal = TRUE, overwrite = TRUE)
