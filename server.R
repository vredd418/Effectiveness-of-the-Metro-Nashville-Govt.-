library(shiny)
library(leaflet)


shinyServer(function(input, output) {

    # Draw base map  
    output$mymap <- renderLeaflet({
      map <- draw_base_map(all_data)
      #map
    })
    
    # Filter df based on case request selection
    data_filtered <- reactive({
      all_data <- all_data %>%
        filter(case_request == input$req_vars)
    })
    
    # Update choropleth on choropleth variable selection
    observeEvent(input$chor_vars, {
      update_choropleth("mymap", tract_census, input$chor_vars)
    })
    
    # Update markers on case_request selection
    observeEvent(input$req_vars, {
      req(input$req_vars)
      update_data_points("mymap", data_filtered())
    })
    
    # Update map legend based on choropleth variable selection
    observeEvent(input$chor_vars, {
      draw_map_legend("mymap", tract_census, input$chor_vars)
    })
    
    # Popup graph when polygon is clicked
    observeEvent(input$mymap_shape_click, {
      showModal(modalDialog(
        plotOutput("plot"),
        title = input$mymap_shape_click[1],
        fade = F,
        easyClose = T,
        footer = NULL
      ))
    })

    output$plot <- renderPlot({
      tract_census %>%
        st_drop_geometry() %>%
        filter(NAMELSAD == input$mymap_shape_click[1]) %>%
        select(NAMELSAD, white, black, asian, hispanic) %>%
        pivot_longer(!NAMELSAD, names_to = "Race", values_to = "Percentage of Tract Pop") %>%
        ggplot() + geom_col(aes(x = Race, y = `Percentage of Tract Pop`))
    })
    
})


# tract_census %>%
#   st_drop_geometry() %>%
#   select(NAMELSAD, white, black, asian, hispanic) %>%
#   pivot_longer(!NAMELSAD, names_to = "Race", values_to = "Percentage of Tract Pop") %>%
#   ggplot() +geom_col(aes(x = Race, y = `Percentage of Tract Pop`, group = NAMELSAD))


