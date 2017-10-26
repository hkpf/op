# Run this script on SERVER

#install package plumber because of dependencies
install.packages("plumber")

# load packages
library(plumber)
library(randomForest)
library(jsonlite)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

hello <- function( name ) {
    sprintf( "Hello, %s", name );
}

hello("John")

r <- plumb("deploy_rf_pkg.R")
r$run(port=80)

