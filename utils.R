# Dependent libs
library(magrittr)
library(polloi)

read_api <- function() {
  # arima_forecast <- read_dataset("discovery-forecasts/search_api_arima.tsv", col_types = "Dddddd")
  arima_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/search_api_arima.tsv", col_types = "Dddddd")
  names(arima_forecast) <- c("date", paste0("arima_", names(arima_forecast)[-1]))
  # bsts_forecast <- read_dataset("discovery-forecasts/search_api_bsts.tsv")
  bsts_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/search_api_bsts.tsv", col_types = "Dddddd")
  names(bsts_forecast) <- c("date", paste0("bsts_", names(bsts_forecast)[-1]))
  interim <- read_dataset("search/search_api_aggregates.tsv", col_names = c("date", "type", "events"), col_types = "cci", skip = 1) %>%
    { .$date <- as.Date(.$date); . } %>%
    dplyr::distinct(date, type, .keep_all = TRUE) %>%
    dplyr::filter(type == "cirrus") %>%
    tidyr::spread(type, events) %>%
    dplyr::rename(actual = cirrus) %>%
    dplyr::full_join(arima_forecast, by = "date") %>%
    dplyr::full_join(bsts_forecast, by = "date") %>%
    dplyr::mutate(
      arima_percent_error = 100*(actual - arima_point_est)/arima_point_est,
      bsts_percent_error = 100*(actual - bsts_point_est)/bsts_point_est
    )
  api_usage <<- xts::xts(interim[, -1], order.by = interim$date)
}

value_box_previous <- function(data, model = c("arima", "bsts")) {
  cols_to_keep <- c("actual", paste0(model[1], c("_point_est", "_percent_error")))
  temp <- tail(api_usage, 2)[1, cols_to_keep]
  return({
    valueBox(value = sprintf("%.2f%% %s requests than expected",
                             temp[[3]], ifelse(temp[[3]] > 0, "more", "less")),
             subtitle = paste("% error for", as.character(index(temp), "%A (%d %B %Y) |"), polloi::compress(temp[[1]]), "actual vs.", polloi::compress(temp[[2]]), "predicted by", toupper(model[1])),
             color = polloi::cond_color(temp[[3]] > 0))
  })
}

value_box_prediction <- function(data, model = c("arima", "bsts"), conf_level = c("80", "95")) {
  cols_to_keep <- paste0(model[1], c("_point_est", paste0(c("_lower_", "_upper_"), conf_level[1])))
  temp <- tail(data, 1)[, cols_to_keep]
  return({
    valueBox(value = sprintf("~%s (%s-%s)", polloi::compress(temp[[1]]), polloi::compress(temp[[2]]), polloi::compress(temp[[3]])),
             subtitle = paste0("Expected requests and ", conf_level, "% Confidence Interval for ", as.character(index(temp), "%a (%d %B %Y)")),
             color = "black")
  })
}
