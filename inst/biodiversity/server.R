shinyServer(function(input, output, session) {
  
  
  ## stop shiny app when browser is closed
  session$onSessionEnded(function() {
    stopApp()
    print("Finished.")
  })
  
  source("global.R", encoding = "UTF-8", local = TRUE)
  source("frontPage.R", encoding = "UTF-8", local = TRUE)
  source("frontPage_ui.R", encoding = "UTF-8", local = TRUE)
  })