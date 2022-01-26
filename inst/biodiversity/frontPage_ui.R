
output$ui_frontPage <- renderUI({
  
  fluidRow(#div(style = "height:50px;"),
    
    column(width = 12,#style='height:200px',
           div(class="outer",
               tags$head(includeCSS("www/styles.css")),
               leafletOutput("worldMap", height = "700px"),
               absolutePanel(id = "confirmedID", class = "panel panel-default",
                             top = 300, left = 20, width = 45, fixed=FALSE,
                             draggable = TRUE, height =  45 ,#"auto",
                             # Make the absolutePanla collapsable
                             #HTML('<button data-toggle="collapse" data-target="#popup_id">Confirmed</button> '),
                             #tags$div(id = 'popup_id',  class="collapse",# style="text-align:center",
                             div(actionButton(inputId = "popup_id",label = "",
                                               icon = icon("globe"),
                                               style='background-color:transparent; border-color: transparent',),
                                 style = "font-size:100%") 
                             #)
               ),
               
               
           )
    )
  )
  
  
  
  
  
})