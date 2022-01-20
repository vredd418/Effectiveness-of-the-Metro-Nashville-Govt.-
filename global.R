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
library(prevR)
library(leaflet)
library(stats)
library(scales)
census_api_key("86875983b50f2fae4cdb9463bafa4f584c31b2f8")

# # Read in Metro Nashville Govt data
# df <- read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json") %>%
#   subset(., select = c("status", "case_request", "case_subrequest", "additional_subrequest", "date_time_opened",
#                         "date_time_closed", "mapped_location.latitude", "mapped_location.longitude")) %>%
#   filter(year(date_time_opened) == 2019 & year(date_time_closed) == 2019) %>%
#   filter_at(vars(mapped_location.latitude, mapped_location.longitude), all_vars(!is.na(.))) %>%
#   mutate_at(vars(mapped_location.latitude, mapped_location.longitude), as.numeric) %>%
#   mutate(duration = date_time_closed - date_time_opened) %>%
#   st_as_sf(., coords = c("mapped_location.longitude", "mapped_location.latitude"), crs = 4269, remove = F, agr = "constant")
# #  
# # Read in census tract shape file
# tract <- readOGR(dsn = "C:/Users/vredd/Documents/data_science_projects/Midcourse project/Effectiveness-of-the-Metro-Nashville-Govt.-/data",
#                 layer = "tl_2019_47_tract") %>%
#   subset(., COUNTYFP %in% "037") %>% 
#   st_as_sf(., crs = 4269)
# 
# # Read in census data
# census <- get_acs(geography = "tract",
#                   variables = c(median_income = "B06011_001", population = "B01001_001",
#                                 white = "B01001H_001", asian = "C02003_006", hispanic = "B01001I_001",
#                                 black = "C02003_004", median_age = "B01002_001"),
#                   state = "TN",
#                   county = 37,
#                   year = 2019) %>%
#   select(., -c(moe)) %>%
#   spread(., key = variable, value = estimate) %>%
#   mutate_at(vars(asian, black, hispanic, white), ~./population)
# 
# 
# Merge census and tract data
# tract_census <- geo_join(tract, census, by = "GEOID") %>%
#   .[,-(13:14)] 
# 
# tract_census <- st_as_sf(tract_census, 
#                          crs = 4269, 
#                          agr = c(STATEFP = "identity", COUNTYFP = "identity", 
#                                  TRACTCE = "identity", GEOID = "identity", 
#                                  NAME = "identity", NAMELSAD = "identity",
#                                  MTFCC = "constant", FUNCSTAT = "constant", ALAND = "aggregate",
#                                  AWATER = "aggregate", asian = "aggregate", black = "aggregate",
#                                  hispanic = "aggregate", white = "aggregate", population = "aggregate",
#                                  median_age = "aggregate", median_income = "aggregate"))

# all_data <- all_data %>%
#   group_by(case_request) %>%
#   mutate(med_inc_by_request = median(median_income, na.rm = T),
#          med_age_by_request = median(median_age, na.rm = T),
#          num_request = n()) %>%
#   group_by(GEOID, case_request) %>%
#   mutate(requests_per_tract = n()) %>%
#   group_by(GEOID, case_request, case_subrequest) %>%
#   mutate(sub_requests_per_tract = n()) %>%
#   group_by(GEOID) %>%
#   mutate(median_duration_by_tract = paste(sprintf("%.2f", median(duration)/86400), "days"))


# df <- read_rds(file = "data/df.rds")
tract_census <- read_rds(file = "data/tract_census.rds")
all_data <- read_rds(file = "data/all_data.rds")

# # Merge all data and filter points outside of Davidson County
# all_data <- st_join(df, tract_census, join = st_within) %>% 
#   drop_na(STATEFP)


# Color palette for choropleth 
pal <- colorNumeric(palette = "viridis", domain = NULL)

# Choices for choropleth variable 
choro_variables <- variable.names(subset(tract_census@data, 
                                         select = c(white, asian, hispanic, black, 
                                                    population, median_age, median_income)))

# Choices for case request variable
req_variables <- c(distinct(all_data, case_request))

# Initialize leaflet map function
draw_base_map <- function(all_data) {
  leaflet(data = all_data, options = leafletOptions(minZoom = 10, maxZoom = 17)) %>%
    addProviderTiles("CartoDB.Positron") %>% 
    addMarkers(lat = ~mapped_location.latitude, lng = ~mapped_location.longitude,
               clusterOptions = markerClusterOptions(),
               label = ~sprintf("<strong>%s</strong><br/>%s<br/>%s", case_request, 
                                case_subrequest, median_duration_by_tract) %>% lapply(HTML)) %>% 
    setView(lat = 36.163934, lng = -86.774893, zoom = 10)
}

# Update data points function
update_data_points <- function(mymap, all_data) {
  #browser()
  leafletProxy(mymap) %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    addMarkers(data = df, lat = all_data[["mapped_location.latitude"]], lng = all_data[["mapped_location.longitude"]],
               clusterOptions = markerClusterOptions(),
               label = sprintf("<strong>%s</strong><br/>%s<br/>%s", all_data[["case_request"]],
                               all_data[["case_subrequest"]], all_data[["median_duration_by_tract"]]) %>% 
                 lapply(HTML))
}



# Update choropleth function
update_choropleth <- function(mymap, tract_census, chor_vars) {
  leafletProxy(mymap) %>% 
    addPolygons(data = tract_census, weight = 1, color = "white",
                highlightOptions = highlightOptions(weight = 5, color = "white", bringToFront = T),
                label = ~sprintf("<strong>%s</strong><br/>%.2f", 
                                 tract_census@data$NAMELSAD, 
                                 tract_census@data[[chor_vars]]) %>% lapply(HTML),
                labelOptions = labelOptions(style = list("font_weight" = "normal", padding = "3px 8px",
                                                         textsize = "15px", direction = "auto")),
                fillColor = ~pal(tract_census@data[[chor_vars]]), fillOpacity = 0.7)
}

# Draw map legend function
draw_map_legend <- function(mymap, tract_census, chor_vars) {
  leafletProxy(mymap, data = tract_census) %>%
    clearControls() %>%
    addLegend(
      "bottomleft",
      pal = pal, 
      values = tract_census[[chor_vars]], # need to change with input
      title = ~ str_to_title(chor_vars), # needs to change with input
      opacity = 1
    )
}

