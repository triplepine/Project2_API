#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shiny)
library(DT)

# Define UI for application that draws a histogram


navbarPage("FDA Animal & Drug API",
           tabPanel("About",
                    fluidPage(
                      titlePanel("About This App"),
                      sidebarLayout(
                        sidebarPanel(
                          h3("Purpose of the App"),
                          p("This app provides access to the FDA Animal & Veterinary API and Drug API data, allowing users to search for adverse events and see the numerical and graphical summaries."),
                          img(src = "openFDA.png", height = "100px", width = "200px"),
                          h3("Data Source"),
                          p("The data is sourced from the FDA's Animal & Veterinary API. For more information, visit the ",
                            a("FDA Animal & Veterinary API", href = "https://api.fda.gov/drug/event.json?")),
                          h3("Tab Descriptions"),
                          p("1. ", strong("About:"), " Provides information about the app, the data source, and the purpose of each tab."),
                          p("2. ", strong("Download:"), " Allows users to specify changes to API querying and return data."),
                          
                        ),
                        mainPanel(
                          h3("Welcome to the FDA Animal & Drug API App"),
                          p("Use the tabs above to navigate through the app.")
                        )
                      )
                    )
           ),
                 tabPanel("Download",
                          fluidPage(
                            titlePanel("Adverse Events"),
                            sidebarLayout(
                              sidebarPanel(
                                textInput("search_events", "Search:", value = ""),
                                numericInput("limit_events", "Limit:", value = 10, min = 1, max = 100),
                                actionButton("submit_events", "Submit")
                              ),
                              mainPanel(
                                DTOutput("results_events")
                              )
                            )
                          )
                 ),
                 tabPanel("Exploration",
                          fluidPage(
                            titlePanel("Recalls"),
                            sidebarLayout(
                              sidebarPanel(
                                textInput("search_recalls", "Search:", value = ""),
                                numericInput("limit_recalls", "Limit:", value = 10, min = 1, max = 100),
                                actionButton("submit_recalls", "Submit")
                              ),
                              mainPanel(
                                DTOutput("results_recalls")
                              )
                            )
                          )
                 
                 
                              )
                            )
                          
                 
                 
                              
                            
                          
                 

