library(shiny)
library(leaflet)
library(leaflet.extras)
library(leafpop)

# Define UI for application that draws a histogram
shinyUI(
  bootstrapPage(
    tags$style(type = "text/css", 
               "html, body {width:100%;height:100%}"),
    windowTitle = "Effectiveness of Metro Nashville Government",
    leafletOutput("mymap", 
                  width = "100%", 
                  height = "100%"),
    absolutePanel(top = 10, 
                  right = 10,
                  selectInput("chor_vars", 
                              "Choropleth Variables", 
                              c(choro_variables)
                              )
                  ),
    absolutePanel(bottom = 10, 
                  right = 10,
                  selectizeInput("req_vars", 
                                 "Types of Requests", 
                                 c(req_variables),
                                 options = list(
                                   placeholder = ("Select a case request type"),
                                   onInitialize = I('function() { this.setValue(""); }')
                                   )
                                 )
                  )
  )
)

