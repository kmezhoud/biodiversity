<!-- README.md is generated from README.Rmd. Please edit that file! -->

# biodiversity Map Tracker <img src="inst/biodiversity/www/biodiversity.png" align="right" alt="containerit logo" width="200" style="padding: 0 0 10px 10px;" />

# How to install and run

```{r}
require(devtools)
install_github("kmezhoud/biodiversity")
library(biodiversity)
biodiversity()
```

<img src="inst/biodiversity/www/screenshot.png" align="right" alt="https://github.com/kmezhoud/biodiversity" width="400" style="padding: 0 0 10px 10px;" /><img src="biodiversity.gif" align="right" alt="https://github.com/kmezhoud/biodiversity" width="400" style="padding: 0 0 10px 10px;" />


# Keywords
+ Freq: How many time the Spacy was found in different place or date.time
+ Total: The sum of all individus

# Skills
+ biodiversity is a complete R package
  + Build/Check/Test package
+ Add Progressbar to inform the user what the app is doing
+ Add a Layout control panel for existing Kingdom
  + Rapid Overview of the position of Animals, PLants and Others
  + User can focus search on `Plantae` by checking Plantae
+ User can search by `vernacularName`, the app returns `scientificName` and vice versa.
+ Map Focusing process of selected item to the position
  + Indicate the position with red circle
  + Open popup with all needed information: 
    + External link to orginal data
    + Images
+ CSS styling with logos in header

# Deal with occurence.cvs

### locate the column of country
```{r}
read.table(file = "biodiversity-data/occurence.csv", header = TRUE,
              sep = ",", nrows = 1) %>%
  names() %>%
  stringr::str_locate(fixed("country", ignore_case=TRUE) ) %>%
  as_tibble()%>%
  tibble::rowid_to_column("index") %>%
  drop_na() %>%
  pull(index)

```
[1] 22 23

### Extract only rows with Poland in column 22 and save it to occurence_poland.csv
```{bash}
awk -F, '$22 ~ /^Poland/' "biodiversity-data/occurence.csv" > occurence_poland.csv
```

### Load only used columns from multimedia
```{r}
multimedia <- fread("biodiversity-data/multimedia.csv", header = TRUE,
                    select = c("CoreId", "accessURI")) %>%
  rename( id = CoreId) %>%
  mutate(id = as.factor(id))
```

### Join Files
```{r}

occurence <- fread("occurence_poland.csv", header = TRUE, sep= ',', 
                   select = c("id", "eventDate", "eventTime", "locality", "kingdom", "family",
                              "vernacularName", "scientificName", "longitudeDecimal", "individualCount", "latitudeDecimal", "countryCode","references"))
                              
occurence <- occurence %>%
              select_if(function(x) !(all(is.na(x)) | all(x==""))) %>%
              mutate(eventDate = as.POSIXct(eventDate,format="%Y-%m-%d")) %>%
              #mutate(modified = as.POSIXct(modified,format="%Y/%m/%d")) %>%
                tidyr::extract(col = locality, into = c("country", "locality"),
                             regex =  "([A-Z]+[a-z]+\\s)-(\\s[A-Z]+[a-z]+)",remove = TRUE)  %>%
               mutate(kingdom = if_else(kingdom == "", "Unknown", kingdom)) %>%
              mutate(id = as.factor(id), kingdom = as.factor(kingdom),
                     family = as.factor(family), locality = as.factor(locality),
                     vernacularName = as.factor(vernacularName),
                     scientificName = as.factor(scientificName)) 


full_data_poland <- occurence %>%
                    left_join(multimedia, by="id") 

```

# Issues
+ Loading countries.geojson file makes the app slowly
+ addSearchFeatures highlight multiple circles with same name
+ addSearchFeatures with multiple addCircles groups
+ All Kingdoms must be checked for the `addSearchFeatures`