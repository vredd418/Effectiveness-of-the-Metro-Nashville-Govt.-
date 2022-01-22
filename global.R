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
library(ggstatsplot)
census_api_key("86875983b50f2fae4cdb9463bafa4f584c31b2f8")

# # Read in Metro Nashville Govt data
# df <- read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json") %>%
#   subset(., select = c("status", "case_request", "case_subrequest", "additional_subrequest", "date_time_opened",
#                        "date_time_closed", "mapped_location.latitude", "mapped_location.longitude")) %>%
#   filter(year(date_time_opened) == 2019 & year(date_time_closed) == 2019) %>%
#   filter_at(vars(mapped_location.latitude, mapped_location.longitude), all_vars(!is.na(.))) %>%
#   mutate_at(vars(mapped_location.latitude, mapped_location.longitude), as.numeric) %>%
#   mutate(duration = difftime(date_time_closed, date_time_opened, units = "days")) %>%
#   st_as_sf(., coords = c("mapped_location.longitude", "mapped_location.latitude"), crs = 4269, remove = F, agr = "constant")
# 
# # Read in census tract shape file
# tract <- readOGR(dsn = "C:/Users/vredd/Documents/data_science_projects/Midcourse project/Effectiveness-of-the-Metro-Nashville-Govt.-/data",
#                  layer = "tl_2019_47_tract") %>%
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
# # Merge census and tract data
# tract_census <- geo_join(tract, census, by = "GEOID") %>%
#   st_as_sf(tract_census,
#            crs = 4269,
#            agr = c(STATEFP = "identity", COUNTYFP = "identity",
#                    TRACTCE = "identity", GEOID = "identity",
#                    NAME = "identity", NAMELSAD = "identity",
#                    MTFCC = "constant", FUNCSTAT = "constant", ALAND = "aggregate",
#                    AWATER = "aggregate", asian = "aggregate", black = "aggregate",
#                    hispanic = "aggregate", white = "aggregate", population = "aggregate",
#                    median_age = "aggregate", median_income = "aggregate"))
# 
# # Merge all data and filter points outside of Davidson County
# all_data <- st_join(df, tract_census, join = st_within) %>%
#   drop_na(STATEFP)

# Create grouping columns for EDA
# all_data <- all_data %>%
#   group_by(GEOID) %>%
#   mutate(gr_tract_median_duration = median(duration, na.rm = T),
#          gr_tract_mean_duration = mean(duration, na.rm = T),
#          gr_tract_sum_requests = n()) %>%
#   ungroup() %>% 
#   group_by(case_request) %>%
#   mutate(gr_request_median_inc = median(median_income, na.rm = T),
#          gr_request_mean_inc = mean(median_income, na.rm = T),
#          gr_request_median_age = median(median_age, na.rm = T),
#          gr_request_mean_age = mean(median_age, na.rm = T),
#          gr_request_median_duration = median(duration, na.rm = T),
#          gr_request_mean_duration = mean(duration, na.rm = T),
#          gr_requests_sum = n()) %>%
#   ungroup() %>% 
#   group_by(GEOID, case_request) %>%
#   mutate(gr_tract.request_median_duration = median(duration, na.rm = T),
#          gr_tract.request_mean_duration = mean(duration, na.rm = T),
#          gr_tract.request_sum = n()) %>%
#   ungroup() %>% 
#   group_by(GEOID, case_request, case_subrequest) %>%
#   mutate(gr_tract.request.sub_median_duration = median(duration, na.rm = T),
#          gr_tract.request.sub_mean_duration = mean(duration, na.rm = T),
#          gr_tract.request_sum = n()) %>%
#   ungroup()

# 
# Data for scatterplot
# scatter_data <- st_drop_geometry(all_data) %>%
#   select(NAMELSAD, asian, black, hispanic, white, population, median_age, median_income, gr_tract_median_duration, gr_tract_mean_duration, gr_tract_sum_requests) %>%
#   mutate(gr_tract_median_duration = as.numeric(gr_tract_median_duration),
#          gr_tract_mean_duration = as.numeric(gr_tract_mean_duration))
# scatter_data <- scatter_data[!duplicated(scatter_data), ]
#
# # Save files as .rds
# df %>% write_rds(file = "data/df.rds")
# tract_census %>% write_rds(file = "data/tract_census.rds")
# all_data %>% write_rds(file = "data/all_data.rds")
# scatter_data %>% write_rds(file = "data/scatter_data.rds")


