output$worldMap <- renderLeaflet({
  
  
  ## source : https://datahub.io/core/geo-countries#r
  countries_map <- geojson_read("extdata/countries.geojson", what = "sp")
  
  ## Add Iso2C of Countries
  countries_map@data$countryCode <- countrycode::countrycode(sourcevar = countries_map@data %>% 
                                                        pull(ISO_A3), 
                                                        origin = "iso3c",
                                                        destination = "iso2c",
                                                        nomatch = NA,
                                                        warn = FALSE)
  
  ## Load data
  
  poland_data <- fread("extdata/full_data_poland.csv", header = TRUE) %>%
                  #select_if(function(x) !(all(is.na(x)) | all(x==""))) %>%
                  mutate(eventDate = as.POSIXct(eventDate,format="%Y-%m-%d")) %>%
                  mutate(modified = as.POSIXct(modified,format="%Y/%m/%d")) %>%
                  mutate(kingdom = if_else(kingdom == "", "Unknown", kingdom)) %>%
                  mutate(id = as.factor(id))%>%
                  mutate(eventTime = as.ITime(eventTime)) #%>%
                  #mutate(accessURI = if_else(is.na(accessURI), references, accessURI))
                 #mutate(royaume = if_else(kingdom == "Animalia", "Animal", "Plant"))

  
  
  countries_map@data <- countries_map@data %>%
                       left_join(poland_data , by ="countryCode")
  

  
  # Create a palette that maps factor levels to colors
  pal <- colorFactor(c("red",  "black", "forestgreen", "blue" ),
                     domain = c("Unknown","Fungi","Animalia", "Plantae"))
  
  # Set radius of circuleMarker
  radius <- poland_data %>%
            group_by(scientificName, family, longitudeDecimal,latitudeDecimal, eventDate, eventTime ) %>%
            summarise(Total_Obs = paste0(sum(individualCount),"=",paste0(individualCount, collapse = "+")),
                      Freq_Obs = n(), 
                      Dates = paste0(eventDate, collapse = ","),
                      Times = paste0(eventTime, collapse = ","),
                      .groups = 'drop') %>%
            ungroup()
  
  # Merge radius with poland data
  poland_data <- poland_data %>%
                left_join(radius, by = c("scientificName","family",
                                         "longitudeDecimal", "latitudeDecimal",
                                         "eventDate", "eventTime"))
  
  
  # used for groups
  poland_data_Animalia <- poland_data %>%
                          filter(kingdom %in% "Animalia")
  
  poland_data_Plantae <- poland_data %>%
                         filter(kingdom %in% "Plantae")
  
  poland_data_Fungi <- poland_data %>%
                        filter(kingdom %in% "Fungi")
  poland_data_Unknown <- poland_data %>%
                       filter(kingdom %in% "Unknown")
  
  # Confirmed.bins <-c(-Inf, 0, 100, 500)  #-100,1000, 15000, 80000
  # Confirmed.pal <- colorBin( c("blue","red",  "black", "forestgreen"),  #"#00FF00",
  #                            bins=Confirmed.bins, na.color = "#aaff56", alpha = TRUE)
  
  ## Start the map    
  leaflet(data =  countries_map) %>%  # countries_map
    
    addTiles() %>% 
    
    setView(lng= 20, lat=52, zoom  = 5.5 )%>%
    
    addProviderTiles(providers$Esri.WorldGrayCanvas, #CartoDB.DarkMatter, #  providers$CartoDB.Positron,
                     providerTileOptions(detectRetina = TRUE,
                                         reuseTiles = TRUE,
                                         minZoom = 4,
                                         maxZoom = 8)) %>%
    

    # ## Legend for Colors 
    # addLegend("bottomright", 
    #           pal = Confirmed.pal, 
    #           #labels=c("0-5K", "5-10K", "10-50K", "50-100K", "100-600K"),
    #           values = ~ poland_data$kingdom,
    #           title = "<small>Kingdom</small>", opacity = 0.8) %>%
    
    addLayersControl(
      position = "topleft", 
      overlayGroups = c("Animalia","Plantae","Fungi",
                        "Unknown"),
      options = layersControlOptions(collapsed = FALSE))%>%
    
    
    addCircles(data = poland_data_Animalia, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "Animalia",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Animalia$Freq_Obs),
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
                                     poland_data_Animalia$accessURI,
                                     poland_data_Animalia$kingdom,
                                     poland_data_Animalia$scientificName,
                                     poland_data_Animalia$vernacularName,
                                     poland_data_Animalia$family,
                                     poland_data_Animalia$Freq_Obs,
                                     poland_data_Animalia$Total_Obs,
                                     as.character(poland_data_Animalia$eventDate),
                                     as.character(poland_data_Animalia$eventTime),
                                     poland_data_Animalia$references)%>%lapply(htmltools::HTML),
                     popupOptions = labelOptions(
                       style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                    "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                     label = ~poland_data_Animalia$scientificName
                     # label = sprintf("
                     #          <img src= %s width='400'/>  <br/>
                     #          Sc.Name: <strong>%s</strong> <br/>
                     #          Ver.Name: <strong>%s</strong> <br/>",
                     #                 poland_data_Animalia$accessURI,
                     #                 poland_data_Animalia$scientificName,
                     #                 poland_data_Animalia$vernacularName)%>%lapply(htmltools::HTML),
                     # labelOptions = labelOptions(
                     #   style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                     #                "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)"))



    )%>%
    # addMarkers(data = poland_data_Animalia, lat = ~ latitudeDecimal ,
    #            lng = ~ longitudeDecimal,group = "Animalia",
    #            #group = poland_data_Animalia$scientificName,
    #            icon = makeIcon(#iconUrl = "http://leafletjs.com/examples/custom-icons/leaf-green.png",
    #                            iconWidth = 0, iconHeight = 0)) %>%
    
    addCircles(data = poland_data_Plantae, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "Plantae",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Plantae$Freq_Obs),
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
                                     poland_data_Plantae$accessURI,
                                     poland_data_Plantae$kingdom,
                                     poland_data_Plantae$scientificName,
                                     poland_data_Plantae$vernacularName,
                                     poland_data_Plantae$family,
                                     poland_data_Plantae$Freq_Obs,
                                     poland_data_Plantae$Total_Obs,
                                     as.character(poland_data_Plantae$eventDate),
                                     as.character(poland_data_Plantae$eventTime),
                                     poland_data_Plantae$references)%>%lapply(htmltools::HTML),
                     popupOptions = labelOptions(
                       style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                    "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                    label = ~poland_data_Plantae$scientificName
                    # label = sprintf("
                     #          <img src= %s width='400'/>  <br/>
                     #          Sc.Name: <strong>%s</strong> <br/>
                     #          Ver.Name: <strong>%s</strong> <br/>",
                     #                 poland_data_Plantae$accessURI,
                     #                 poland_data_Plantae$scientificName,
                     #                 poland_data_Plantae$vernacularName)%>%lapply(htmltools::HTML),
                     # labelOptions = labelOptions(
                     #   style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                     #                "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)"))
                     
                     
                     
    )%>%
    addCircles(data = poland_data_Fungi, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "Fungi",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Fungi$Freq_Obs),
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
                                     poland_data_Fungi$accessURI,
                                     poland_data_Fungi$kingdom,
                                     poland_data_Fungi$scientificName,
                                     poland_data_Fungi$vernacularName,
                                     poland_data_Fungi$family,
                                     poland_data_Fungi$Freq_Obs,
                                     poland_data_Fungi$Total_Obs,
                                     as.character(poland_data_Fungi$eventDate),
                                     as.character(poland_data_Fungi$eventTime),
                                     poland_data_Fungi$references)%>%lapply(htmltools::HTML),
                      popupOptions = labelOptions(
                        style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                     "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                     label = ~poland_data_Fungi$scientificName
                     # label = sprintf("
                     #          <img src= %s width='400'/>  <br/>
                     #          Sc.Name: <strong>%s</strong> <br/>
                     #          Ver.Name: <strong>%s</strong> <br/>",
                     #                 poland_data_Fungi$accessURI,
                     #                 poland_data_Fungi$scientificName,
                     #                 poland_data_Fungi$vernacularName)%>%lapply(htmltools::HTML),
                     # labelOptions = labelOptions(
                     #   style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                     #                "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)"))
                     
                     
                     
    )%>%
    addCircles(data = poland_data_Unknown, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "Unknown",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Unknown$Freq_Obs),
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
                                     poland_data_Unknown$accessURI,
                                     poland_data_Unknown$kingdom,
                                     poland_data_Unknown$scientificName,
                                     poland_data_Unknown$vernacularName,
                                     poland_data_Unknown$family,
                                     poland_data_Unknown$Freq_Obs,
                                     poland_data_Unknown$Total_Obs,
                                     as.character(poland_data_Unknown$eventDate),
                                     as.character(poland_data_Unknown$eventTime),
                                     poland_data_Unknown$references)%>%lapply(htmltools::HTML),
                      popupOptions = labelOptions(
                        style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                                     "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)")),
                     label = ~ poland_data_Unknown$scientificName
                     # label = sprintf("
                     #          <img src= %s width='400'/>  <br/>
                     #          Sc.Name: <strong>%s</strong> <br/>
                     #          Ver.Name: <strong>%s</strong> <br/>",
                     #                 poland_data_Unknown$accessURI,
                     #                 poland_data_Unknown$scientificName,
                     #                 poland_data_Unknown$vernacularName)%>%lapply(htmltools::HTML),
                     # labelOptions = labelOptions(
                     #   style = list("font-weight" = "normal", padding = "3px 8px", "color" = "#277a91", "font-family" = "arial",
                     #                "font-size" = "14px", direction = "auto","box-shadow" = "3px 3px rgba(0,0,0,0.25)"))
                     
                     
                     
    )%>%
    
    leaflet.extras::addResetMapButton() %>%
    leaflet.extras::addSearchFeatures(
      targetGroups = list("Animalia", "Plantae",
                          "Fungi", "Unknown"),
      options = searchFeaturesOptions(
                               propertyName = "label",
                               zoom = 12, openPopup = TRUE, firstTipSubmit = FALSE,
                           autoCollapse = FALSE, hideMarkerOnCollapse = TRUE )) %>%
    addControl("<P><B>Hint!</B> Search for ...<br/><ul><li>Podiceps</li>
           <li>Stachys</li><li>Lentinus</li><li>Thamnolia</li>
               </ul></P>",
               position = 'bottomright'
    )
  
  
})