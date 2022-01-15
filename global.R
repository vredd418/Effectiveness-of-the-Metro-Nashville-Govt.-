library(httr)
library(tidyverse)
library(RSocrata)
library(lubridate)
library(rgdal)
library(ggplot2)
library(tidycensus)
library(sf)
library(tigris)
library(htmltools)
census_api_key("86875983b50f2fae4cdb9463bafa4f584c31b2f8")

# Read in Metro Nashville Govt data
df = read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json") %>% 
  subset(., select = c("status", "case_request", "case_subrequest", "additional_subrequest", "date_time_opened",
                        "date_time_closed", "mapped_location.latitude", "mapped_location.longitude")) %>% 
  filter(year(date_time_opened) == 2019 & year(date_time_closed) == 2019) %>% 
  filter_at(vars(mapped_location.latitude, mapped_location.longitude), all_vars(!is.na(.))) %>% 
  mutate_at(vars(mapped_location.latitude, mapped_location.longitude), as.numeric) %>% 
  mutate(duration = date_time_closed - date_time_opened) %>% 
  st_as_sf(., coords = c("mapped_location.latitude", "mapped_location.longitude"), crs = 4269, remove = F)

# Read in census tract shape file
tract <- readOGR(dsn = "C:/Users/vredd/Documents/data_science_projects/Midcourse project/Effectiveness-of-the-Metro-Nashville-Govt.-/data",
                layer = "tl_2019_47_tract") %>% 
  subset(., COUNTYFP %in% "037")

# Read in census data
census <- get_acs(geography = "tract",
                  variables = c(median_income = "B06011_001", population = "B01001_001",
                                white = "B01001H_001", asian = "C02003_006", hispanic = "B01001I_001",
                                black = "C02003_004", median_age = "B01002_001"),
                  state = "TN",
                  county = 37,
                  year = 2019) %>% 
  select(., -c(moe)) %>% 
  spread(., key = variable, value = estimate)

# Merge census and tract data
tract_census <- geo_join(tract, census, by = "GEOID") %>% 
  .[,-(13:14)]

# Filter out point data outside of Davidson County
df_filtered <- st_join(df, tract_census)

# Choices for choropleth variable 
choro_variables <- variable.names(subset(tract_census@data, 
                                         select = c(white, asian, hispanic, black, population, median_age, median_income)))

# Initialize leaflet map function
draw_base_map <- function() {
  leaflet(options = leafletOptions(minZoom = 10, maxZoom = 25)) %>%
    addProviderTiles("CartoDB.Positron") %>% 
    setView(lat = 36.163934, lng = -86.774893, zoom = 10)
}

# Color palette for choropleth 
pal <- colorNumeric(palette = "viridis", domain = NULL)

# Update choropleth function
update_choropleth <- function(mymap, tract_census, chor_vars) {
  
  leafletProxy(mymap, data = df) %>% 
    addPolygons(data = tract_census, weight = 1, color = "white",
                highlightOptions = highlightOptions(weight = 5, color = "white", bringToFront = T),
                label = ~sprintf("<strong>%s</strong><br/>%d", 
                                 tract_census@data$NAMELSAD, 
                                 tract_census@data[[chor_vars]]) %>% lapply(HTML),
                labelOptions = labelOptions(style = list("font_weight" = "normal", padding = "3px 8px",
                                                         textsize = "15px", direction = "auto")),
                fillColor = ~pal(tract_census@data[[chor_vars]]), fillOpacity = 0.9)
}

# Draw map legend function
draw_map_legend <- function(mymap, tract_census, chor_vars) {
  leafletProxy(mymap, data = tract_census) %>%
    clearControls() %>%
    addLegend(
      "bottomleft",
      pal = pal, 
      values = tract_census@data[[chor_vars]], # need to change with input
      title = ~ str_to_title(chor_vars), # needs to change with input
      opacity = 1
    )
}

