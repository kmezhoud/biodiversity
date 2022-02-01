output$ui_frontPage <- renderUI({
  
  tagList(
    
  fluidRow(
      column(width = 12, #style='height:80px',
             splitLayout(
               infoBoxOutput("ib_animalia", width = 2.5),
               infoBoxOutput("ib_plantae", width = 2.5),
               infoBoxOutput("ib_fungi", width = 2.5),
               infoBoxOutput("ib_Unknown", width = 2.5)
             ),tags$style("#dri {width:110px;}")
      )
    ),
  
  fluidRow(#div(style = "height:50px;"),
    
    column(width = 12,#style='height:200px',
           div(class="outer",
               tags$head(includeCSS("www/styles.css")),
               leafletOutput("worldMap", height = "600px"),
               absolutePanel(id = "panel_id", class = "panel panel-default",
                             top = 300, left = 20, width = 45, fixed=FALSE,
                             draggable = TRUE, height =  45 ,#"auto",
                             # Make the absolutePanla collapsable
                             #HTML('<button data-toggle="collapse" data-target="#popup_id">Country</button> '),
                             #tags$div(id = 'popup_id',  class="collapse",#style='background-color:transparent; border-color: transparent',
                             div(actionButton(inputId = "popup_id",label = "",
                                               icon = icon("globe"),
                                               style='background-color:transparent; border-color: transparent',),
                                 style = "font-size:100%") 
                             #)
               ),
               
               
           )
    )
  )
  )
  
  
})