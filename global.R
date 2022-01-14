library(httr)
library(tidyverse)
library(RSocrata)
library(lubridate)
library(rgdal)
library(ggplot2)
library(tidycensus)
library(sf)
library(tigris)
census_api_key("86875983b50f2fae4cdb9463bafa4f584c31b2f8")

df = read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json") %>% 
  subset(., select = c("status", "case_request", "case_subrequest", "additional_subrequest", "date_time_opened",
                        "date_time_closed", "mapped_location.latitude", "mapped_location.longitude")) %>% 
  filter(year(date_time_opened) == 2019 & year(date_time_closed) == 2019) %>% 
  filter_at(vars(mapped_location.latitude, mapped_location.longitude), all_vars(!is.na(.))) %>% 
  mutate_at(vars(mapped_location.latitude, mapped_location.longitude), as.numeric) %>% 
  mutate(duration = date_time_closed - date_time_opened)

tract <- readOGR(dsn = "C:/Users/vredd/Documents/data_science_projects/Midcourse project/Effectiveness-of-the-Metro-Nashville-Govt.-/data",
                layer = "tl_2019_47_tract") %>% 
  subset(., COUNTYFP %in% "037")

census <- get_acs(geography = "tract",
                  variables = c(median_income = "B06011_001", population = "B01001_001",
                                white = "B01001H_001", asian = "C02003_006", hispanic = "B01001I_001",
                                black = "C02003_004", median_age = "B01002_001"),
                  state = "TN",
                  county = 37,
                  year = 2019) %>% 
  select(., -c(moe)) %>% 
  spread(., key = variable, value = estimate)


tract_census <- geo_join(tract, census, by = "GEOID") %>% 
  .[,-(13:14)]

# Choices for choropleth variable selectInput
choro_variables <- variable.names(subset(tract_census@data, select = c(white, asian, hispanic, black, population, median_age, median_income)))

# Initialize leaflet map function
draw_base_map <- function() {
  leaflet(options = leafletOptions(minZoom = 10, maxZoom = 25)) %>%
    addProviderTiles("CartoDB.Positron") 
}

# Color palette for choropleth 
pal <- colorNumeric(palette = "viridis", domain = NULL)

# Update choropleth function
update_choropleth <- function(mymap, tract_census, chor_vars) {
  
}

