
## Load data
#biodiversity_data <- read_rds("extdata/full_data_Poland_Switzerland_Germany_France_Spain_USA.rds") %>% 
get_biodiversity_data <- function(pays){
      # table_list <- NULL
      # for (i in pays){
      #   #Put each table in the list, one by one
      #   table_list[[i]] <- tbl(con,i) %>% as_tibble()
      # }

        lapply(pays, function(x) tbl(con,x)%>% as_tibble()) %>%
        #table_list %>%
        rbindlist() %>%
        as_tibble() %>%
  filter(grepl(paste0(pays, collapse = "|"), country, ignore.case = TRUE))%>% 
  mutate(eventDate = format(as.POSIXct(eventDate,format="%Y-%m-%dT%H:%M:%S"), '%Y-%m-%d'),
         individualCount = as.numeric(individualCount),
         longitudeDecimal = as.numeric(longitudeDecimal),
         latitudeDecimal = as.numeric(latitudeDecimal))%>%
  group_by(scientificName, family, longitudeDecimal,latitudeDecimal, eventDate, eventTime ) %>%
  mutate(Total_Obs = paste0(sum(individualCount, na.rm = TRUE),"=",paste0(individualCount, collapse = "+")),
         Freq_Obs = seq(n()), 
         Dates = unique(eventDate),
         Times = unique(paste0(eventTime)))%>%
  ungroup() %>%
  as.data.table()

}


geojson_read_fun <- function(){
  
    ##  Load Map source : https://datahub.io/core/geo-countries#r
    #countries_map <- geojson_read("extdata/countries.geojson", what = "sp")
    ##  Load map Faster
    geojson_read("https://raw.githubusercontent.com/johan/world.geo.json/master/countries.geo.json",what = "sp")
    
}
