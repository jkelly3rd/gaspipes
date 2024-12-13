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
                                  "<br><strong>Fatalities:</strong>", fatal,
                                  "<br><strong>Injuries:</strong>", injure,
                                  "<br><strong>Ignited?:</strong>", ignite_ind,
                                  "<br><strong>Gas Provider:</strong>", name)) %>%
  addLegend("bottomright", colors = c("red", "blue"), 
            labels = c("Fatal", "Non-fatal"), 
            title = "Incident Type") %>%
  setView(-83.0458, 42.3314, zoom = 9) %>%
  addControl(html = "<h3>Gas Incidents in Detroit Region<br>From 2010 to October 2024</h3>", position = "topright")
    
# save an html version of the map into the docs directory
saveWidget(gas_incidents_detroit, "docs/gas_incidents_detroit.html", selfcontained = TRUE)

# Create a document that gives every incidents in Wayne or Oakland County Michigan with the year, date, street address, city, county, gas company name and the narrative description of the incident and number of fatalities
detroit_incidents <- gasincidents %>% 
  filter(location_county_name %in% c("WAYNE", "WAYNE COUNTY","OAKLAND","OAKLAND COUNTY") & location_state_abbreviation == "MI") %>% 
  select(iyear, local_datetime, location_street_address, location_city_name, location_county_name, name, narrative, fatal,injure,ignite_ind)
# use lubridate to convert the local_datetime to a date
detroit_incidents <- detroit_incidents %>% 
  mutate(local_datetime = mdy_hm(local_datetime)) %>% 
  mutate(date = as_date(local_datetime))
# write as csv 
detroit_incidents %>% 
  write_csv("data/gas_incidents_wayne_oakland.csv")
