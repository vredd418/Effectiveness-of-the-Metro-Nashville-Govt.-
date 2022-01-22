library(shiny)
library(shinyjs)
library(leaflet)
library(leaflet.extras)
library(leafpop)
library(htmltools)

# shinyUI(
#   useShinyjs(),
#   tagList(
#     navbarPage(title = "Effectiveness of Metro Govt.",
#                tabPanel("Map",
#                         tags$style(type = "text/css", "html, body {width:100%;height:100%}")
#                ),
#                # div(class = "outer",
#                #     tags$head(
#                #       includeCSS("styles.css")
#                #     ),
#                
#                
#                leafletOutput("mymap", width = "100%", height = "100%"),
#                
#                
#                absolutePanel(top = 10,right = 10,
#                              selectInput("chor_vars", "Choropleth Variables",
#                                          c(choro_variables)
#                              )
#                ),
#                
#                
#                absolutePanel(bottom = 10, right = 10,
#                              selectizeInput("req_vars", "Types of Requests",
#                                             c(req_variables),
#                                             options = list(placeholder = ("Select a case request type"),
#                                                            onInitialize = I('function() { this.setValue(""); }')
#                                             )
#                              )
#                ),
#                tabPanel(title = "Analysis",
#                         h4("Something here")
#                )
#     )
#   )
# )

shinyUI(
  navbarPage("Nashville Metro Govt",
             tabPanel("Map",
                      leafletOutput("mymap",
                                    width = "100%",
                                    height = "60px"),
                      absolutePanel(top = 10,
                                    right = 10,
                                    selectInput("chor_vars",
                                                "Choropleth Variables",
                                                c(choro_variables)
                                    ),
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
             ),
             tabPanel("Analysis",
                      h4("Something here")
             )
  )
)

# # This works. But no navbarpage.
# shinyUI(
#   bootstrapPage(
#     tags$style(type = "text/css", 
#                "html, body {width:100%;height:100%}"),
#     windowTitle = "Effectiveness of Metro Nashville Government",
#     leafletOutput("mymap", 
#                   width = "100%", 
#                   height = "100%"),
#     absolutePanel(top = 10, 
#                   right = 10,
#                   selectInput("chor_vars", 
#                               "Choropleth Variables", 
#                               c(choro_variables)
#                   )
#     ),
#     absolutePanel(bottom = 10, 
#                   right = 10,
#                   selectizeInput("req_vars", 
#                                  "Types of Requests", 
#                                  c(req_variables),
#                                  options = list(
#                                    placeholder = ("Select a case request type"),
#                                    onInitialize = I('function() { this.setValue(""); }')
#                                  )
#                   )
#     )
#   )
# )
