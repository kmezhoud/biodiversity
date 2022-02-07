## InfoBox Animalia
output$ib_animalia <- renderInfoBox({
  
  if (is.null(vals$countries)){
    #"No countries selected"
    infoBox(title = tags$p("Animalia", style = "font-size: 100%;font-weight:bold"), 
            value = "", 
            subtitle =  "" , 
            icon = icon("paw", lib = "font-awesome"), 
            color = "red")
  }else{
    
    n_Animalia <- tbl(con,vals$countries) %>% as_tibble() %>%
      filter(kingdom %in% "Animalia") %>%
      group_by(scientificName) %>%
      summarise(n = n(),.groups = 'drop') %>%
      ungroup() %>%
      nrow()
    
    infoBox(title = tags$p("Animalia", style = "font-size: 100%;font-weight:bold"), 
            value = n_Animalia, 
            subtitle =  vals$countries , 
            icon = icon("paw", lib = "font-awesome"), 
            color = "red")
  }
})

## InfoBox Plantae
output$ib_plantae <- renderInfoBox({
  
  if (is.null(vals$countries)){
    #"No countries selected"
    infoBox(title = tags$p("Plantae", style = "font-size: 100%;font-weight:bold"), 
            value = "", 
            subtitle =  "" , 
            icon = icon("leaf", lib = "font-awesome"), 
            color = "olive")
  }else{
    
    n_Plantae <- tbl(con,vals$countries) %>% as_tibble() %>%
      filter(kingdom %in% "Plantae") %>%
      group_by(scientificName) %>%
      summarise(n = n(),.groups = 'drop') %>%
      ungroup() %>%
      nrow()
    
    infoBox(title = tags$p("PLantae", style = "font-size: 100%;font-weight:bold"), 
            value = n_Plantae, 
            subtitle =  vals$countries , 
            icon = icon("leaf", lib = "font-awesome"), 
            color = "olive")
  }
})

## InfoBox Fungi
output$ib_fungi <- renderInfoBox({
  
  if (is.null(vals$countries)){
    #"No countries selected"
    infoBox(title = tags$p("Fungi", style = "font-size: 100%;font-weight:bold"), 
            value = "", 
            subtitle =  "" , 
            icon = icon("cookie", lib = "font-awesome"), 
            color = "black")
  }else{
    
    n_Fungi <- tbl(con,vals$countries) %>% as_tibble() %>%
      filter(kingdom %in% "Fungi") %>%
      group_by(scientificName) %>%
      summarise(n = n(),.groups = 'drop') %>%
      ungroup() %>%
      nrow()
    
    infoBox(title = tags$p("Fungi", style = "font-size: 100%;font-weight:bold"), 
            value = n_Fungi, 
            subtitle =  vals$countries , 
            icon = icon("cookie", lib = "font-awesome"), 
            color = "black")
  }
})

## InfoBox authors
output$ib_Unknown <- renderInfoBox({
  
  if (is.null(vals$countries)){
    #"No countries selected"
    infoBox(title = tags$p("Others", style = "font-size: 100%;font-weight:bold"), 
            value = "", 
            subtitle =  "" , 
            icon = icon("question", lib = "font-awesome"), 
            color = "blue")
  }else{
    
    n_Unknown <- tbl(con,vals$countries) %>% as_tibble() %>%
      filter(kingdom %in% "Unknown") %>%
      group_by(scientificName) %>%
      summarise(n = n(),.groups = 'drop') %>%
      ungroup() %>%
      nrow()
    
    infoBox(title = tags$p("Others", style = "font-size: 100%;font-weight:bold"), 
            value = n_Unknown, 
            subtitle =  vals$countries , 
            icon = icon("question", lib = "font-awesome"), 
            color = "blue")
  }
})


