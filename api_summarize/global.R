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

# Function to query the animal API endpoint
get_animal_adr <- function(search = "original_receive_date", date = "20230601", limit = 1000) {
  baseURL <- "https://api.fda.gov/animalandveterinary/event.json"
  query <- paste0("?search=", search, ":", date, "&limit=", limit)
  fullURL <- URLencode(paste0(baseURL, query))
  outputAPI <- fromJSON(fullURL, flatten = TRUE)
  output <- outputAPI$results
  output <- as_tibble(output)
  return(output)
}

# Function to query the food API endpoint
get_food_data <- function(date_range = "20240101+TO+20240531", limit = 1000) {
  base_url <- "https://api.fda.gov/food/enforcement.json"
  query <- paste0("?search=report_date:[", date_range, "]&limit=", limit)
  fullURL <- URLencode(paste0(base_url, query))
  outputAPI <- fromJSON(fullURL, flatten = TRUE)
  output <- outputAPI$results
  output <- as_tibble(output)
  return(output)
}

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




