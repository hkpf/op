# Make Requests

There are many variants to make requests. In the Following three are listed to make GET/POST requests for R code

# 1. R

## Requirenments
* [R](https://cran.r-project.org/)

## Procedure for running

Some examples are shown 

* for **plumber** in */plumber/post_request_to_RESTApi.R*
* for **OpenCPU** in */openCPU/performanceTest.R*

Please try them!

# 2. Postman

## Requirenments
* [Postman](https://www.getpostman.com/)

## Procedure for running

1. Choose between GET and POST
2. Enter the request url
3. If you chose a POST request: Click to "Body" and enter your data.
4. If your request need an authorization, specialize an authorization!
5. Click "Send".

Example for POST request with

* **plumber**: In "Body" choose "raw" and enter a 784 (28x28) length vector with gray-scale values between 0-255 such as
 
```{r}
[0, 0, 0, 251, 251, 211, 31, 80, 181, 251, ..., 253, 251, 251, 251, 94, 96, 31, 95, 251, 211, 94, 59]
```

* **OpenCPU**: In "Body" choose "raw", choose "JSON(application/json)" and enter a 784 (28x28) length list with the label "image" and gray-scale values between 0-255 such as
```{r}
{
 "image" :  [0, 0, 0, 251, 251, 211, 31, 80, ..., 251, 251, 251, 94, 96, 31, 95, 251, 211, 94, 59]
}
```

# 3. Python

In Python the code mlbenchmark in IndustrialML is used. This code make for every REST API request three scenarios: "Accuracy", "Sequential Load" and "Concurrent Load". It gives as output a tabular of results.

## Requirenments
* Python3
* Optional: [Anaconda](https://docs.anaconda.com/)

## Code for running
We used Anaconda promp

1. Set working directory to mlbenchmark folder with `cd ~\mlbenchmark`
2. `pip install -r requirements.txt`
3. `python setup.py develop`
4. `py.test`


> ### @icon-exclamation-circle Change requests
> To change the running REST API requests one have to make changes in* ENVIRONMENTS = [...]* in file  *test/test_mnist.py* ! Besides, one have to choose the right environment for the different tools: "MNistEnvironment" for plumber, "OpencpuMNistEnv" for OpenCPU and "MSRServerMNistEnv" for MS ML Server (in the old days R Server).





