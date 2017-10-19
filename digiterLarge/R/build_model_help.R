library(devtools)

modellarge <- readRDS(file = "C:/Users/vepo/Documents/GitRepo/operationalisierung/models/model_rf_60000.rds")
devtools::use_data(modellarge, internal = TRUE, overwrite = TRUE) #save modellarge in sysdata.rda
