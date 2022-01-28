output$worldMap <- renderLeaflet({
  
  if (is.null(vals$countries)){
    #"No countries selected"
  }else{
  withProgress(message = 'Loading Map ...', value = 0, {
  ##  Load Map source : https://datahub.io/core/geo-countries#r
  #countries_map <- geojson_read("extdata/countries.geojson", what = "sp")
  ##  Load map Faster
  countries_map <- geojson_read("https://raw.githubusercontent.com/johan/world.geo.json/master/countries.geo.json", what = "sp")
  

  })
  withProgress(message = 'Reading File ...', value = 0, {
    
  ## Load data
  biodiversity_data <- #readRDS("extdata/full_data_poland.rds") %>%
                 #mutate(eventDate = format(as.POSIXct(eventDate,format="%Y-%m-%d %H:%M:%S"), '%Y-%m-%d')) %>%
               fread("extdata/full_data_poland_Switzerland.csv", header = TRUE, showProgress = TRUE) %>%
                mutate(eventDate = format(as.POSIXct(eventDate,format="%Y-%m-%dT%H:%M:%S"), '%Y-%m-%d'))%>%
                filter(grepl(paste0(input$countries_id, collapse = "|"), country, ignore.case = TRUE))%>% 
                #select_if(function(x) !(all(is.na(x)) | all(x==""))) %>%
                mutate(eventDate = as.POSIXct(eventDate,format="%Y-%m-%d")) #%>
                #  mutate(modified = as.POSIXct(modified,format="%Y/%m/%d")) %>%
                 #  mutate(kingdom = if_else(kingdom == "", "Unknown", kingdom)) %>%
                 #  mutate(id = as.factor(id))%>%
                 #  mutate(eventTime = as.ITime(eventTime)) #%>%
                 #  #mutate(accessURI = if_else(is.na(accessURI), references, accessURI))
                 # #mutate(royaume = if_else(kingdom == "Animalia", "Animal", "Plant"))
  })
  
  
  withProgress(message = 'Data Processing ...', value = 0, {
  ## Add Iso2C of Countries
  # countries_map@data$countryCode <- countrycode::countrycode(sourcevar = countries_map@data %>% 
  #                                                              pull(ISO_A3), 
  #                                                            origin = "iso3c",
  #                                                            destination = "iso2c",
  #                                                            nomatch = NA,
  #                                                            warn = FALSE)
  
  #countries_map@data <- countries_map@data %>%
  #                     left_join(biodiversity_data , by ="countryCode")
  

  
  # Create a color palette for kingdom 
  pal <- colorFactor(c("red",  "black", "forestgreen", "blue" ),
                     domain = c("Unknown","Fungi","Animalia", "Plantae"))
  
  # Set radius of circuleMarker
  radius <- biodiversity_data %>%
            group_by(scientificName, family, longitudeDecimal,latitudeDecimal, eventDate, eventTime ) %>%
            summarise(Total_Obs = paste0(sum(individualCount),"=",paste0(individualCount, collapse = "+")),
                      Freq_Obs = seq(n()), 
                      Dates = paste0(eventDate, collapse = ","),
                      Times = paste0(eventTime, collapse = ","),
                      .groups = 'drop') %>%
            ungroup()
  
  # Merge radius with poland data
  biodiversity_data <- biodiversity_data %>%
                        left_join(radius, by = c("scientificName","family",
                                                  "longitudeDecimal", "latitudeDecimal",
                                                    "eventDate", "eventTime"))
  
  
  # used for groups
  biodiversity_data_Animalia <- biodiversity_data %>%
                          filter(kingdom %in% "Animalia")
  
  biodiversity_data_Plantae <- biodiversity_data %>%
                         filter(kingdom %in% "Plantae")
  
  biodiversity_data_Fungi <- biodiversity_data %>%
                        filter(kingdom %in% "Fungi")
  biodiversity_data_Unknown <- biodiversity_data %>%
                       filter(kingdom %in% "Unknown")
  
  remove(biodiversity_data)

  })
  
  withProgress(message = 'Ploting ...', value = 0, {
  ## Start the map    
  leaflet(data =  countries_map) %>%  # countries_map
    
    addTiles() %>% 
    
    ##for Poland only
    #setView(lng= 20, lat=52, zoom  = 5.5 )%>%
    setView(lng= mean(biodiversity_data_Animalia$longitudeDecimal),
            lat= mean(biodiversity_data_Animalia$latitudeDecimal),
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
    ## add color legend for kingdom
    addLegend(colors = c("red", "forestgreen", "black",  "blue"), 
              labels = c("Animalia","Plantae", "Fungi" , "Unknown"), opacity = 1) %>%
    ## add Animalia Circles
    addCircles(data = biodiversity_data_Animalia, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 ,
                     group = "Animalia",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(biodiversity_data_Animalia$Freq_Obs),
                     #popup = ~vernacularName,
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
                                     biodiversity_data_Animalia$accessURI,
                                     biodiversity_data_Animalia$kingdom,
                                     biodiversity_data_Animalia$scientificName,
                                     biodiversity_data_Animalia$vernacularName,
                                     biodiversity_data_Animalia$family,
                                     biodiversity_data_Animalia$Freq_Obs,
                                     biodiversity_data_Animalia$Total_Obs,
                                     as.character(biodiversity_data_Animalia$eventDate),
                                     as.character(biodiversity_data_Animalia$eventTime),
                                     biodiversity_data_Animalia$references)%>%lapply(htmltools::HTML),
                     popupOptions = labelOptions(
                       style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                    "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                     label = ~paste(biodiversity_data_Animalia$scientificName,
                                     biodiversity_data_Animalia$vernacularName)



    )%>%
    addCircles(data = biodiversity_data_Plantae, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 ,
                     group = "Plantae",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(biodiversity_data_Plantae$Freq_Obs),
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
                                     biodiversity_data_Plantae$accessURI,
                                     biodiversity_data_Plantae$kingdom,
                                     biodiversity_data_Plantae$scientificName,
                                     biodiversity_data_Plantae$vernacularName,
                                     biodiversity_data_Plantae$family,
                                     biodiversity_data_Plantae$Freq_Obs,
                                     biodiversity_data_Plantae$Total_Obs,
                                     as.character(biodiversity_data_Plantae$eventDate),
                                     as.character(biodiversity_data_Plantae$eventTime),
                                     biodiversity_data_Plantae$references)%>%lapply(htmltools::HTML),
                     popupOptions = labelOptions(
                       style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                    "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                    label = ~paste(biodiversity_data_Plantae$scientificName,
                                   biodiversity_data_Plantae$vernacularName)
    )%>%
    addCircles(data = biodiversity_data_Fungi, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 ,
                     group = "Fungi",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(biodiversity_data_Fungi$Freq_Obs),
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
                                     biodiversity_data_Fungi$accessURI,
                                     biodiversity_data_Fungi$kingdom,
                                     biodiversity_data_Fungi$scientificName,
                                     biodiversity_data_Fungi$vernacularName,
                                     biodiversity_data_Fungi$family,
                                     biodiversity_data_Fungi$Freq_Obs,
                                     biodiversity_data_Fungi$Total_Obs,
                                     as.character(biodiversity_data_Fungi$eventDate),
                                     as.character(biodiversity_data_Fungi$eventTime),
                                     biodiversity_data_Fungi$references)%>%lapply(htmltools::HTML),
                      popupOptions = labelOptions(
                        style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                     "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                     label = ~paste(biodiversity_data_Fungi$scientificName,
                                    biodiversity_data_Fungi$vernacularName)

    )%>%
    addCircles(data = biodiversity_data_Unknown, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 ,
                     group = "Unknown",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(biodiversity_data_Unknown$Freq_Obs),
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
                                     biodiversity_data_Unknown$accessURI,
                                     biodiversity_data_Unknown$kingdom,
                                     biodiversity_data_Unknown$scientificName,
                                     biodiversity_data_Unknown$vernacularName,
                                     biodiversity_data_Unknown$family,
                                     biodiversity_data_Unknown$Freq_Obs,
                                     biodiversity_data_Unknown$Total_Obs,
                                     as.character(biodiversity_data_Unknown$eventDate),
                                     as.character(biodiversity_data_Unknown$eventTime),
                                     biodiversity_data_Unknown$references)%>%lapply(htmltools::HTML),
                      popupOptions = labelOptions(
                        style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                     "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                     label = ~paste(biodiversity_data_Unknown$scientificName,
                                    biodiversity_data_Unknown$vernacularName)
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
})