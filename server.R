
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$mymap <- renderLeaflet({

        draw_base_map()

    })

})
