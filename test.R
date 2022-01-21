library(leaflet)
library(stats)
library(htmltools)
library(geojson)

choro_variables <- variable.names(subset(tract_census@data, select = c(white, asian, hispanic, black, population, median_age, median_income)))

pal_test <- colorNumeric("viridis", domain = all_data$median_income)

leaflet(data = test_data, options = leafletOptions(minZoom = 10, maxZoom = 17)) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addMarkers(lat = ~mapped_location.latitude, lng = ~mapped_location.longitude, 
             label = ~sprintf("<strong>%s</strong><br/>%s<br/>%d%s", case_request, 
                              case_subrequest, duration, " seconds") %>% lapply(HTML),
             clusterOptions = markerClusterOptions()) %>% 
  addPolygons(data = distinct(test_data$geometry.y), weight = 1, color = "white",
              highlightOptions = highlightOptions(weight = 5, color = "white", bringToFront = T),
              label = ~sprintf("<strong>%s</strong><br/>%d", NAMELSAD, median_income) %>% lapply(HTML),
              labelOptions = labelOptions(style = list("font_weight" = "normal", padding = "3px 8px"), 
                                          textsize = "15px", direction = "auto"),
              fillColor = ~pal_test(median_income), fillOpacity = .9) %>% 
  setView(lat = 36.163934, lng = -86.774893, zoom = 10) %>% 
  addLegend(pal = pal_test, values = test_data$median_income, title = "Median Income")
              




test_census <- get_acs(geography = "tract",
                       variables = c(median_income = "B06011_001", population = "B01001_001",
                                     white = "B01001H_001", asian = "C02003_006", hispanic = "B01001I_001",
                                     black = "C02003_004", median_age = "B01002_001"),
                       state = "TN",
                       county = 37,
                       year = 2019) %>%
  select(., -c(moe))

test_df <- read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json") %>%
  subset(.[1:50,], select = c("status", "case_request", "case_subrequest", "additional_subrequest", "date_time_opened",
                       "date_time_closed", "mapped_location.latitude", "mapped_location.longitude")) %>%
  filter(year(date_time_opened) == 2019 & year(date_time_closed) == 2019) %>%
  filter_at(vars(mapped_location.latitude, mapped_location.longitude), all_vars(!is.na(.))) %>%
  mutate_at(vars(mapped_location.latitude, mapped_location.longitude), as.numeric) %>%
  mutate(duration = date_time_closed - date_time_opened)





