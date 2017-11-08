# Run this script in VM command shell via: 
# sudo Rscript install_and_runport.R

# Windows VM: 
# setwd("C:/Users/soga/Desktop/op")

# Linux VM:
setwd("/home/soga/op")

# install packages from CRAN
install.packages("plumber")
install.packages("randomForest")
install.packages("jsonlite")

# install our packages from local repo on vm
install.packages("digiterEmpty_0.1.0.tar.gz", repos = NULL, type = "source")
install.packages("digiterEmpty_0.1.0.tar.gz", repos = NULL, type = "source")
install.packages("digiterEmpty_0.1.0.tar.gz", repos = NULL, type = "source")


# load packages
library(plumber)
library(randomForest)
library(jsonlite)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

# start webserver:
r <- plumb("deploy_rf_pkg.R")
r$run(port=8000)








