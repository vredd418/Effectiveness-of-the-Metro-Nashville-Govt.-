library(shiny)
library(leaflet)
library(leaflet.extras)
library(leafpop)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Effectiveness of Metro Nashville Govt."),
    absolutePanel(top = 10, right = 10,
                  selectInput("chor_vars", "Choropleth Variables", c(choro_variables))),
    absolutePanel(bottom = 10, left = 10,
                  selectInput("req_vars", "Types of Requests", c(distinct(df, case_request)))),
    mainPanel(leafletOutput("mymap", width = "100%", height = "100%"))
))
