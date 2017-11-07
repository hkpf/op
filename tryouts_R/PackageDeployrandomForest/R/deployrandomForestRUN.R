#'operationalization: SERVER side RUN
#'
#'Start a locally REST Api gateway by using plumber. Usally one should use port=8000.
#'
#'@param x A numeric value which defines the port. Usally one should use x=8000.
#'@import plumber
#'@return Start a locally REST Api gateway.
#'@export
#'
start_api_plumber <- function(x){
    r <- plumber::plumb(system.file("deployrandomForest.R", package = "PackageDeployrandomForest")) #plumber::plumb("C:/Users/vepo/Documents/GitRepo/operationalisierung/PackageDeployrandomForest/R/deployrandomForest.R")
    r$run(port=x) #r$run(port=8000)
    }

# Usage: run(8000)
