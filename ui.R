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
  navbarPage("",
             tabPanel("Map",
                      leafletOutput("mymap",
                                    width = "100%",
                                    height = "800px"),
                      actionButton("reset_button", "Reset View"),
                      absolutePanel(top = 100,
                                    right = 10,
                                    selectInput("chor_vars",
                                                "Choropleth Variables",
                                                c(choro_variables)
                                    ),
                      ),
                      absolutePanel(bottom = 200,
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
             tabPanel("Correlation",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("y_var",
                                      "Y Variable:",
                                      c(names(scatter_data)[-1]),
                                      selected = "gr_tract_median_duration"),
                          br(),
                          selectInput("x_var",
                                      "X variable:",
                                      c(names(scatter_data)[-1]),
                                      selected = "median_income")
                        ),
                        mainPanel(
                          plotOutput("scatter",
                                     width = "100%",
                                     height = "900px")
                        ),
                        position = "left",
                        fluid = TRUE
                      )
             ),
             tabPanel("Data",
                      mainPanel( 
                        dataTableOutput("table")
                      )
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
