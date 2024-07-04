#
# Project 2 -st558
#

# server

library(shiny)
library(DT)

# Define the server logic
function(input, output, session) {
  # Reactive values to store API data
  animal_data <- reactiveVal(NULL)
  food_data <- reactiveVal(NULL)
  
  selected_columns_animal <- reactiveVal(NULL)
  selected_columns_food <- reactiveVal(NULL)
  
  observeEvent(input$submit_animal, {
    req(input$search_animal, input$date_animal, input$limit_animal)
    data <- get_animal_adr(input$search_animal, input$date_animal, input$limit_animal)
    data <- flatten_list_columns(data)
    animal_data(data)
    selected_columns_animal(names(data)) # Initialize with all columns selected
  })
  
  observeEvent(input$submit_food, {
    req(input$date_range_food, input$limit_food)
    data <- get_food_data(input$date_range_food, input$limit_food)
    #data <- flatten_list_column(data)
    food_data(data)
    selected_columns_food(names(data)) # Initialize with all columns selected
  })
  
  output$results_animal <- renderDT({
    req(animal_data())
    data <- animal_data()
    columns <- selected_columns_animal()
    if (!is.null(columns)) {
      data <- data[, columns, drop = FALSE]
    }
    datatable(data, options = list(pageLength = input$rows_to_display_animal, searching=FALSE))
  })
  
  output$results_food <- renderDT({
    req(food_data())
    data <- food_data()
    columns <- selected_columns_food()
    if (!is.null(columns)) {
      data <- data[, columns, drop = FALSE]
    }
    datatable(data, options = list(pageLength = input$rows_to_display_food,searching=FALSE))
  })
  
  output$column_selector_animal <- renderUI({
    req(animal_data())
    data <- animal_data()
    checkboxGroupInput("columns_animal", "Select columns to display", choices = names(data), selected = names(data))
  })
  
  output$column_selector_food <- renderUI({
    req(food_data())
    data <- food_data()
    checkboxGroupInput("columns_food", "Select columns to display", choices = names(data), selected = names(data))
  })
  
  observeEvent(input$columns_animal, {
    selected_columns_animal(input$columns_animal)
  })
  
  observeEvent(input$columns_food, {
    selected_columns_food(input$columns_food)
  })
  
  observeEvent(animal_data(), {
    updateNumericInput(session, "rows_to_display_animal", max = nrow(animal_data()))
  })
  
  observeEvent(food_data(), {
    updateNumericInput(session, "rows_to_display_food", max = nrow(food_data()))
  })
  
  output$download_data_animal <- downloadHandler(
    filename = function() {
      paste("animal_data.csv")
    },
    content = function(file) {
      data <- animal_data()
      columns <- selected_columns_animal()
      if (!is.null(columns)) {
        data <- data[, columns, drop = FALSE]
      }
      data <- head(data, input$rows_to_display_animal)
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  output$download_data_food <- downloadHandler(
    filename = function() {
      paste("food_data.csv")
    },
    content = function(file) {
      data <- food_data()
      columns <- selected_columns_food()
      if (!is.null(columns)) {
        data <- data[, columns, drop = FALSE]
      }
      data <- head(data, input$rows_to_display_food)
      write.csv(data, file, row.names = FALSE)
    }
  )
}