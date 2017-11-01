##########################################################
#       Create & Test a Logistic Regression Model        #
##########################################################

# Use logistic regression equation of vehicle transmission 
# in the data set mtcars to estimate the probability of 
# a vehicle being fitted with a manual transmission 
# based on horsepower (hp) and weight (wt)

# If on R Server 9.0, load mrsdeploy package now
library(mrsdeploy)

# Create glm model with `mtcars` dataset
carsModel <- glm(formula = am ~ hp + wt, data = mtcars, family = binomial)

# Produce a prediction function that can use the model
manualTransmission <- function(hp, wt) {
    newdata <- data.frame(hp = hp, wt = wt)
    predict(carsModel, newdata, type = "response")
}

# test function locally by printing results
print(manualTransmission(120, 2.8)) # 0.6418125

##########################################################
#            Log into Server                 #
##########################################################

# Use `remoteLogin` to authenticate with Server using 
# the local admin account. Use session = false so no 
# remote R session started
remoteLogin("http://lin-op-vm.westeurope.cloudapp.azure.com:12800", 
                        session = FALSE)
# user: admin
# pw: ...OnBo.

##########################################################
#             Publish Model as a Service                 #
##########################################################

# Generate a unique serviceName for demos 
# and assign to variable serviceName
serviceName <- paste0("mtService", round(as.numeric(Sys.time()), 0))

# Publish as service using publishService() function from 
# mrsdeploy package. Name service "mtService" and provide
# unique version number. Assign service to the variable `api`
ll <- list(hp = "numeric", wt = "numeric")

api <- publishService(
    serviceName,
    code = manualTransmission,
    model = carsModel,
    inputs = ll,
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)

api2 <- publishService(
    serviceName,
    code = manualTransmission,
    model = carsModel,
    #inputs = list(hp = "numeric", wt = "numeric"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)

api3 <- publishService(
    serviceName,
    code = manualTransmission,
    model = carsModel,
    inputs = list("numeric", "numeric"),
    outputs = list(answer = "numeric"),
    v = "v1.0.0"
)

##########################################################
#                 Consume Service in R                   #
##########################################################

# Print capabilities that define the service holdings: service 
# name, version, descriptions, inputs, outputs, and the 
# name of the function to be consumed
print(api$capabilities())

# Consume service by calling function, `manualTransmission`
# contained in this service
result <- api$manualTransmission(120, 2.8)

# Print response output named `answer`
print(result$output("answer")) # 0.6418125   

##########################################################
#         Get Service-specific Swagger File in R         #
##########################################################

# During this authenticated session, download the  
# Swagger-based JSON file that defines this service
swagger <- api$swagger()
cat(swagger, file = "swagger.json", append = FALSE)

# Now share this Swagger-based JSON so others can consume it


##########################################################
#          Delete service version when finished          #
##########################################################

# User who published service or user with owner role can
# remove the service when it is no longer needed
status <- deleteService(serviceName, "v1.0.0")
status

##########################################################
#                   Log off of R Server                  #
##########################################################

# Log off of R Server
remoteLogout()






# Return metadata for all services hosted on this server
serviceAll <- listServices()

# Return metadata for all versions of service "mtService" 
mtServiceAll <- listServices("mtService")

# Return metadata for version "v1" of service "mtService" 
mtService <- listServices("mtService", "v1")

# View service capabilities/schema for mtService v1. 
# For example, the input schema:
#   list(name = "wt", type = "numeric")
#   list(name = "dist", type = "numeric")
print(mtService)