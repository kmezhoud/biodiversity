
output$ui_frontPage <- renderUI({
  
  fluidRow(#div(style = "height:50px;"),
    
    column(width = 12,#style='height:200px',
           div(class="outer",
               tags$head(includeCSS("www/styles.css")),
               leafletOutput("worldMap", height = "600px")
               
           )
    )
  )
  
  
  
  
  
})