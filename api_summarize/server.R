#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define the server logic
function(input, output) {
  
  observeEvent(input$submit_drugs, {
    results <- get_animal_drugs(input$search_drugs, input$limit_drugs)
    output$results_drugs <- renderDT({
      results
    })
  })
  
  observeEvent(input$submit_events, {
    results <- get_adverse_events(input$search_events, input$limit_events)
    output$results_events <- renderDT({
      results
    })
  })
  
  observeEvent(input$submit_recalls, {
    results <- get_recalls(input$search_recalls, input$limit_recalls)
    output$results_recalls <- renderDT({
      results
    })
  })
  
  observeEvent(input$submit_enforcement, {
    results <- get_enforcement_reports(input$search_enforcement, input$limit_enforcement)
    output$results_enforcement <- renderDT({
      results
    })
  })
  
  observeEvent(input$submit_ndc, {
    results <- get_ndc_directory(input$search_ndc, input$limit_ndc)
    output$results_ndc <- renderDT({
      results
    })
  })
  
  observeEvent(input$submit_approvals, {
    results <- get_animal_drug_approvals(input$search_approvals, input$limit_approvals)
    output$results_approvals <- renderDT({
      results
    })
  })
}
