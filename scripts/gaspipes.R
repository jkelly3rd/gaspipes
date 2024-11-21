library(tidyverse)
library(lubridate)
library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(htmlwidgets)



# import the zip file in the data directory
unzip("data/annual_gas_distribution_2010_present.zip", exdir = "data/gaspipes")
# repeat for the zip file for gas incidents
unzip("data/incident_gas_distribution_jan2010_present.zip", exdir = "data/gasincidents")

# import the csv for 2023 called data/gaspipes/GD AR 2023.csv
gaspipes <- read_csv("data/gaspipes/GD AR 2023.csv")  %>% janitor::clean_names()


# Import the above file instead as a tab delimited
gasincidents <- read_tsv("data/gasincidents/incident_gas_distribution_jan2010_present.txt") %>% janitor::clean_names()


# map the gas incidents data in leaflet with red dots for those with 1 or more fatality and blue dots for all others
#leaflet(gasincidents) %>%
#  addTiles() %>%
#  addCircleMarkers(~location_longitude, ~location_latitude, color = ~ifelse(fatal > 0, "red", "blue"))
# map gas incidents in Michigan only
gas_incidents_detroit <- leaflet(gasincidents %>% 
  filter(location_state_abbreviation == "MI")) %>%
  addTiles() %>%
  addCircleMarkers(~location_longitude, ~location_latitude, color = ~ifelse(fatal > 0, "red", "blue"), 
                   popup = ~paste("<strong>Year:</strong>", iyear, 
                                  "<br><strong>Address:</strong>", location_street_address, 
                                  "<br><strong>City:</strong>", location_city_name, 
                                  "<br><strong>Fatalities:</strong>", fatal)) %>%
  addLegend("bottomright", colors = c("red", "blue"), 
            labels = c("Fatal", "Non-fatal"), 
            title = "Incident Type") %>%
  setView(-83.0458, 42.3314, zoom = 9) %>%
  addControl(html = "<h3>Gas Incidents in Detroit</h3>", position = "topright")


    
# save an html version of the map into the docs directory
saveWidget(gas_incidents_detroit, "docs/gas_incidents_detroit.html", selfcontained = TRUE)

