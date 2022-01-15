library(leaflet)
library(stats)
library(htmltools)

choro_variables <- variable.names(subset(tract_census@data, select = c(white, asian, hispanic, black, population, median_age, median_income)))

pal <- colorNumeric("viridis", domain = tract_census@data$median_income)

leaflet(data = df, options = leafletOptions(minZoom = 10, maxZoom = 25)) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addMarkers(lng = ~mapped_location.longitude, lat = ~mapped_location.latitude, 
             label = ~sprintf("<strong>%s</strong><br/>%s<br/>%d%s", case_request, case_subrequest, duration, " seconds") %>% lapply(HTML),
             clusterOptions = markerClusterOptions()) %>% 
  addPolygons(data = tract_census, weight = 1, color = "white",
              highlightOptions = highlightOptions(weight = 5, color = "white", bringToFront = T),
              label = ~sprintf("<strong>%s</strong><br/>%d", NAMELSAD, median_income) %>% lapply(HTML),
              labelOptions = labelOptions(style = list("font_weight" = "normal", padding = "3px 8px"), 
                                          textsize = "15px", direction = "auto"),
              fillColor = ~pal(median_income), fillOpacity = .9) %>% 
  setView(lat = 36.163934, lng = -86.774893, zoom = 10) %>% 
  addLegend(pal = pal, values = tract_census@data$median_income, title = "Median Income")
              
              
              
  


