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


navbarPage("FDA Animal & Food API",
           tabPanel("About",
                    fluidPage(
                      titlePanel("About This App"),
                      sidebarLayout(
                        sidebarPanel(
                          h3("Purpose of the App"),
                          p("This app provides access to the FDA Animal & Veterinary API and Food API data, allowing users to search for adverse events and see the numerical and graphical summaries."),
                        ),
                        mainPanel(
                          h3("Welcome to the Animal Drug & Food Adverse Events Reports App"),
                          h3("Data Source"),
                          p("The data is sourced from the FDA's Animal & Veterinary API. For more information, visit the ",
                            a("FDA Animal & Veterinary API", href = "https://api.fda.gov/drug/event.json?"),
                            br(),
                            img(src = "openFDA.png", height = "80px", width = "200px")
                          ),
                          p("Use the tabs above to navigate through the app."),
                          
                          h3("Tab Descriptions"),
                          p("1. ", strong("About:"), " Provides information about the app, the data source, and the purpose of each tab."),
                          p("2. ", strong("Download:"), " Allows users to specify changes to API querying and return data.")
                        )
                      )
                    )
           ),
           
           tabPanel("Download",
                    fluidPage(
                      titlePanel("Adverse Events"),
                      sidebarLayout(
                        sidebarPanel(
                          h3("Animal Data Query"),
                          selectInput("search_animal", "Search:", 
                                      choices = list("original_receive_date" = "original_receive_date", "onset_date" = "onset_date")),
                          textInput("date_animal", "Date (yyyymmdd):", value = "20230601"),
                          numericInput("limit_animal", "Limit:", value = 1000, min = 1, max = 1000),
                          actionButton("submit_animal", "Submit Animal Query"),
                          br(),
                          h3("Food Data Query"),
                          textInput("date_range_food", "Date Range (yyyymmdd+TO+yyyymmdd):", value = "20240101+TO+20240531"),
                          numericInput("limit_food", "Limit:", value = 1000, min = 1, max = 1000),
                          actionButton("submit_food", "Submit Food Query")
                        ),
                        mainPanel(
                          tabsetPanel(
                            tabPanel("Animal Data", 
                                     DTOutput("results_animal"),
                                     uiOutput("column_selector_animal"),
                                     numericInput("rows_to_display_animal", "Number of rows to display", value = 10, min = 1),
                                     downloadButton("download_data_animal", "Download Animal Data")
                            ),
                            tabPanel("Food Data", 
                                     DTOutput("results_food"),
                                     uiOutput("column_selector_food"),
                                     numericInput("rows_to_display_food", "Number of rows to display", value = 10, min = 1),
                                     downloadButton("download_data_food", "Download Food Data")
                            )
                          )
                        )
                      )
                    )
           ),
           
           tabPanel("Exploration",
                    fluidRow(
                      column(4,
                             wellPanel(
                               h3("View Animal Adverse Effect Data"),
                               p("Content for side panel 1")
                             ),
                             wellPanel(
                               h3("View Food Adverse Effect Data"),
                               p("Content for side panel 2")
                             )
                      ),
                      column(8,
                             wellPanel(
                               h3("Animal"),
                               p("Content for main panel 1")
                             ),
                             wellPanel(
                               h3("Food"),
                               p("Content for main panel 2")
                             )
                      )
                    )
           )
)

                             
        
                            
                          
                 
                 
                              
                            
                          
                 

