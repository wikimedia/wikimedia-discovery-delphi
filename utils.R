# Dependent libs
library(magrittr)
library(polloi)
library(xts)
library(forecast)

read_api <- function() {
  api_usage <<- polloi::read_dataset("search/search_api_aggregates.tsv") %>%
  tidyr::spread(event_type, events) %>%
  { xts::xts(.[, -1], order.by = .$timestamp) }
}

predict_backfill_arima <- function(data, var, arima_params = NULL, days = 7,
                                   scaling_function = function(x, x_ref) { max(x, x_ref) }) {
  if (is.null(arima_params)) {
    arima_params <- list(order = c(0L, 0L, 0L),
                         seasonal = list(order = c(0L, 0L, 0L), period = NA))
  }
  n <- days; predictions <- as.data.frame(matrix(0, nrow = n + 1, ncol = 4))
  days <- tail(index(data), n)
  days <- c(days, days[n] + 1)
  for ( i in 1:length(days) ) {
    day <- days[i]
    fit <- arima(data[sprintf('/%s', day - 1), var],
                 order = arima_params$order,
                 seasonal = arima_params$seasonal)
    predicted <- forecast(fit, h = 1)
    reality <- as.numeric(data[day, var])
    if (length(reality) == 0) {
      reality <- NA
    }
    predictions[i, ] <- cbind(reality, as.data.frame(predicted)[, 1:3])
  }; rm(fit, predicted, reality, i, day, n)
  predictions$Rel_Diff = apply(predictions[, 1:2], 1, function(x) { return((x[2]-x[1])/scaling_function(x[2], x[1])) })
  predictions$Date <- days
  predictions <- xts(predictions[, 1:5], order.by = predictions$Date)
  prior_data <- cbind(data[!(index(data) %in% days), var], NA, NA, NA, NA)
  predictions <- rbind(prior_data, predictions)
  colnames(predictions) <- c('Actual', 'Predicted', 'Lower80', 'Upper80', 'Rel_Diff')
  return(predictions)
}

predict_api_cirrus <- function(days = 90) {
  predictions_api_cirrus <<- predict_backfill_arima(api_usage, 'cirrus', days = days,
    arima_params = list(order = c(0, 1, 2), seasonal = list(order = c(2, 1, 1), period = 7)))
}
