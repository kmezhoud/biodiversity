#' Launch biodiversity with default browser
#' @description Launch biodiversity with default browser
#' @return  shiny webpage
#' @usage biodiversity()
#'
#' @examples
#' ShinyApp <-  1
#' \dontrun{
#' biodiversity()
#' }
#'
#' @name biodiversity
#' @docType package
#' @import shiny leaflet leaflet.extras shinythemes shinydashboard
#' @import DBI RSQLite countrycode knitr tictoc
#' @import tidyverse data.table memoise promises future
#' @importFrom utils installed.packages
#' @rawNamespace import(geojsonio, except= c(validate))
#' @export

biodiversity <- function(){
  if("biodiversity" %in% installed.packages()){
    library(biodiversity)
    shiny::runApp(system.file("biodiversity", package = "biodiversity"),
                  launch.browser = TRUE, quiet = TRUE)
  }else{
    stop("Install and load biodiversity package before to run it.")
  }
}
