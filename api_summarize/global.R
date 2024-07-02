# Load necessary libraries
library(shiny)
library(httr)
library(tidyverse)
library(jsonlite)


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

# Function to convert lists in columns to strings and ensure consistent column lengths
flatten_list_column <- function(df) {
  max_length <- max(sapply(df, length))
  df <- as.data.frame(lapply(df, function(col) {
    if (is.list(col)) {
      col <- sapply(col, function(x) {
        if (is.list(x)) {
          return(paste(unlist(x), collapse = ", "))
        } else {
          return(as.character(x))
        }
      })
    }
    # Ensure the column has the correct length
    if (length(col) < max_length) {
      col <- c(col, rep(NA, max_length - length(col)))
    }
    return(col)
  }))
  return(df)
}



