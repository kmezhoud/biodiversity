## The file must be a head of the package:  HERE/biodiversity/DESCRIPTION
# get shiny server and R from the rocker project
FROM rocker/shiny-verse:latest

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
RUN apt-get update && apt-get install -y \
    libudunits2-dev \
    libgdal-dev \
    libjq-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libprotobuf-dev \
    libv8-dev \
    protobuf-compiler
  

# install R packages required
RUN R -e "install.packages('remotes', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('shinythemes', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('leaflet', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('countrycode', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('leaflet.extras', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('data.table', repos='http://cran.rstudio.com/', dependencies = TRUE)"
## needed for geojsonio
RUN R -e "install.packages('protolite', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('jqr', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('geojson', repos='http://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "install.packages('geojsonio', repos='http://cran.rstudio.com/', dependencies = TRUE)"

#RUN R -e "remotes::install_github(repo='kmezhoud/biodiversity', ref='main', subdir='inst/biodiversity', auth_token = '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')"

# copy the app directory into the image
COPY /biodiversity ./biodiversity


# expose port
EXPOSE 3838

# run app
CMD ["R", "-e", "shiny::runApp('/biodiversity/inst/biodiversity', host = '0.0.0.0', port = 3838)"]
## If the app is install as R package
#CMD ["R", "-e", "shiny::runApp(system.file('biodiversity', package = 'biodiversity'), host = '0.0.0.0', port = 3838,launch.browser = TRUE, quiet = TRUE)"]