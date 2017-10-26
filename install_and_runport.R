# Run this script on SERVER


# # install packages from CRAN
install.packages("plumber")
install.packages("randomForest")
install.packages("jsonlite")
# install.packages("devtools")
# 
# # install our packages from local repo on vm
install.packages("digiterEmpty_0.1.0.tar.gz", repos = NULL, type = "source")
install.packages("digiterEmpty_0.1.0.tar.gz", repos = NULL, type = "source")
install.packages("digiterEmpty_0.1.0.tar.gz", repos = NULL, type = "source")

# not needed anymore: install our own packages from github repo
# to load models and predict functions from within the packages
# install_github("hkpf/op/digiterLarge")
# install_github("hkpf/op/digiterSmall")
# install_github("hkpf/op/digiterEmpty")

# load packages
library(plumber)
library(randomForest)
#library(devtools)
library(jsonlite)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

#setwd("C:/Users/soga/Desktop/op")
r <- plumb("deploy_rf_pkg.R")
r$run(port=80)

