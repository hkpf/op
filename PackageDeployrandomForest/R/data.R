#' @title Trained model of MNIST dataset
#'
#' A model which was trained from 60000 pictures of the MNiST digit recognition dataset.
#' The MNIST digit recognition dataset in R #' is divided in  train$n, train$x, train$y  and
#' test$n, test$x, test$y #' e.g. train$x is a 60000 x 784 matrix, each row is one digit (28x28)
#' brendan o'connor - gist.github.com/39760 - anyall.org
#' https://gist.github.com/sboysel/3fed0a36a5b231278089#file-load_mnist-r
#' @name data
#' @format A RSA-file (model) which was trained from 60000 pictures of the MNIST dataset:
#'
#' @source \url{https://gist.github.com/sboysel/3fed0a36a5b231278089#file-load_mnist-r}
"model"
