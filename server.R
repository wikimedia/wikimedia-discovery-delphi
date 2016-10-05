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
    progress$set(message = "Finished downloading datasets.", value = 1)
    existing_date <<- Sys.Date()
  }

  output$cirrus_api_arima_previous <- renderValueBox({
    value_box_previous(api_usage, "arima")
  })

  output$cirrus_api_arima_prediction <- renderValueBox({
    value_box_prediction(api_usage, "arima", input$confidence)
  })

  output$cirrus_api_bsts_previous <- renderValueBox({
    value_box_previous(api_usage, "bsts")
  })

  output$cirrus_api_bsts_prediction <- renderValueBox({
    value_box_prediction(api_usage, "bsts", input$confidence)
  })

  output$cirrus_api_predictions <- renderDygraph({
    cols_to_keep <- "actual"
    if (input$models == "both" || input$models == "arima") {
      cols_to_keep <- c(cols_to_keep,  "arima_point_est", "arima_lower_80", "arima_upper_80")
    }
    if (input$models == "both" || input$models == "bsts") {
      cols_to_keep <- c(cols_to_keep,  "bsts_point_est", "bsts_lower_80", "bsts_upper_80")
    }
    if (input$confidence == "95") {
      cols_to_keep <- sub("80", "95", cols_to_keep, fixed = TRUE)
    }
    dyOut <- dygraph(api_usage[, cols_to_keep],
            ylab = "Events", group = "api-cirrus",
            main = "Cirrus API usage modeled with ARIMA & BSTS") %>%
      dySeries("actual", label = "Actual", color = "black")
    if (input$models == "both" || input$models == "arima") {
      if (input$confidence == "95") {
        dyOut <- dySeries(dyOut, c("arima_lower_95", "arima_point_est", "arima_upper_95"), label = "ARIMA",
                          color = RColorBrewer::brewer.pal(3, "Set1")[1])
      } else {
        dyOut <- dySeries(dyOut, c("arima_lower_80", "arima_point_est", "arima_upper_80"), label = "ARIMA",
                          color = RColorBrewer::brewer.pal(3, "Set1")[1])
      }
    }
    if (input$models == "both" || input$models == "bsts") {
      if (input$confidence == "95") {
        dyOut <- dySeries(dyOut, c("bsts_lower_95", "bsts_point_est", "bsts_upper_95"), label = "BSTS",
                          color = RColorBrewer::brewer.pal(3, "Set1")[2])
      } else {
        dyOut <- dySeries(dyOut, c("bsts_lower_80", "bsts_point_est", "bsts_upper_80"), label = "BSTS",
                          color = RColorBrewer::brewer.pal(3, "Set1")[2])
      }
    }
    dyOut %>%
      dyOptions(labelsKMB = TRUE) %>%
      dyLegend(width = 400) %>%
      dyCSS(css = system.file("custom.css", package = "polloi"))
  })

  output$cirrus_api_diagnostics <- renderDygraph({
    switch(input$models,
           both = {
             cols_to_keep = c("arima_percent_error", "bsts_percent_error")
           },
           arima = {
             cols_to_keep = "arima_percent_error"
           },
           bsts = {
             cols_to_keep = "bsts_percent_error"
           })
    dyOut <- dygraph(api_usage[, cols_to_keep],
            ylab = "% Error", group = "api-cirrus",
            main = "Percent error between predicted and observed Cirrus API usage counts") %>%
      dyLimit(limit = 0)
    if (input$models == "both" || input$models == "arima") {
      dyOut <- dySeries(dyOut, "arima_percent_error", label = "ARIMA's % Error",
                        color = RColorBrewer::brewer.pal(3, "Set1")[1])
    }
    if (input$models == "both" || input$models == "bsts") {
      dyOut <- dySeries(dyOut, "bsts_percent_error", label = "BSTS's % Error",
                        color = RColorBrewer::brewer.pal(3, "Set1")[2])
    }
    dyOut %>%
      dyAxis("y", valueRange = c(-1, 1) * max(abs(as.numeric(api_usage[, c("arima_percent_error", "bsts_percent_error")])), na.rm = TRUE)) %>%
      dyLegend(width = 400) %>%
      dyCSS(css = system.file("custom.css", package = "polloi"))
  })

})
