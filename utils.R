# Dependent libs
library(magrittr)
library(polloi)
library(xts)
library(dplyr)
library(forecast)
library(ggplot2)
library(gridExtra)

read_api <- function() {
  api_usage <<- polloi::read_dataset("search/search_api_aggregates.tsv") %>%
  tidyr::spread(event_type, events) %>%
  { xts::xts(.[, -1], order.by = .$timestamp) }
}

backfill_online_predictions_with_arima <- function(data, var,
                                                   arima_params = NULL,
                                                   days = 7,
                                                   scaling_function = function(x, x_ref) { max(x, x_ref) },
                                                   progress = FALSE) {
  if (is.null(arima_params)) {
    arima_params <- list(order = c(0L, 0L, 0L),
                         seasonal = list(order = c(0L, 0L, 0L), period = NA))
  }
  n <- days; predictions <- as.data.frame(matrix(0, nrow = n, ncol = 6))
  days <- tail(index(data), n)
  if (progress) {
    pb <- progress_bar$new(total = n)
  }
  for ( i in 1:length(days) ) {
    if (progress) {
      pb$tick()
    }
    day <- days[i]
    fit <- arima(data[sprintf('/%s', day - 1), var],
                 order = arima_params$order,
                 seasonal = arima_params$seasonal)
    predicted <- forecast(fit, h = 1)
    reality <- as.numeric(data[day, var])
    predictions[i, ] <- cbind(reality, as.data.frame(predicted)[, 1:3])
  }; rm(fit, predicted, reality, i, day, n)
  if (progress) {
    rm(pb)
  }
  colnames(predictions) <- c('Actual', 'Predicted',
                             'Lower80', 'Upper80',
                             'Lower95', 'Upper95')
  predictions$Date <- days
  predictions <- transform(predictions, Rel_Diff = (Predicted - Actual) / scaling_function(Predicted, Actual))
  return(predictions[, union('Date', names(predictions))])
}

predict_api_cirrus <- function(days = 90) {
  predictions_api_cirrus <<- backfill_online_predictions_with_arima(api_usage, 'cirrus', days = days,
    arima_params = list(order = c(0, 1, 2), seasonal = list(order = c(2, 1, 1), period = 7))) %>%
    { xts(.[, -1], order.by = .$Date) }
}
