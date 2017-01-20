library(shiny)
library(shinydashboard)
library(dygraphs)
library(xts)

source("utils.R")

existing_date <- Sys.Date() - 1

shinyServer(function(input, output, session) {

  if (Sys.Date() != existing_date) {
    progress <- shiny::Progress$new(session, min = 0, max = 1)
    on.exit(progress$close())
    progress$set(message = "Downloading Cirrus API forecasts & data...", value = 0)
    read_api()
    progress$set(message = "Downloading zero results rate forecasts & data...", value = 0.333)
    read_zrr()
    progress$set(message = "Downloading WDQS forecasts & data...", value = 0.666)
    read_wdqs()
    progress$set(message = "Finished downloading datasets.", value = 1)
    existing_date <<- Sys.Date()
  }

  output$zrr_overall_arima_previous <- renderValueBox({
    value_box_previous(zrr_overall, "arima", .terms = list(units = "ZRR rate", up = "higher", down = "lower"), .up_is_good = FALSE)
  })

  output$zrr_overall_arima_prediction <- renderValueBox({
    value_box_prediction(zrr_overall, "arima", input$confidence, .terms = list(units = "ZRR rate"))
  })

  output$zrr_overall_bsts_previous <- renderValueBox({
    value_box_previous(zrr_overall, "bsts", .terms = list(units = "ZRR rate", up = "higher", down = "lower"), .up_is_good = FALSE)
  })

  output$zrr_overall_bsts_prediction <- renderValueBox({
    value_box_prediction(zrr_overall, "bsts", input$confidence, .terms = list(units = "ZRR rate"))
  })

  output$cirrus_api_arima_previous <- renderValueBox({
    value_box_previous(api_usage, "arima", .terms = list(units = "requests", up = "more", down = "less"))
  })

  output$cirrus_api_arima_prediction <- renderValueBox({
    value_box_prediction(api_usage, "arima", input$confidence, .terms = list(units = "requests"))
  })

  output$cirrus_api_bsts_previous <- renderValueBox({
    value_box_previous(api_usage, "bsts", .terms = list(units = "requests", up = "more", down = "less"))
  })

  output$cirrus_api_bsts_prediction <- renderValueBox({
    value_box_prediction(api_usage, "bsts", input$confidence, .terms = list(units = "requests"))
  })

  output$zrr_overall_predictions <- renderDygraph({
    dygraph_predictions(zrr_overall, input$models, input$confidence, .terms = list(title = "Overall zero results rate", units = "% of searches yielding zero results"), .dygroup = "zrr-overall") %>%
      dyEvent(as.Date("2016-03-15"), "Completion Suggester", labelLoc = "bottom", color = "black", strokePattern = "dashed")
  })

  output$zrr_overall_diagnostics <- renderDygraph({
    dygraph_diagnostics(zrr_overall, input$models, .terms = list(title = "overall zero results rate"), .dygroup = "zrr-overall") %>%
      dyEvent(as.Date("2016-03-15"), "Completion Suggester", labelLoc = "bottom", color = "black", strokePattern = "dashed")
  })

  output$cirrus_api_predictions <- renderDygraph({
    dygraph_predictions(api_usage, input$models, input$confidence, .terms = list(title = "Cirrus API usage", units = "Calls"), .dygroup = "cirrus-api")
  })

  output$cirrus_api_diagnostics <- renderDygraph({
    dygraph_diagnostics(api_usage, input$models, .terms = list(title = "Cirrus API usage counts"), .dygroup = "cirrus-api")
  })

  output$wdqs_homepage_predictions <- renderDygraph({
    dygraph_predictions(wdqs_homepage, input$models, input$confidence, .terms = list(title = "WDQS homepage traffic", units = "Visits"), .dygroup = "wdqs-homepage")
  })

  output$wdqs_homepage_diagnostics <- renderDygraph({
    dygraph_diagnostics(wdqs_homepage, input$models, .terms = list(title = "WDQS homepage visits"), .dygroup = "wdqs-homepage")
  })

  output$wdqs_sparql_predictions <- renderDygraph({
    dygraph_predictions(wdqs_sparql, input$models, input$confidence, .terms = list(title = "SPARQL endpoint usage", units = "Calls"), .dygroup = "wdqs-sparql")
  })

  output$wdqs_sparql_diagnostics <- renderDygraph({
    dygraph_diagnostics(wdqs_sparql, input$models, .terms = list(title = "SPARQL endpoint usage counts"), .dygroup = "wdqs-sparql")
  })

})
