source("utils.R")

existing_date <- Sys.Date() - 1

shinyServer(function(input, output) {
  
  if (Sys.Date() != existing_date) {
    read_api()
    predict_api_cirrus(90)
    existing_date <<- Sys.Date()
  }
  
  output$arima_search_api_cirrus_previous <- renderValueBox({
    temp <- as.numeric(abs(tail(predictions_api_cirrus, 2)[1, "Rel_Diff"]))
    valueBox(sprintf("%.2f%% %s requests than expected",
                     100 * tail(predictions_api_cirrus, 2)$Rel_Diff[1],
                     ifelse(temp < 0, "more", "less")),
             paste0("Relative % difference for 'yesterday' (", tail(index(predictions_api_cirrus), 2)[1],")"),
             color = polloi::cond_color(temp < 0.1))
  })
  
  output$arima_search_api_cirrus_prediction <- renderValueBox({
    temp <- polloi::compress(tail(predictions_api_cirrus, 1)[, 2:4])
    valueBox(sprintf("~%s (%s-%s)", temp[1], temp[2], temp[3]),
             paste0("Expected requests and 80% Confidence Interval for 'today' (",
                    tail(index(predictions_api_cirrus), 1), ")"), color = "black")
  })
  
  output$arima_search_api_cirrus_predictions <- renderDygraph({
    dygraph(predictions_api_cirrus[, c("Actual", "Predicted", "Lower80", "Upper80")],
            ylab = "Events", group = "api-cirrus",
            main = "Predictions with a daily updated ARIMA model") %>%
      dySeries("Actual", color = "black", strokeWidth = 2) %>%
      dySeries(c("Lower80", "Predicted", "Upper80"), label = "Predicted",
               color = "blue", strokeWidth = 2) %>%
      dyOptions(labelsKMB = TRUE) %>%
      dyLegend(width = 400) %>%
      dyCSS(css = system.file("custom.css", package = "polloi"))
  })
  
  output$arima_search_api_cirrus_diagnostics <- renderDygraph({
    dygraph(100 * predictions_api_cirrus[, "Rel_Diff"],
            ylab = "Relative Difference", group = "api-cirrus",
            main = "Relative percentage difference between observed and expected") %>%
      dyLimit(limit = 0) %>%
      dySeries("Rel_Diff", label = "Relative Difference",
               color = "blue", strokeWidth = 2) %>%
      dyAxis("y", valueRange = c(-25, 25),
             axisLabelFormatter = 'function(x) { return x + "%"; }',
             valueFormatter = 'function(x) { return round(x, 3) + "%"; }') %>%
      dyLegend(width = 400) %>%
      dyCSS(css = system.file("custom.css", package = "polloi"))
  })
  
})