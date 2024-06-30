# Load necessary libraries
library(shiny)
library(httr)
library(tidyverse)
library(jsonlite)



# Function to query the animal API endpoint
get_animal_adr <- function(search = "original_receive_date", date = "20230601", limit = 1000) {
  # Base URL for the FDA Animal & Veterinary API
  baseURL <- "https://api.fda.gov/animalandveterinary/event.json"
  
  # Construct the full URL with query parameters
  query <- paste0("?search=", search, ":", date, "&limit=", limit)
  fullURL <- URLencode(paste0(baseURL, query))
  
  # Print the full URL for debugging
  message("Requesting URL: ", fullURL)
  
  # Fetch and parse the JSON data directly from the URL
  response <- tryCatch({
    fromJSON(fullURL)
  }, error = function(e) {
    message("Error fetching data: ", e)
    return(NULL)
  })
  
  # Check if the response is valid
  if (is.null(response) || is.null(response$results)) {
    return(data.frame())
  }
  
  # Extract the results
  output <- response$results
  
  return(output)
}

# Test the function with customizable parameters
output <- get_animal_adr(search = "original_receive_date", date = "20230501", limit = 1000)

# Print the results
print(output)

