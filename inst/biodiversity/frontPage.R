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
                 #mutate(royaume = if_else(kingdom == "Animalia", "Animal", "Plant"))

  
  countries_map@data <- countries_map@data %>%
                       left_join(poland_data , by ="countryCode")
  

  
  # Create a palette that maps factor levels to colors
  pal <- colorFactor(c("red",  "black", "forestgreen", "blue" ),
                     domain = c("Unknown","Fungi","Animalia", "Plantae"))
  
  # Set radius of circuleMarker
  radius <- poland_data %>%
            group_by(family, longitudeDecimal,latitudeDecimal ) %>%
            summarise(Total_family = sum(individualCount), Freq_family = n(), .groups = 'drop') %>%
            ungroup()
  
  poland_data <- poland_data %>%
    left_join(radius, by = c("family", "longitudeDecimal", "latitudeDecimal"))
  
  
  
  poland_data_Animalia <- poland_data %>%
                          filter(kingdom %in% "Animalia")
  
  poland_data_Plantae <- poland_data %>%
                         filter(kingdom %in% "Plantae")
  
  poland_data_Fungi <- poland_data %>%
                        filter(kingdom %in% "Fungi")
  poland_data_Unknown <- poland_data %>%
                       filter(kingdom %in% "Unknown")
  
  Confirmed.bins <-c(-Inf, 0, 100, 500)  #-100,1000, 15000, 80000
  Confirmed.pal <- colorBin( c("blue","red",  "black", "forestgreen"),  #"#00FF00",
                             bins=Confirmed.bins, na.color = "#aaff56", alpha = TRUE)
  
  ## Start the map    
  leaflet(data =  countries_map) %>%  # countries_map
    
    addTiles() %>% 
    
    setView(lng= 20, lat=52, zoom  = 5.5 )%>%
    
    addProviderTiles(providers$Esri.WorldGrayCanvas, #CartoDB.DarkMatter, #  providers$CartoDB.Positron,
                     providerTileOptions(detectRetina = TRUE,
                                         reuseTiles = TRUE,
                                         minZoom = 4,
                                         maxZoom = 8)) %>%
    

    ## Legend for Colors 
    addLegend("bottomright", 
              pal = Confirmed.pal, 
              #labels=c("0-5K", "5-10K", "10-50K", "50-100K", "100-600K"),
              values = ~ poland_data$kingdom,
              title = "<small>Kingdom</small>", opacity = 0.8) %>%
    
    addLayersControl(
      position = "topleft", 
      overlayGroups = c("<strong>Animalia</strong>","<strong>Plantae</strong>","<strong>Fungi</strong>",
                        "<strong>Unknown</strong>"),
      options = layersControlOptions(collapsed = FALSE))%>%
    
    
    addCircleMarkers(data = poland_data_Animalia, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "<strong>Animalia</strong>",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Animalia$Freq_family),
                     popup = ~vernacularName, label = ~higherClassification #scientificName



    )%>%
    addCircleMarkers(data = poland_data_Plantae, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "<strong>Plantae</strong>",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Plantae$Freq_family),
                     popup = ~vernacularName, label = ~higherClassification #scientificName
                     
                     
                     
    )%>%
    addCircleMarkers(data = poland_data_Fungi, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "<strong>Fungi</strong>",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Fungi$Freq_family),
                     popup = ~vernacularName, label = ~higherClassification #scientificName
                     
                     
                     
    )%>%
    addCircleMarkers(data = poland_data_Unknown, lat = ~ latitudeDecimal ,
                     lng = ~ longitudeDecimal, #layerId = ~circle_pt,
                     fillOpacity = 0.5 , 
                     group = "<strong>Unknown</strong>",
                     color = ~pal(kingdom),
                     stroke = FALSE,
                     radius = ~sqrt(poland_data_Unknown$Freq_family),
                     popup = ~vernacularName, label = ~higherClassification #scientificName
                     
                     
                     
    )%>%
    
    leaflet.extras::addResetMapButton() %>%
    leaflet.extras::addSearchFeatures(
      targetGroups = 'kingdom',
      options = leaflet.extras::searchFeaturesOptions(
        zoom=12, openPopup = TRUE, firstTipSubmit = TRUE,
        autoCollapse = TRUE, hideMarkerOnCollapse = TRUE )) 
  
  
})