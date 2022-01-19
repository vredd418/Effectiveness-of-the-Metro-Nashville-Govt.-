library(shiny)
library(leaflet)


shinyServer(function(input, output) {

    # Draw base map  
    output$mymap <- renderLeaflet({
      map <- draw_base_map(df)
      map
    })
    
    # Filter df based on case request selection
    df_filtered <- reactive({
      df <- df %>%
        filter(case_request == input$req_vars)
    })
    
    # Update choropleth on choropleth variable selection
    observeEvent(input$chor_vars, {
      update_choropleth("mymap", tract_census, input$chor_vars)
    })
    
    # # Update markers on case_request selection
    # observeEvent(input$req_vars, {
    #   update_data_points("mymap", df_filtered())
    # })
    
    # Update map legend based on choropleth variable selection
    observeEvent(input$chor_vars, {
      draw_map_legend("mymap", tract_census, input$chor_vars)
    })
    
})
