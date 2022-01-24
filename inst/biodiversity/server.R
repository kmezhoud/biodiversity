shinyServer(function(input, output, session) {
  
  
  ## stop shiny app when browser is closed
  session$onSessionEnded(function() {
    stopApp()
    print("Finished.")
  })
  
  source("global.R")
  

  })