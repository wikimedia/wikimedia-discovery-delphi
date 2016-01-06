source("utils.R")

existing_date <- Sys.Date() - 1

shinyServer(function(input, output) {
  
  if (Sys.Date() != existing_date) {
    read_api()
    predict_api_cirrus()
    existing_date <<- Sys.Date()
  }
  
  output$arima_search_api_cirrus_predictions <- renderDygraph({
    dygraph(predictions_api_cirrus[, c("Actual", "Predicted", "Lower80", "Upper80")],
            ylab = "Events", group = "api-cirrus",
            main = "Predictions with a daily updated ARIMA model") %>%
      dySeries("Actual", color = "black", strokeWidth = 2) %>%
      dySeries(c("Lower80", "Predicted", "Upper80"), label = "Predicted",
               color = "red", strokeWidth = 2) %>%
      dyOptions(labelsKMB = TRUE) %>%
      dyLegend(width = 400) %>%
      dyCSS(css = system.file("custom.css", package = "polloi"))
  })
  
  output$arima_search_api_cirrus_diagnostics <- renderDygraph({
    dygraph(100 * predictions_api_cirrus[, "Rel_Diff"],
            ylab = "Relative Difference", group = "api-cirrus",
            main = "Relative percentage difference between observed and expected") %>%
      dySeries("Rel_Diff", label = "Relative Difference",
               color = "red", strokeWidth = 2) %>%
      dyAxis("y", valueRange = c(-25, 25),
             axisLabelFormatter = 'function(x) { return x + "%"; }',
             valueFormatter = 'function(x) { return round(x, 3) + "%"; }') %>%
      dyLegend(width = 400) %>%
      dyCSS(css = system.file("custom.css", package = "polloi"))
  })
  
})