output$worldMap <- renderLeaflet({
  
  
  ## source : https://datahub.io/core/geo-countries#r
  countries_map <- geojson_read("extdata/countries.geojson", what = "sp")
  
  ## Start the map    
  leaflet(data =  countries_map) %>%  # countries_map
    
    addTiles() %>% 
    
    setView(lng= 20, lat=52, zoom  = 5.5 )%>%
    
    addProviderTiles(providers$Esri.WorldGrayCanvas, #CartoDB.DarkMatter, #  providers$CartoDB.Positron,
                     providerTileOptions(detectRetina = TRUE,
                                         reuseTiles = TRUE,
                                         minZoom = 4,
                                         maxZoom = 8)) 
  
  
})