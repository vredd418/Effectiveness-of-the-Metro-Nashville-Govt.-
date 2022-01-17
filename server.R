library(shiny)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$mymap <- renderLeaflet({
      draw_base_map(df)
    })
    
    observeEvent(input$chor_vars, {
      update_choropleth("mymap", tract_census, input$chor_vars)
    })

})
