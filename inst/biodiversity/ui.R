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
                                       "Biodiversity")
                             
                  )
                  
))