# Project2_API

This project is to allow user to run the shiny app from the GitHub and access the API and summarize the data.
This app provides access to the FDA Animal & Veterinary API and Food API data, allowing users to search for Animal Adverse Events and Food Enforcement along with the numerical and graphical summaries.

The app includes 3 Tabs:
1. About.

The data is sourced from the FDA's Animal & Veterinary Adeverse Effect API and Food Enforcement API Endpoints from openFDA.
There is a limit of 1000 observations you can query at once

2. Download.

You can specify changes to the API querying and obtain the corresponding data.
- Display the returned data- Subset the data set, you can select 
- Allow you to save the data as .csv filerows and columns

3. Exploration. 

Based on your query,
- This tab allow you to choose variables that are summarized via numerical and graphical summaries
- You can change the type of plot shown and the type of summary reported

The packages you will need given in the below code:

install.packages(c("shiny", "tidyverse", "ggplot2", "jsonlite", "httr", "ggcharts", "shinybusy", "shinycssloaders", "DT"))

You can use the code below that copy and paste into RStudio to run this app.

shiny::runGitHub("triplepine/Project2_API", subdir = "api_summarize")