# Read in files
tract_census <- read_rds(file = "data/tract_census.rds")
all_data <- read_rds(file = "data/all_data.rds")
scatter_data <- read_rds(file = "data/scatter_data.rds")

# Color palette for choropleth 
pal <- colorNumeric(palette = "viridis", domain = NULL)

# Choices for choropleth variable 
choro_variables <- variable.names(subset(tract_census, 
                                         select = c(white, asian, hispanic, black, 
                                                    population, median_age, median_income)))[-8]

# Choices for case request variable
req_variables <- c(distinct(all_data, case_request))

# List for marker icons
icons <- awesomeIconList(
  "Streets, Roads & Sidewalks" = makeAwesomeIcon(
    icon = "road",
    library = "fa"
  ),
  "Trash, Recycling & Litter" = makeAwesomeIcon(
    icon = "trash",
    library = "fa"
  ),
  "Resolved by hubNashville on First Call" = makeAwesomeIcon(
    icon = "fighter-jet",
    library = "fa"
  ),
  "Submit Budget Ideas to Mayor Briley" = makeAwesomeIcon(
    icon = "money-bill-wave",
    library = "fa"
  ),
  "Electric & Water General" = makeAwesomeIcon(
    icon = "water",
    library = "fa"
  ),
  "Public Safety" = makeAwesomeIcon(
    icon = "user-shield",
    library = "fa"
  ),
  "Transit" = makeAwesomeIcon(
    icon = "bus",
    library = "fa"
  ),
  "Public Records Request" = makeAwesomeIcon(
    icon = "scroll",
    library = "fa"
  ),
  "Social Services & Housing" = makeAwesomeIcon(
    icon = "home",
    library = "fa"
  ),
  "Property Violations" = makeAwesomeIcon(
    icon = "house-damage",
    library = "fa"
  ),
  "Permits" = makeAwesomeIcon(
    icon = "sticky_note",
    library = "fa"
  ),
  "Planning & Zoning" = makeAwesomeIcon(
    icon = "buffer",
    library = "fa"
  ),
  "Parks" = makeAwesomeIcon(
    icon = "pagelines",
    library = "fa"
  ),
  "Other Metro Services and Forms" = makeAwesomeIcon(
    icon = "clipboard",
    library = "fa"
  ),
  "Education & Libraries" = makeAwesomeIcon(
    icon = "university",
    library = "fa"
  ),
  "Workforce & Jobs" = makeAwesomeIcon(
    icon = "hard-hat",
    library = "fa"
  )
)

# Initialize leaflet map function
draw_base_map <- function(all_data) {
  leaflet(data = all_data, options = leafletOptions(minZoom = 10, maxZoom = 17)) %>%
    addProviderTiles("CartoDB.Positron") %>% 
    addAwesomeMarkers(lat = ~mapped_location.latitude, lng = ~mapped_location.longitude,
                      icon = ~ icons[case_request],
               clusterOptions = markerClusterOptions(),
               label = ~sprintf("<strong>%s</strong><br/>%s<br/>%s", case_request, 
                                case_subrequest, gr_tract_median_duration) %>% lapply(HTML)) %>% 
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
                               all_data[["case_subrequest"]], all_data[["gr_tract_median_duration"]]) %>% 
                 lapply(HTML))
}



# Update choropleth function
update_choropleth <- function(mymap, tract_census, chor_vars) {
  leafletProxy(mymap) %>% 
    addPolygons(data = tract_census, weight = 1, color = "white",
                highlightOptions = highlightOptions(weight = 5, color = "white", bringToFront = T),
                label = ~sprintf("<strong>%s</strong><br/>%.2f", 
                                 tract_census$NAMELSAD, 
                                 tract_census[[chor_vars]]) %>% lapply(HTML),
                labelOptions = labelOptions(style = list("font_weight" = "normal", padding = "3px 8px",
                                                         textsize = "15px", direction = "auto")),
                stroke = F,
                fillColor = ~pal(tract_census[[chor_vars]]), 
                fillOpacity = 0.7,
                smoothFactor = 0.5,
                layerId = tract_census$NAMELSAD)
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


 
