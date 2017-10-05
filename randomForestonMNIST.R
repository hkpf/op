## Read in data set ####
setwd("U:/soga/private/02_Projekte/00_Operationalisierung")
source("utilitiy_functions/readMNISTintoR.R")
d.mnist <- load_mnist()
str(d.mnist)

## Generate train and test data frame ####
m.train <- cbind(d.mnist$train$x$x, d.mnist$train$y)
str(m.train)

# column names
row <- as.character(rep(1:28, each = 28))
col <- as.character(rep(1:28, times = 28))
numbs <- paste(row, col, sep = ".")
c.names <- c(paste0(rep("X", length(numbs)), numbs),"Y") # Alternative: c.names <- c(paste0(rep("X", 784), 1:784), "Y")
head(c.names)
tail(c.names)
colnames(m.train) <- c.names
str(m.train)

# data frame
d.train <- as.data.frame(m.train)
str(d.train)

# generate test data frame analogously
m.test <- cbind(d.mnist$test$x$x, d.mnist$test$y)
str(m.test)
colnames(m.test) <- c.names
d.test <- as.data.frame(m.test)
str(d.test)


## Have a look at data ####
head(d.train)
range(d.train)       # the pixels have values between 0 and 255
range(d.train[,1])   # pixel 1 (=X1.1) is always 0 (="white")
range(d.train[,"X14.14"]) # pixel X14.14 obtains values between 0 and 255
sort(unique(d.train[,300]))
table(d.train[,300])

show_digit(d.mnist$train$x$x[5,])
show_digit(as.matrix(d.train[,-785])[5,]) # how does 5th observation (5th digit) look like?

par(mfrow = c(3,3))
sapply(1:9, function(i) show_digit(d.mnist$train$x$x[i,])) #for(i in 1:9){show_digit(d.mnist$train$x$x[i,])}


## Train Model on train data ####
library(randomForest)



## Predict label of test data

## ####
















