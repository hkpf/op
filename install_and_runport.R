
# install packages from CRAN
install.packages("plumber")
install.packages("randomForest")
install.packages("jsonlite")
install.packages("devtools")

library(plumber)
library(randomForest)
library(devtools)
library(jsonlite)

# install our own packages from github repo
# to load models and predict functions from within the packages
install_github("hkpf/op/digiterLarge")
install_github("hkpf/op/digiterSmall")
install_github("hkpf/op/digiterEmpty")

#install("C:/Users/soga/Desktop/op")


# # load packages
# library(plumber, lib.loc="C:/Program Files/R/R-3.4.2/library")
# library(jsonlite, lib.loc="C:/Program Files/R/R-3.4.2/library")
# library(randomForest, lib.loc="C:/Program Files/R/R-3.4.2/library")
# library(devtools, lib.loc="C:/Program Files/R/R-3.4.2/library")
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)


setwd("C:/Users/soga/Desktop/op")
r <- plumb("deploy_rf_pkg.R")
r <- plumb("deploy_randomForest.R")
r$run(port=80)

