#
# St558 - Project 2
# Create a shiny app to query an API and summarize the data
# Jie Chen

# Load necessary libraries
library(shiny)
library(httr)
library(tidyverse)
library(jsonlite)
library(DT)
library(ggplot2)
library(ggcharts)
library(shinybusy)
library(tools)

# Function to flatten list columns
flatten_list_columns <- function(data) {
  for (col in names(data)) {
    if (is.list(data[[col]])) {
      # Flatten list columns by converting them to a character string
      data[[col]] <- sapply(data[[col]], function(x) paste(unlist(x), collapse = ", "))
    }
  }
  return(data)
}

# Function to query the all animal data with specific date 
get_animal_adr <- function(search = "original_receive_date", date = "20230601", limit = 1000) {
  baseURL <- "https://api.fda.gov/animalandveterinary/event.json"
  query <- paste0("?search=", search, ":", date, "&limit=", limit)
  fullURL <- URLencode(paste0(baseURL, query))
  outputAPI <- fromJSON(fullURL, flatten = TRUE)
  output <- outputAPI$results
  output <- flatten_list_columns(as_tibble(output)) # un-nested some columns
  return(output)
}

# Function to request specific animal species and date 
animal_species <- function(species, date, limit = 1000) {
  # Internal function to validate the date format
  validate_date <- function(date) {
    if (!grepl("^\\d{8}$", date)) {
      # If the date is not in YYYYMMDD format, use the default date
      return("20230601")
    }
    return(date)
  }
  
  # Internal function to validate the species input
  validate_species <- function(species) {
    # Convert species input to have the first letter uppercase and the rest lowercase
    species <- tolower(species)
    species <- tools::toTitleCase(species)
    valid_species <- c("Cat", "Dog", "Cattle", "Goat", "Horse")
    
    if (!species %in% valid_species) {
      # If the species is not valid, use the default species
      return("Cat")
    }
    return(species)
  }
  
  # Validate inputs
  date <- validate_date(date)
  species <- validate_species(species)
  
  # Construct the query URL
  base_url <- "https://api.fda.gov/animalandveterinary/event.json"
  query <- paste0("search=animal.species:", species, "+AND+original_receive_date:", date, "&limit=", limit)
  full_url <- paste0(base_url, "?", URLencode(query))
  response <- GET(full_url)
  
  data <- fromJSON(content(response, "text"), flatten = TRUE)$results
  data <- flatten_list_columns(as_tibble(data))
  return(data)
}


# Function to query the food data with specific date range
get_food_data <- function(date_range = "20240101+TO+20240531", limit = 1000) {
  base_url <- "https://api.fda.gov/food/enforcement.json"
  query <- paste0("?search=report_date:[", date_range, "]&limit=", limit)
  fullURL <- URLencode(paste0(base_url, query))
  outputAPI <- fromJSON(fullURL, flatten = TRUE)
  output <- outputAPI$results
  output <- flatten_list_columns(as_tibble(output)) # make sure columns un-nested
  return(output)
}


