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
  
  # Get the data from the endpoint
  outputAPI <-fromJSON(fullURL, flatten = TRUE)
  
  # Extract the results
  output <- outputAPI$results
  output <- as_tibble(output)
  return(output)
}

# Test the function with customizable parameters
#output <- get_animal_adr(search = "original_receive_date", date = "20230501", limit = 1000)


get_food_data <- function(date_range = "20240101+TO+20240531", limit = 1000) {
  # Construct the full URL with query parameters
  base_url <- "https://api.fda.gov/food/enforcement.json"
  query <- paste0("?search=report_date:[", date_range, "]&limit=", limit)
  fullURL <- URLencode(paste0(base_url, query))
  
  # Get the data from the endpoint
  outputAPI <-fromJSON(fullURL, flatten = TRUE)
  
  # Extract the results
  output <- outputAPI$results
  output <- as_tibble(output)
  return(output)
}



# Test the function
get_food_data(date_range = "20240101+TO+20240531", limit = 1000)

# create a wrapper function for the above two.
fdaAPI <-function(func,...){
  if (func =="get_animal_adr"){
    output <- get_animal_adr(...)
  } else if (func =="get_food_data"){
    output <- get_food_data(...)
  } else {
    stop("ERROR: Argument for func is not valid!")
  }
  return(output)
}

output <- get_animal_adr(search = "original_receive_date", date = "20230601", limit = 1000)

str(output)

# Convert columns to numeric
output$animal.weight.min <- as.numeric(output$animal.weight.min)
output$animal.age.min <- as.numeric(output$animal.age.min)
output$number_of_animals_treated <-as.numeric(output$number_of_animals_treated)
output$number_of_animals_affected <- as.numeric(output$number_of_animals_affected)

# Function to convert age to years (deal with different age units)
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


# Apply conversion to each row to create a new column 'age_in_years'
output$age_in_years <- mapply(convert_to_years, output$animal.age.min, output$animal.age.unit)

# Print the updated data frame
print(output)


# Convert animal.weight.min and age to numeric
output$animal.weight.min <- as.numeric(output$animal.weight.min)
output$age.age.min <- as.numeric(output$age)

# Unnest the list column to create a reaction_terms data frame
reaction_terms <- output %>%
  unnest(cols = c(reaction), names_sep = "_") %>%
  unnest(cols = c(reaction_veddra_term_name), names_sep = "_")

# Define the reaction categories
vomiting <- c("Vomiting", "Nausea")
lethargy <- c("Lethargy", "Fatigue")
diarrhoea <- c("Diarrhoea", "Diarrhea")
lack_of_efficacy <- c("Lack of efficacy")
ineffective <-c("ineffective, heartworm larvae")
emesis <- c("Emesis")
anorexia <- c("Anorexia")
death <- c("Death")
depression <- c("Depression")
Seizure_NOS <-c("Seizure NOS")
not_eating <-c("Not eating")

# Categorize the reaction_veddra_term_name
reaction_new <- reaction_terms %>%
  mutate(reactions = case_when(
    str_detect(reaction_veddra_term_name, "Vomiting|Nausea") ~ "Vomiting",
    str_detect(reaction_veddra_term_name, "Lethargy|Fatigue") ~ "Lethargy",
    str_detect(reaction_veddra_term_name, "Diarrhoea|Diarrhea") ~ "Diarrhoea",
    str_detect(reaction_veddra_term_name, "Lack of efficacy") ~ "Lack of efficacy",
    str_detect(reaction_veddra_term_name, "Emesis") ~ "Emesis",
    str_detect(reaction_veddra_term_name, "Anorexia") ~ "Anorexia",
    str_detect(reaction_veddra_term_name, "Death") ~ "Death",
    str_detect(reaction_veddra_term_name, "Depression") ~ "Depression",
    str_detect(reaction_veddra_term_name, "Seizure|NOS") ~ "Seizure NOS",
    str_detect(reaction_veddra_term_name, "Not|eating") ~"Not eating",
    TRUE ~ 'Others'
  ))

# Create the contingency table of reports on animal species and gender
contingency_gender <- table(output$animal.species,output$animal.gender)
# Print the contingency table
print(contingency_gender)

conti_reaction_gender <- table(reaction_new$reactions, reaction_new$animal.gender)
print(conti_reaction_gender)
conti_reaction_species <- table(reaction_new$reactions, reaction_new$animal.species)
print(conti_reaction_species)


# create the contigency table of reports on primary reporter and animal species
contigency_react <-table(output$animal.species,output$primary_reporter )
print(contigency_react)



# Plotting
animal_hist <- ggplot(output, aes(x=animal.weight.min, fill=animal.gender)) +
  geom_histogram(alpha=0.3, position='identity', binwidth = 1) + 
  ggtitle("Reaction by Weight and Gender") +
  xlab("Animal Weight (kg)") +
  theme_minimal()

animal_reaction_speicies <- ggplot(output, aes(x=animal.age.min, fill=animal.species))+
  geom_histogram(alpha=0.3, position='identity', binwidth = 1) + 
  ggtitle("Reaction by Species and Ages") +
  xlab("Animal Age (Year)") +
  theme_minimal()



# Display the plot
print(animal_hist)
print(animal_reaction_speicies) 
