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
                     choices = c("Poland", "Switzerland"), 
                     multiple = TRUE),
      if (failed)
        div(tags$b("Please, Select Countries", style = "color: red;")),
      
      footer = tagList(
        actionButton("cancel_id","Cancel"),
        actionButton("ok", "OK")
      )
    )
  }
  
  ## Show the popup
  showModal(popupModal())
  
  ## Listening OK button
  observeEvent(input$ok, {
    if (!is.null(input$countries_id) && nzchar(input$countries_id)) {
      vals$countries <- input$countries_id
      removeModal()
    } else {
      showModal(popupModal(failed = TRUE))
    }
  })
  
  ## remove popup if cancel
  observeEvent(input$cancel_id, {
      removeModal()
      print("cancel")
      stopApp()
      print("Finished.")
  })
  
   ## iterate popup button  when we want to select others countries
   observeEvent(input$popup_id,ignoreInit = TRUE,{
    #updateActionButton(inputId = "popup_id", session = session)
     vals$countries <- NULL
    showModal(popupModal())

  })
  
  #source("global.R", encoding = "UTF-8", local = TRUE)
  source("frontPage.R", encoding = "UTF-8", local = TRUE)
  source("frontPage_ui.R", encoding = "UTF-8", local = TRUE)
  })