library(shiny)
library(leaflet)
library(leaflet.extras)
library(leafpop)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Effectiveness of Metro Nashville Govt."),
    
    mainPanel(leafletOutput("mymap", width = "100%", height = "100%"),
              absolutePanel(top = 10, right = 10, 
                            selectInput("chor_vars", "Choropleth variables", c(choro_variables))))
))
