# 
#
# St558 - Project 2
# Create a shiny app to query an API and summarize the data
# Jie Chen
# 07-04-2024

library(shiny)
library(shiny)
library(DT)


# Define UI for application which contains 3 tabs

navbarPage("FDA Animal & Food Aderve Effect",
           tabPanel("About",
                    fluidPage(
                      
                      titlePanel("About This App"),
                      sidebarLayout(
                        sidebarPanel(
                          h3("Data Source"),
                          p("The data is sourced from the FDA's Animal & Veterinary Adeverse Effect API and Food Enforcement API Endpoints. For more information, visit the ",
                            br(),
                            br(),
                            a("OpenFDA ", href = "https://api.fda.gov/drug/event.json?"),
                            br(),
                            br(),
                            img(src = "openFDA.png", height = "60px", width = "160px")),
                          br(),
                          p("Please know that there is a limit of 1000 observations you can query at once")
                          ),
                        
                        mainPanel(
                          h3("Purpose of the App"),
                          p("This app provides access to the FDA Animal & Veterinary API and Food API data, allowing users to search for Animal Adverse Events and Food Enforcement along with the numerical and graphical summaries."),
                          br(),
                          h3("Tab Descriptions"),
                          h4("1. ", strong("About:")) ,
                          p(" Provides information about the app, the data source, and the purpose of each tab."),
                          h4("2. ", strong("Download:")), 
                          p("- You can specify changes to the API querying and obtain the corresponding data."),
                          p("- Display the returned data"),
                          p("- Subset the data set, you can select rows and columns"),
                          p("- Allow you to save the data as .csv file"),
                          h4("3. ", strong("Exploration:")),
                          p("-This tab allow you to choose variables that are summarized via numerical and graphical summaries"),
                          p("- You can change the type of plot shown and the type of summary reported"),
                          br(),
                          br(),
                          br()
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
                               h3("Animal Adverse Effect"),
                               br(),
                               h4("Bar plots"),
                               radioButtons("plot", "Select the Plot Type", 
                                            choices = list("Just species" = "species", 
                                                           "Species and weight" = "speciesWeight", 
                                                           "Species and age" = "speciesAge"), 
                                            selected = "species"),
                               br(),
                               h5(strong("Basic Summaries"),
                               p("mean/median/min/max by animal.species")), 
                               selectInput("var", label = "Variables to Summarize",
                                           choices = c("Age", "Weight"),
                                           selected = "Age")
                             ),
                             
                             wellPanel(
                               h3("Food Reinforcement"),
                               
                               h4("Contingency Table"),
                               radioButtons("table_choice", "Select Contingency Table:",
                                            choices = list("Seriousness by Voluntary/Mandated" = "voluntary_mandated",
                                                           "Seriousness by Status" = "status")),
                               br(),
                               h4("Top states by Classification"),
                               sliderInput("top_n", "Select Number of Top States:", min = 1, max = 50, value = 10)
                               
                             )
                             
                      ),
                      column(8,
                             wellPanel(
                               h3("Animal Exploration"),
                               plotOutput("animalPlot"),
                               tableOutput("summaryTable")
                             ),
                             wellPanel(
                               h3("Food Exploration"),
                               h4(textOutput("table_title")),  # dynamic title
                               tableOutput("contingency_table"),
                               p("Classification (I, II, or III) is assigned by FDA to a indicate the relative degree of health hazard."),
                               p("I= most serious / dangerous, II= potentially dangerous and III = least dangerous."),
                               br(),
                               br(),
                               h4(textOutput("chart_title")), # dynamic title
                               plotOutput("foodPlot")  # ggplot visualization
                             )
                      )
                    )
           )

)
                             
        
                            
                          
                 
                 
                              
                            
                          
                 