output$worldMap <- renderLeaflet({
  
  if (is.null(vals$countries)){
    #"No countries selected"
  }else{
    
    m_geojson_read_fun <- memoise::memoise(geojson_read_fun, cache = session$cache)
    
    ## read map
    withProgress(message = 'Load the Geojson Map ...', value = 20, {
      countries_map <- m_geojson_read_fun()
    })
    # Create a color palette for kingdom 
    pal <- colorFactor(c("red",  "black", "forestgreen", "blue" ),
                       domain = c("Unknown","Fungi","Animalia", "Plantae"))
    
    
    
    withProgress(message = 'Load data set ...', value = 20, {
      biodiversity_data <- get_biodiversity_data(input$countries_id)
    })
    
    biodiversity_data_animalia <- biodiversity_data[kingdom == "Animalia"]
    biodiversity_data_plantae <- biodiversity_data[kingdom == "Plantae"]
    biodiversity_data_fungi <- biodiversity_data[kingdom == "Fungi"]
    biodiversity_data_unknown <- biodiversity_data[kingdom == "Unknown"]
    
    ## refresh memory
    remove(biodiversity_data)
    invisible(gc())
    
    withProgress(message = 'Display The Map ...', value = 20, {
      #print(paste0("Start of building the Map ", Sys.time()))
      ## Start the map  
      
      leaflet(data =  countries_map) %>%  
        
        addTiles() %>% 
        
        ##for Poland only
        #setView(lng= 20, lat=52, zoom  = 5.5 )%>%
        setView(lng= mean(biodiversity_data_animalia$longitudeDecimal),
                lat= mean(biodiversity_data_animalia$latitudeDecimal),
                zoom  = 5.5 )%>%
        ## for Poland and Switzerland
        #setView(lng= 18, lat=52, zoom  = 5.5 )%>%
        
        addProviderTiles(providers$Esri.WorldGrayCanvas, #CartoDB.DarkMatter, #  providers$CartoDB.Positron,
                         providerTileOptions(detectRetina = TRUE,
                                             reuseTiles = TRUE,
                                             minZoom = 4,
                                             maxZoom = 8)) %>%
        ## add checkBox from kingdom
        addLayersControl(
          position = "topleft", 
          overlayGroups = c("Animalia","Plantae","Fungi",
                            "Unknown"),
          options = layersControlOptions(collapsed = FALSE))%>%
        ## hide groups
        #hideGroup(c("Fungi","Unknown")) %>%
        ## add color legend for kingdom
        addLegend(colors = c("red", "forestgreen", "black",  "blue"), 
                  labels = c("Animalia","Plantae", "Fungi" , "Unknown"), opacity = 1) %>%
        
        #{if_else(nrow(biodiversity_data_Animalia)>0, 
        #purrr::when(nrow(biodiversity_data_Animalia)>0, ~
        ## add Animalia Circles
        addCircles(data = biodiversity_data_animalia, lat = ~ latitudeDecimal ,
                   lng = ~ longitudeDecimal,
                   fillOpacity = 0.5 ,
                   group = "Animalia",
                   color = ~pal(kingdom),
                   stroke = FALSE,
                   radius = ~sqrt(biodiversity_data_animalia$Freq_Obs),
                   popup = sprintf("
                              <img src= %s width='100'/>  <br/>
                              Kingdom: <strong>%s</strong>  <br/>
                              Sc.Name: <strong>%s</strong> <br/>
                              Ver.Name: <strong>%s</strong> <br/>
                              Family: <strong>%s</strong> <br/>
                              Freq: <strong>%g</strong> <br/>
                              Total: <strong>%s</strong> <br/>
                              Date: <strong>%s</strong> <br/>
                              Time: <strong>%s</strong> <br/>
                              Ref.: <strong> <a href = %s> Link </a> </strong> <br/>",
                                   biodiversity_data_animalia$accessURI,
                                   biodiversity_data_animalia$kingdom,
                                   biodiversity_data_animalia$scientificName,
                                   biodiversity_data_animalia$vernacularName,
                                   biodiversity_data_animalia$family,
                                   biodiversity_data_animalia$Freq_Obs,
                                   biodiversity_data_animalia$Total_Obs,
                                   as.character(biodiversity_data_animalia$eventDate),
                                   as.character(biodiversity_data_animalia$eventTime),
                                   biodiversity_data_animalia$references)%>%lapply(htmltools::HTML),
                   popupOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                  "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                   label = ~paste(biodiversity_data_animalia$scientificName,
                                  biodiversity_data_animalia$vernacularName))%>%
        
        addCircles(data = biodiversity_data_plantae, lat = ~ latitudeDecimal ,
                   lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                   fillOpacity = 0.5 ,
                   group = "Plantae",
                   color = ~pal(kingdom),
                   stroke = FALSE,
                   radius = ~sqrt(biodiversity_data_plantae$Freq_Obs),
                   popup = sprintf("
                              <img src= %s width='100'/>  <br/>
                              Kingdom: <strong>%s</strong>  <br/>
                              Sc.Name: <strong>%s</strong> <br/>
                              Ver.Name: <strong>%s</strong> <br/>
                              Family: <strong>%s</strong> <br/>
                              Freq: <strong>%g</strong> <br/>
                              Total: <strong>%s</strong> <br/>
                              Date: <strong>%s</strong> <br/>
                              Time: <strong>%s</strong> <br/>
                              Ref.: <strong> <a href = %s> Link </a> </strong> <br/>",
                                   biodiversity_data_plantae$accessURI,
                                   biodiversity_data_plantae$kingdom,
                                   biodiversity_data_plantae$scientificName,
                                   biodiversity_data_plantae$vernacularName,
                                   biodiversity_data_plantae$family,
                                   biodiversity_data_plantae$Freq_Obs,
                                   biodiversity_data_plantae$Total_Obs,
                                   as.character(biodiversity_data_plantae$eventDate),
                                   as.character(biodiversity_data_plantae$eventTime),
                                   biodiversity_data_plantae$references)%>%lapply(htmltools::HTML),
                   popupOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                  "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                   label = ~paste(biodiversity_data_plantae$scientificName,
                                  biodiversity_data_plantae$vernacularName)
        )%>%
        addCircles(data = biodiversity_data_fungi, lat = ~ latitudeDecimal ,
                   lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                   fillOpacity = 0.5 ,
                   group = "Fungi",
                   color = ~pal(kingdom),
                   stroke = FALSE,
                   radius = ~sqrt(biodiversity_data_fungi$Freq_Obs),
                   popup = sprintf("
                              <img src= %s width='100'/>  <br/>
                              Kingdom: <strong>%s</strong>  <br/>
                              Sc.Name: <strong>%s</strong> <br/>
                              Ver.Name: <strong>%s</strong> <br/>
                              Family: <strong>%s</strong> <br/>
                              Freq: <strong>%g</strong> <br/>
                              Total: <strong>%s</strong> <br/>
                              Date: <strong>%s</strong> <br/>
                              Time: <strong>%s</strong> <br/>
                              Ref.: <strong> <a href = %s> Link </a> </strong> <br/>",
                                   biodiversity_data_fungi$accessURI,
                                   biodiversity_data_fungi$kingdom,
                                   biodiversity_data_fungi$scientificName,
                                   biodiversity_data_fungi$vernacularName,
                                   biodiversity_data_fungi$family,
                                   biodiversity_data_fungi$Freq_Obs,
                                   biodiversity_data_fungi$Total_Obs,
                                   as.character(biodiversity_data_fungi$eventDate),
                                   as.character(biodiversity_data_fungi$eventTime),
                                   biodiversity_data_fungi$references)%>%lapply(htmltools::HTML),
                   popupOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                  "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                   label = ~paste(biodiversity_data_fungi$scientificName,
                                  biodiversity_data_fungi$vernacularName)
                   
        )%>%
        addCircles(data = biodiversity_data_unknown, lat = ~ latitudeDecimal ,
                   lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                   fillOpacity = 0.5 ,
                   group = "Unknown",
                   color = ~pal(kingdom),
                   stroke = FALSE,
                   radius = ~sqrt(biodiversity_data_unknown$Freq_Obs),
                   popup = sprintf("
                              <img src= %s width='100'/>  <br/>
                              Kingdom: <strong>%s</strong>  <br/>
                              Sc.Name: <strong>%s</strong> <br/>
                              Ver.Name: <strong>%s</strong> <br/>
                              Family: <strong>%s</strong> <br/>
                              Freq: <strong>%g</strong> <br/>
                              Total: <strong>%s</strong> <br/>
                              Date: <strong>%s</strong> <br/>
                              Time: <strong>%s</strong> <br/>
                              Ref.: <strong> <a href = %s> Link </a> </strong> <br/>",
                                   biodiversity_data_unknown$accessURI,
                                   biodiversity_data_unknown$kingdom,
                                   biodiversity_data_unknown$scientificName,
                                   biodiversity_data_unknown$vernacularName,
                                   biodiversity_data_unknown$family,
                                   biodiversity_data_unknown$Freq_Obs,
                                   biodiversity_data_unknown$Total_Obs,
                                   as.character(biodiversity_data_unknown$eventDate),
                                   as.character(biodiversity_data_unknown$eventTime),
                                   biodiversity_data_unknown$references)%>%lapply(htmltools::HTML),
                   popupOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                  "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                   label = ~paste(biodiversity_data_unknown$scientificName,
                                  biodiversity_data_unknown$vernacularName)
        )%>%
        leaflet.extras::addResetMapButton() %>%
        leaflet.extras::addSearchFeatures(
          targetGroups = list("Animalia", "Plantae",
                              "Fungi", "Unknown"),
          options = leaflet.extras::searchFeaturesOptions(
            propertyName = "label",
            zoom = 12, openPopup = TRUE, firstTipSubmit = FALSE,
            autoCollapse = FALSE, hideMarkerOnCollapse = TRUE )) %>%
        addControl("<P><B>Hint!</B> Search for ...<br/><ul><li>Fox-sedge</li>
           <li>Slow Worm</li><li>Lentinus</li><li>Thamnolia</li>
               </ul></P>",
                   position = 'bottomright'
        ) 
      
      
      
    })
  }
  
}) %>% bindCache(vals$countries, cache = "app")


