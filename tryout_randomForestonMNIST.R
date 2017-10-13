## Read in data set ####
setwd("~/02_Projekte/00_Operationalisierung/operationalisierung")
source("utilitiy_functions/readMNISTintoR.R")
l.mnist <- load_mnist()
str(l.mnist)

m.train.predictors <- l.mnist$train$x$x
m.train.labels <- l.mnist$train$y
m.test.predictors <- l.mnist$test$x$x
m.test.labels <- l.mnist$test$y

## not necessary: Generate train and test data frame ####
m.train <- cbind(l.mnist$train$x$x, l.mnist$train$y)
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
d.train$Y <- as.factor(d.train$Y)
str(d.train)
str(d.train[,785])
colnames(d.train)

# generate test data frame analogously
m.test <- cbind(l.mnist$test$x$x, l.mnist$test$y)
str(m.test)
colnames(m.test) <- c.names
d.test <- as.data.frame(m.test)
d.test$Y <- as.factor(d.test$Y)
str(d.test)


## Have a look at data ####
head(d.train)
range(d.train)       # the pixels have values between 0 and 255
range(d.train[,1])   # pixel 1 (=X1.1) is always 0 (="white")
# check out pixel in middle of picture (row 14, col 14)
range(d.train[,"X14.14"]) # pixel X14.14 obtains values between 0 and 255
sort(unique(d.train[,"X14.14"])) 
table(d.train[,"X14.14"])
# visualize one observation (image of one digit)
# how does 5th observation (5th digit) look like?
show_digit(d.mnist$train$x$x[5,])
show_digit(as.matrix(d.train[,-785])[5,]) 

par(mfrow = c(3,3))
sapply(1:9, function(i) show_digit(d.mnist$train$x$x[i,])) #for(i in 1:9){show_digit(d.mnist$train$x$x[i,])}


## Train Model on train data ####
library(randomForest)
n <- 1000 # 10000 ca. 1h
set.seed(1)
sys.time.seq <- system.time(
        model.rf <- randomForest(x = d.train[1:n, -785], y = d.train[1:n, 785], do.trace = TRUE) #viel schneller als mit matrix?!
)[3]

sys.time.seq <- system.time(
    model.rf <- randomForest(x = m.train.predictors[1:n,], y = m.train.labels[1:n], do.trace = TRUE) # langsam
)[3]


m.train.predictors <- l.mnist$train$x$x
m.train.labels


summary(model.rf)
saveRDS(model.rf, file = paste0("model_rf_", n, ".rds")) 
model.saved <- readRDS(file = paste0("model_rf_", n, ".rds"))

# Parallelized Random Forests ####
library(randomForest)
library(doParallel)  # works for Windows as well
#no_cores <- detectCores() - 1  # 8 cores on this laptop
no_cores <- 2
cl <- makeCluster(no_cores)  
registerDoParallel(cl) 
sys.time.par <- system.time(
        rf <- foreach(ntree=rep(250, 2), .combine=combine, .multicombine=TRUE,
                      .packages='randomForest') %dopar% {
                          randomForest(x=d.train[1:n, -785],
                                       y=d.train[1:n, 785],
                                       ntree=ntree, do.trace = TRUE)
        }
)[3]
stopCluster(cl)

## Predict label of test data
?predict.randomForest
pred1 <- predict(model.saved, newdata = d.test[1,-785], type = "response") # test set as data frame
pred2 <- predict(model.saved, newdata = m.test[1:2,], type = "response") # test set as matrix
pred2 <- predict(model.saved, newdata = m.test[1], type = "response") # not working
str(pred1) # factor
unbox(as.numeric(as.character(pred1)))

confusion.matrix <- table(true = d.test$Y, predicted = pred)
diag(confusion.matrix) <- 0
error.rate <- sum(confusion.matrix)/nrow(d.test)
accuracy <- (1-error.rate)


















