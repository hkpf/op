# Functions to load the MNIST digit recognition dataset into R
# creates train$n, train$x, train$y  and test$n, test$x, test$y
# e.g. train$x is a 60000 x 784 matrix, each row is one digit (28x28)
# brendan o'connor - gist.github.com/39760 - anyall.org
# https://gist.github.com/sboysel/3fed0a36a5b231278089#file-load_mnist-r

## Functions to read mnist data into R ####

# load_mnist() reads the data set from the homepage into R all by itself
# Usage:
# d.mnist <- load_mnist()
load_mnist <- function(path = "mnist") {
  mnist_url <- list(train_images = paste0("http://yann.lecun.com/exdb/mnist/",
                                          "train-images-idx3-ubyte.gz"),
                    train_labels = paste0("http://yann.lecun.com/exdb/mnist/",
                                          "train-labels-idx1-ubyte.gz"),
                    test_images = paste0("http://yann.lecun.com/exdb/mnist/",
                                         "t10k-images-idx3-ubyte.gz"),
                    test_labels = paste0("http://yann.lecun.com/exdb/mnist/",
                                         "t10k-labels-idx1-ubyte.gz"))
  if (!dir.exists(path)) {
    dir.create(path)
    lapply(mnist_url, function(x) {
      download.file(url = x, destfile = file.path(path, basename(x)))
    })
  }
  load_image_file <- function(filename) {
    ret <- list()
    f <- gzfile(filename, "rb")
    readBin(f, "integer", n = 1, size = 4, endian = "big")
    ret$n <- readBin(f, "integer", n = 1, size = 4, endian = "big")
    nrow <- readBin(f, "integer", n = 1, size = 4, endian = "big")
    ncol <- readBin(f, "integer", n = 1, size = 4, endian = "big")
    x <- readBin(f, "integer", n = ret$n * nrow * ncol, size = 1, signed = F)
    ret$x <- matrix(x, ncol = nrow * ncol, byrow = T)
    close(f)
    return(ret)
  }
  load_label_file <- function(filename) {
    f <- gzfile(filename, "rb")
    readBin(f, "integer", n = 1, size = 4, endian = "big")
    n <- readBin(f, "integer", n = 1, size = 4, endian = "big")
    y <- readBin(f, "integer", n = n, size = 1, signed = F)
    close(f)
    return(y)
  }
  tr <- file.path(path, "train-images-idx3-ubyte.gz")
  ts <- file.path(path, "t10k-images-idx3-ubyte.gz")
  tr_l <- file.path(path, "train-labels-idx1-ubyte.gz")
  ts_l <- file.path(path, "t10k-labels-idx1-ubyte.gz")
  mnist <- list()
  message("Loading Training Data...")
  mnist$train$x <- load_image_file(tr)
  message("Loading Testing Data...")
  mnist$test$x <- load_image_file(ts)
  message("Loading Training Labels...")
  mnist$train$y <- load_label_file(tr_l)
  message("Loading Testing Labels...")
  mnist$test$y <- load_label_file(ts_l)
  return(mnist)
}

# show_digit() displays one observation (= one digit) nicely plotted
# usage:  
# show_digit(train$x[5,]) to see a digit.
show_digit <- function(arr784, col = gray(12:1 / 12), ...) {
  image(matrix(arr784, nrow = 28)[, 28:1], col = col, ...)
}

