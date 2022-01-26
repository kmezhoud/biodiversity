shinyServer(function(input, output, session) {
  
  vals <- reactiveValues(countries = NULL)
  
  ## stop shiny app when browser is closed
  session$onSessionEnded(function() {
    stopApp()
    print("Finished.")
  })
  

  
  # Create modal
  popupModal <- function(failed = FALSE) {
    modalDialog(
      selectizeInput(inputId = "countries_id",  list(icon("globe"), label = tags$b("Select Countries")),
                     choices = c("Poland"), 
                     multiple = TRUE),
      if (failed)
        div(tags$b("Please, Select countries", style = "color: red;")),
      
      footer = tagList(
        actionButton("cancel_id","Cancel"),
        actionButton("ok", "OK")
      )
    )
  }
  
  ## Show the popup
  showModal(popupModal())
  
  observeEvent(input$ok, {
    
    if (!is.null(input$countries_id) && nzchar(input$countries_id)) {
      vals$countries <- input$countries_id
      removeModal()
    } else {
      showModal(popupModal(failed = TRUE))
    }
  })
  
  observeEvent(input$cancel_id, {
      removeModal()
      print("cancel")
      stopApp()
      print("Finished.")
  })
  
  source("global.R", encoding = "UTF-8", local = TRUE)
  source("frontPage.R", encoding = "UTF-8", local = TRUE)
  source("frontPage_ui.R", encoding = "UTF-8", local = TRUE)
  })