---
title: "Shiny Developer Challenge @Appsilon"
output: html_notebook
editor_options: 
  chunk_output_type: inline
---


# How to install and run

Before to install, please try to [demo](https://kmezhoud.shinyapps.io/biodiversity/) version.

### R Environment

```{r}
require(devtools)
install_github("kmezhoud/biodiversity"
library(biodiversity)
biodiversity()
```
### Docker Image

#### How to build Docker Image

Navigate to  where `Dockerfile` and `DESCRIPTION` folder.

```{bash}
docker build --tag biodiversity .
docker tag biodiversity kmezhoud/biodiversity:poland
docker push kmezhoud/biodiversity:poland
```
#### How to run
```{bash}
 docker login -u kmezhoud
 # run local
 # docker run -d -p  3838:3838 kmezhoud/biodiversity
 # run from dockerHub 
 docker run -d -p  3838:3838 kmezhoud/biodiversity:poland
```

# Extras Skills

+ biodiversity is a complete R package
  + Build/Check/Test package
+ Add popup to select interested countries to focus on. 
  + Reduce waiting time and improve reactivity of the App.
  + Limit functionalities to wanted countries
+ Add Progressbar to inform the user what the app is doing
+ Add a Layout control panel for existing Kingdom
  + Rapid Overview of the position of Animals, Plants and Others
  + User can focus search by Kingdom
+ User can search by `vernacularName`, the app returns `scientificName` and vice versa.
+ Map Focusing process of selected item to the position
  + Indicate the position with red circle
  + Open popup with all needed information: 
    + External link to orginal data
    + Images
+ CSS styling with logos in header, Absolute Panel with transparent Button

<br>

<br>

<br>

<br>

# Deal with occurence.cvs and multimedia.csv

### Locate the column of country
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

saveRDS(full_data_poland, file = "inst/biodiversity/extdata/full_data_poland.rds")
```

# Keywords
+ Freq: How many time the Spacy was found in different place or date.time
+ Total: The sum of all individus
+ We can add any needed informations in Popups.

# Issues
+ **Cannot deploy the App to shinyapp.io with Poland and Switzerland data**
+ Loading countries.geojson file makes the app slowly
  + Use simpliest map
+ addSearchFeatures highlight multiple circles with same name
  + In some case Image not found in app but exists in Link (case red Fox)
+ addSearchFeatures with multiple addCircles groups
  + All Kingdoms must be checked for the `addSearchFeatures`
+ Extend the app to others countries by passing the name of countries as an argument `biodiversity(countries = c("Poland", "Germany"))`
  + Not a good idea if we deploy app in server.
    + Use instead popup with `selectInput` of countries at the starting.
+ AddCircles from groups (Fungi and Unknown) that not exist in selected country 
+ The number of Kingdoms in countries is not the same. `addCircles` not working with empty dataframe
+ Display Map after `Ploting...` progressBar takes long time if there are a lot of CircleMarkers

# To Do
+ Extend countries to Provinces and Localities: improve precision and search.
+ Subset each country in CSV/RDS file /extdata and load only selected countries
+ Map focus and zoom to first selected country
+ Add botton to the map to iterate countries selection
+ Dockerize the App

# Deploy App using Cloud and Shiny Server

The shiny App can be deployed in any Cloud service like [DigitalOcean](https://www.digitalocean.com/) with Ubuntu server.

```{bash}
# connect to the remote server
ssh remote_username@remote_host
#add user with root privilege
adduser kirus
gpasswd -a kirus sudo
su - kirus
# install nginx
sudo apt-get update
sudo apt-get -y install nginx
# Set virtual domain name
# add source for most recent version of R  for ubuntu 18.04
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran40/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9
gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -
# install R
sudo apt-get update
sudo apt-get -y install r-base
# install useful packages
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev
sudo su - -c "R -e \"install.packages('promises', repos='http://cran.rstudio.com/')\""
# install rstudio server
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.4.1106-amd64.deb
sudo gdebi rstudio-server-1.4.1106-amd64.deb
# check browser at 10.11.12.121:8787/

# install shiny server
sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('rmarkdown', repos='http://cran.rstudio.com/')\""
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.15.953-amd64.deb
sudo gdebi shiny-server-1.5.15.953-amd64.deb
# chack browser at http://10.11.12:3838/

# install biodiversity dependencies
sudo su - -c "R -e \"install.packages(c('shiny','shinytheme'), repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages(c('leaflet', 'leaflet.extras', 'countrycode'), repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages(c('tidyverse','data.table' ), repos='http://cran.rstudio.com/')\""

## install biodiversity from github if public
sudo su - -c "R -e \"devtools::install_github('kmezhoud/biodiversity')\""

## other option built binary source tar.gz and install it as a root
#Build package in /home/kirus
sudo su - -c "R -e \"install.packages(“/home/kirus/biodiversity.01.tar.gz”, type=”source”)\""
```

```{bash}
#The next step is to change the owner of the package folder
chown -R shiny:shiny /usr/local/lib/R/site-library/biodiversity/
# or
chown -R shiny:shiny /home/kirus/R/x86_64-pc-linux-gnu-library/4.0/biodiversity/
systemctl restart shiny-server
# or change shiny-server.conf rus_as “kirus” (where is the package are build) instead “shiny”
# This is also right for the zintr package if installed in  /home of the kirus profile.

# set shiny-server.conf
nano /etc/shiny-server/shiny-server.conf
## Add the following section

location /biodiversity {
 app_dir /usr/local/lib/R/site-library/biodiversity/biodiversity;
 log_dir /var/log/shiny-server;
 directory_index on;
 }

# check browser at http://192.168.10.1:3838/biodiversity
```


# Security System

It can be protected by a strong security system:

+ Firewall with iptable and email Alert

+ Reserve Proxy with SSL and Domaine certificate

+ Keyring system for sensitive code like: Login detail, IP adress, tables and column names

+ IP verification and geo-restrinction


# Mobile App

The App can be implemented for Smartphone using [F7 framework](https://framework7.io/).
