#
# St558 - Project 2
# Create a shiny app to query an API and summarize the data
# Jie Chen

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

  # The Exploration tab
  
  # animal_data with plots by species (based on age/weight)
  # Reactive expression to clean and transform data for exploration
  cleaned_animal_data <- reactive({
    req(animal_data())
    data <- animal_data()
    data$animal.weight.min <- as.numeric(data$animal.weight.min)
    data$animal.age.min <- as.numeric(data$animal.age.min)
    data$number_of_animals_treated <- as.numeric(data$number_of_animals_treated)
    data$number_of_animals_affected <- as.numeric(data$number_of_animals_affected)
    
    # deal with the age unit variable to the consistent unit year
    convert_to_years <- function(age, unit) {
      if (is.na(age) || is.na(unit)) {
        return(NA)
      }
      if (unit == "Year") {
        return(as.numeric(age))
      } else if (unit == "Month") {
        return(as.numeric(age) / 12)
      } else {
        return(as.numeric(NA))
      }
    }
    
    data$age_in_years <- mapply(convert_to_years, data$animal.age.min, data$animal.age.unit)
    
    data
  })
  
  # Reactive expression to summarize data based on selected variable
  summary_data <- reactive({
    req(cleaned_animal_data())
    data <- cleaned_animal_data()
    if (input$var == "Age") {
      data %>% 
        filter(animal.species %in% c("Cat","Dog","Cattle","Goat","Horse")) %>%
        group_by(animal.species) %>%
        summarise(mean_age = mean(age_in_years, na.rm = TRUE),
                  median_age = median(age_in_years, na.rm = TRUE),
                  min_age = ifelse(all(is.na(age_in_years)), NA, min(age_in_years, na.rm = TRUE)),
                  max_age = ifelse(all(is.na(age_in_years)), NA, max(age_in_years, na.rm = TRUE)))
    } else {
      data %>%
        filter(animal.species %in% c("Cat","Dog","Cattle","Goat","Horse")) %>%
        group_by(animal.species) %>%
        summarise(mean_weight = mean(animal.weight.min, na.rm = TRUE),
                  median_weight = median(animal.weight.min, na.rm = TRUE),
                  min_weight = ifelse(all(is.na(animal.weight.min)), NA, min(animal.weight.min, na.rm = TRUE)),
                  max_weight = ifelse(all(is.na(animal.weight.min)), NA, max(animal.weight.min, na.rm = TRUE)))
    }
  })
  
  # Render the summary table
  output$summaryTable <- renderTable({
    summary_data()
  })
  
  # Reactive expression to create plot based on selected type
  plot_data <- reactive({
    req(cleaned_animal_data())
    data <- cleaned_animal_data()
    
    # Define the levels for the animal species
    species_levels <- c("Cat", "Dog", "Cattle", "Goat", "Horse")
    
    data <- data %>%
      filter(animal.species %in% species_levels) %>%
      drop_na(animal.species, animal.weight.min, age_in_years) %>%
      mutate(animal.species = factor(animal.species, levels = species_levels))
    
    if (input$plot == "species") {
      ggplot(data, aes(x = animal.species, fill= animal.species)) +
        geom_bar() +
        labs(title = "Count of Species", x = "Species", y = "Count")
    } else if (input$plot == "speciesWeight") {
      ggplot(data, aes(x = animal.species, y = animal.weight.min, fill= animal.species)) +
        geom_bar(stat = "identity") +
        labs(title = "Species and Weight", x = "Species", y = "Weight")
    } else if (input$plot == "speciesAge") {
      ggplot(data, aes(x = animal.species, y = age_in_years, fill= animal.species)) +
        geom_bar(stat = "identity") +
        labs(title = "Species and Age", x = "Species", y = "Age")
    }
  })
  
  # Render the plot
  output$animalPlot <- renderPlot({
    plot_data()
  })
  
  # Reactive expression for food data
  queried_food_data <- reactive({
    get_food_data()
  })
  
  # Cleaned food data
  cleaned_food_data <- reactive({
    data <- queried_food_data()
    data$classification <- factor(data$classification)
    data$voluntary_mandated <- factor(data$voluntary_mandated)
    data$status <- factor(data$status)
    return(data)
  })
  
  # Dynamic title for the contingency table
  output$table_title <- renderText({
    table_choice <- input$table_choice
    if (table_choice == "voluntary_mandated") {
      return("Contingency Table: Classification by Voluntary/Mandated")
    } else if (table_choice == "status") {
      return("Contingency Table: Classification by Status")
    }
  })
  
  # Food data contingency table
  output$contingency_table <- renderTable({
    data <- cleaned_food_data()
    table_choice <- input$table_choice
    
    if (table_choice == "voluntary_mandated") {
      contingency_table <- table(data$classification, data$voluntary_mandated)
      contingency_table <- as.data.frame.matrix(contingency_table)
      contingency_table <- cbind(Classification = rownames(contingency_table), contingency_table)
    } else if (table_choice == "status") {
      contingency_table <- table(data$classification, data$status)
      contingency_table <- as.data.frame.matrix(contingency_table)
      contingency_table <- cbind(Classification = rownames(contingency_table), contingency_table)
    }
    
    contingency_table
  })
  
  # Fancy ggcharts visualization
  output$foodPlot <- renderPlot({
    data <- cleaned_food_data()
    top_n <- input$top_n
    
  # Summarize data by state and classification
    state_summary <- data %>%
      group_by(state, classification) %>%
      summarize(count = n(), .groups = "drop") %>%
      arrange(desc(count)) %>%
      group_by(state) %>%
      top_n(10, count) %>%
      ungroup()
    
  # Filter for top n states by total number of reports
    top_states <- state_summary %>%
      group_by(state) %>%
      summarize(total_count = sum(count), .groups = "drop") %>%
      arrange(desc(total_count)) %>%
      top_n(top_n, total_count) %>%
      pull(state)
    
    state_summary <- state_summary %>%
      filter(state %in% top_states)
    
    # Create the bar chart using ggcharts
    ggcharts::bar_chart(state_summary, x = state, y = count, facet = classification) +
      labs(title = paste("Top", top_n, "States by Number of Reports"), x = "State", y = "Number of Reports")
  })
}