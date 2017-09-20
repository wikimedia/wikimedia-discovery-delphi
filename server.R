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
    progress$set(message = "Downloading zero results rate forecasts & data...", value = 0)
    read_zrr()
    progress$set(message = "Downloading WDQS forecasts & data...", value = 0.5)
    read_wdqs()
    progress$set(message = "Finished downloading datasets.", value = 1)
    existing_date <<- Sys.Date()
  }

  output$zrr_overall_arima_previous <- renderValueBox({
    value_box_previous(zrr_overall, "arima", .terms = list(units = "ZRR rate"), .up_is_good = FALSE)
  })

  output$zrr_overall_arima_prediction <- renderValueBox({
    value_box_prediction(zrr_overall, "arima", input$confidence, .terms = list(units = "ZRR rate"))
  })

  output$zrr_overall_bsts_previous <- renderValueBox({
    value_box_previous(zrr_overall, "bsts", .terms = list(units = "ZRR rate"), .up_is_good = FALSE)
  })

  output$zrr_overall_bsts_prediction <- renderValueBox({
    value_box_prediction(zrr_overall, "bsts", input$confidence, .terms = list(units = "ZRR rate"))
  })

  output$zrr_overall_prophet_previous <- renderValueBox({
    value_box_previous(zrr_overall, "prophet", .terms = list(units = "ZRR rate"), .up_is_good = FALSE)
  })

  output$zrr_overall_prophet_prediction <- renderValueBox({
    value_box_prediction(zrr_overall, "prophet", input$confidence, .terms = list(units = "ZRR rate"))
  })

  output$wdqs_sparql_arima_previous <- renderValueBox({
    value_box_previous(wdqs_sparql, "arima", .terms = list(units = "Calls"))
  })

  output$wdqs_sparql_arima_prediction <- renderValueBox({
    value_box_prediction(wdqs_sparql, "arima", input$confidence, .terms = list(units = "Calls"))
  })

  output$wdqs_sparql_bsts_previous <- renderValueBox({
    value_box_previous(wdqs_sparql, "bsts", .terms = list(units = "Calls"))
  })

  output$wdqs_sparql_bsts_prediction <- renderValueBox({
    value_box_prediction(wdqs_sparql, "bsts", input$confidence, .terms = list(units = "Calls"))
  })

  output$wdqs_sparql_prophet_previous <- renderValueBox({
    value_box_previous(wdqs_sparql, "prophet", .terms = list(units = "Calls"))
  })

  output$wdqs_sparql_prophet_prediction <- renderValueBox({
    value_box_prediction(wdqs_sparql, "prophet", input$confidence, .terms = list(units = "Calls"))
  })

  output$zrr_overall_predictions <- renderDygraph({
    dygraph_predictions(zrr_overall, input$models, input$confidence, .terms = list(title = "Overall zero results rate", units = "% of searches yielding zero results"), .dygroup = "zrr-overall") %>%
      dyEvent(as.Date("2016-03-15"), "Completion Suggester", labelLoc = "bottom", color = "black", strokePattern = "dashed")
  })

  output$zrr_overall_diagnostics <- renderDygraph({
    dygraph_diagnostics(zrr_overall, input$models, .terms = list(title = "overall zero results rate"), .dygroup = "zrr-overall") %>%
      dyEvent(as.Date("2016-03-15"), "Completion Suggester", labelLoc = "bottom", color = "black", strokePattern = "dashed")
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
