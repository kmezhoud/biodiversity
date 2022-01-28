# Example shiny app docker file
# https://blog.sellorm.com/2021/04/25/shiny-app-in-docker/

# get shiny server and R from the rocker project
FROM rocker/shiny-verse:latest

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libudunits2-dev \
    libgdal-dev
  

# install R packages required
RUN R -e "install.packages('remotes', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinythemes', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('geojsonio', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('countrycode', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet.extras', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('data.table', repos='http://cran.rstudio.com/')"

RUN #R -e "remotes::install_github(repo='kmezhoud/biodiversity', ref='main', subdir='inst/biodiversity', auth_token = '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')"

# copy the app directory into the image
#RUN chown -R shiny:shiny /usr/local/lib/R/site-library/biodiversity/
#RUN chown -R shiny:shiny /var/lib/shiny-server
#RUN chown -R 755 shiny:shiny /srv/shiny-server
#COPY ./biodiversity/* /srv/shiny-server/
COPY /biodiversity/* /biodiversity


# expose port
EXPOSE 3838

# run app
CMD ["R", "-e", "shiny::runApp('/biodiversity/inst/', host = '0.0.0.0', port = 3838)"]
#CMD ["R", "-e", "shiny::runApp(system.file('biodiversity', package = 'biodiversity'), host = '0.0.0.0', port = 3838,launch.browser = TRUE, quiet = TRUE)"]