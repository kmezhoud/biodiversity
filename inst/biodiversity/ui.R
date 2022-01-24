suppressMessages({
  library(shiny)
  library(shinythemes)
  library(leaflet)
  require(geojsonio)
  #library(apexcharter)
  #library(shinyWidgets)
  #library(shinyjs)
  #library(RMariaDB)
})

# source("frontPage_ui.R", encoding = "UTF-8", local = TRUE)
# source("frontPage.R", encoding = "UTF-8", local = TRUE)


shinyUI(fluidPage(theme = shinytheme("flatly"), title = "Biodiversity", #superhero, flatly
                  # Add CSS files
                  includeCSS(path = "www/AdminLTE.css"),
                  includeCSS(path = "www/shinydashboard.css"),
                  tags$head(includeCSS("www/styles.css")),
                  ## Include Appsilon logo at the right of the navbarPage
                  tags$head(tags$script(type="text/javascript", src = "logo.js" )),
                  ## Include Biodirsity logo
                  navbarPage(title=div(img(src="biodiversity.png", height = "50px", widht = "50px",
                                           style = "position: relative; top: -14px; right: 1px;"),
                                       "Biodiversity"),
                             
                             
                             tabPanel("Globe",icon = icon('globe'),
                                      div(class="outer",
                                          tags$head(includeCSS("www/styles.css")),
                                          
                                          uiOutput('ui_frontPage')
                                      )),
                             
                             navbarMenu("", icon = icon("question-circle"),
                                        tabPanel("About",icon = icon("info"),
                                                 withMathJax(includeMarkdown("extdata/help/about.md"))
                                                 #includeHTML("README.html")
                                        ),
                                        tabPanel("Help", "Blabla", icon = icon("question")), #uiOutput("help_ui")
                                        tabPanel(tags$a(
                                          "", href = "https://github.com/kmezhoud/biodiversity/-/issues", target = "_blank",
                                          list(icon("github"), "Report issue")
                                        )),
                                        tabPanel(tags$a(
                                          "", href = "https://github.com/kmezhoud/biodiversity", target = "_blank",
                                          list(icon("globe"), "Resources")
                                        ))
                             )
                   
                                       
                  )
))