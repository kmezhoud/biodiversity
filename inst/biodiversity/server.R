

shinyServer(function(input, output, session) {

  
  vals <- reactiveValues(countries = NULL) 
  
  ## connect to db
  con <-  DBI::dbConnect(RSQLite::SQLite(), "extdata/biodiversity.db") 
  
  ## stop shiny app when browser is closed
  session$onSessionEnded(function() {
    stopApp()
    print("The biodiversity App is closed.")
  })
  

  
  # Create modal
  popupModal <- function(failed = FALSE) {
    modalDialog(
      selectizeInput(inputId = "countries_id",  list(icon("globe"), label = tags$b("Select Countries")),
                     choices = list("Europe" = c("Poland", "Switzerland"), 
                                    "America" = c("Spain", "Spain"),
                                    "Africa"= c("France", "France"), 
                                    "Asia" = c("Germany", "Germany")
                                    ), 
                     multiple = FALSE),
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
      print(paste0("NEW QUERY OF: ", input$countries_id))
    } else {
      showModal(popupModal(failed = TRUE))
    }
  })
  
  ## remove popup if cancel
  observeEvent(input$cancel_id, {
      removeModal()
      print("Canceled Search!")
      stopApp()
  })
  
   ## iterate popup button  when we want to select others countries
   observeEvent(input$popup_id,ignoreInit = TRUE,{
    #updateActionButton(inputId = "popup_id", session = session)
     vals$countries <- NULL
    showModal(popupModal())

  })
   
   # output$performance <- renderUI({
   #   #HTML(markdown::markdownToHTML(knit('extdata/help/performance.Rmd', quiet = TRUE)))
   #   includeHTML("https://kmezhoud.github.io/learn_by_example/biodiversity_performance/biodiversity_performance.html")
   # })
  
  source("global.R", encoding = "UTF-8", local = TRUE)
   tic("sourcing frontPage")
  source("frontPage.R", encoding = "UTF-8", local = TRUE)
   toc()
  tic("sourcing frontPage_ui")
  source("frontPage_ui.R", encoding = "UTF-8", local = TRUE)
   toc()
   
   
  })