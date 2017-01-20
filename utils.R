# Dependent libs
library(magrittr)
library(polloi)

read_api <- function() {
  arima_forecast <- read_dataset("discovery-forecasts/api_cirrus_arima.tsv", col_types = "Dddddd")
  # arima_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/search_api_arima.tsv", col_types = "Dddddd")
  names(arima_forecast) <- c("date", paste0("arima_", names(arima_forecast)[-1]))
  bsts_forecast <- read_dataset("discovery-forecasts/api_cirrus_bsts.tsv", col_types = "Dddddd")
  # bsts_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/search_api_bsts.tsv", col_types = "Dddddd")
  names(bsts_forecast) <- c("date", paste0("bsts_", names(bsts_forecast)[-1]))
  interim <- read_dataset("search/search_api_aggregates.tsv", col_names = c("date", "type", "events"), col_types = "cci", skip = 1) %>%
    # readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/search/search_api_aggregates.tsv", col_names = c("date", "type", "events"), col_types = "cci", skip = 1) %>%
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

read_zrr <- function() {
  arima_forecast <- read_dataset("discovery-forecasts/zrr_overall_arima.tsv", col_types = "Dddddd")
  # arima_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/zrr_overall_arima.tsv", col_types = "Dddddd")
  names(arima_forecast) <- c("date", paste0("arima_", names(arima_forecast)[-1]))
  bsts_forecast <- read_dataset("discovery-forecasts/zrr_overall_bsts.tsv", col_types = "Dddddd")
  # bsts_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/zrr_overall_bsts.tsv", col_types = "Dddddd")
  names(bsts_forecast) <- c("date", paste0("bsts_", names(bsts_forecast)[-1]))
  interim <- read_dataset("search/cirrus_query_aggregates_no_automata.tsv", col_types = "Dd") %>%
    # readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/search/cirrus_query_aggregates_no_automata.tsv", col_types = "Dd") %>%
    dplyr::full_join(arima_forecast, by = "date") %>%
    dplyr::full_join(bsts_forecast, by = "date") %>%
    dplyr::rename(actual = rate) %>%
    dplyr::mutate(
      arima_percent_error = 100*(actual - arima_point_est)/arima_point_est,
      bsts_percent_error = 100*(actual - bsts_point_est)/bsts_point_est
    )
  zrr_overall <<- xts::xts(interim[, -1], order.by = interim$date)
}

read_wdqs <- function() {
  interim <- read_dataset("wdqs/wdqs_aggregates_new.tsv", col_types = "Dclli") %>%
    # readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/wdqs/wdqs_aggregates_new.tsv", col_types = "Dclli") %>%
    dplyr::distinct(date, path, http_success, is_automata, .keep_all = TRUE) %>%
    dplyr::filter(http_success & !is_automata)
  # Homepage traffic:
  arima_forecast <- read_dataset("discovery-forecasts/wdqs_homepage_arima.tsv", col_types = "Dddddd")
  # arima_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/wdqs_homepage_arima.tsv", col_types = "Dddddd")
  names(arima_forecast) <- c("date", paste0("arima_", names(arima_forecast)[-1]))
  bsts_forecast <- read_dataset("discovery-forecasts/wdqs_homepage_bsts.tsv", col_types = "Dddddd")
  # bsts_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/wdqs_homepage_bsts.tsv", col_types = "Dddddd")
  names(bsts_forecast) <- c("date", paste0("bsts_", names(bsts_forecast)[-1]))
  wdqs_homepage <<- interim %>%
    dplyr::filter(path == "/") %>%
    dplyr::select(c(date, actual = events)) %>%
    dplyr::full_join(arima_forecast, by = "date") %>%
    dplyr::full_join(bsts_forecast, by = "date") %>%
    dplyr::mutate(
      arima_percent_error = 100*(actual - arima_point_est)/arima_point_est,
      bsts_percent_error = 100*(actual - bsts_point_est)/bsts_point_est
    ) %>%
    { xts::xts(.[, -1], order.by = .$date) }
  # SPARQL endpoint:
  arima_forecast <- read_dataset("discovery-forecasts/wdqs_sparql_arima.tsv", col_types = "Dddddd")
  # arima_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/wdqs_sparql_arima.tsv", col_types = "Dddddd")
  names(arima_forecast) <- c("date", paste0("arima_", names(arima_forecast)[-1]))
  bsts_forecast <- read_dataset("discovery-forecasts/wdqs_sparql_bsts.tsv", col_types = "Dddddd")
  # bsts_forecast <- readr::read_tsv("~/Documents/Projects/Discovery Dashboards/Forecasting/aggregate-datasets/discovery-forecasts/wdqs_sparql_bsts.tsv", col_types = "Dddddd")
  names(bsts_forecast) <- c("date", paste0("bsts_", names(bsts_forecast)[-1]))
  wdqs_sparql <<- interim %>%
    dplyr::filter(path == "/bigdata/namespace/wdq/sparql") %>%
    dplyr::select(c(date, actual = events)) %>%
    dplyr::full_join(arima_forecast, by = "date") %>%
    dplyr::full_join(bsts_forecast, by = "date") %>%
    dplyr::mutate(
      arima_percent_error = 100*(actual - arima_point_est)/arima_point_est,
      bsts_percent_error = 100*(actual - bsts_point_est)/bsts_point_est
    ) %>%
    { xts::xts(.[, -1], order.by = .$date) }
}

value_box_previous <- function(.data, .model = c("arima", "bsts"), .terms, .up_is_good = TRUE) {
  cols_to_keep <- c("actual", paste0(.model[1], c("_point_est", "_percent_error")))
  temp <- tail(.data, 2)[1, cols_to_keep]
  return({
    if (any(grepl("(rate|%|ctr)", .terms$units))) {
      valueBox(value = sprintf("%.2f%% %s %s than expected",
                               temp[[3]], ifelse(temp[[3]] > 0, .terms$up, .terms$down),
                               .terms$units),
               subtitle = paste("% error for", as.character(index(temp), "%A (%d %B %Y) |"), sprintf("%.1f%%", 100*temp[[1]]), "actual vs.", sprintf("%.1f%%", 100*temp[[2]]), "predicted by", toupper(.model[1])),
               color = polloi::cond_color(temp[[3]] > 0, ifelse(.up_is_good, "green", "red")))
    } else {
      valueBox(value = sprintf("%.2f%% %s %s than expected",
                               temp[[3]], ifelse(temp[[3]] > 0, .terms$up, .terms$down),
                               .terms$units),
               subtitle = paste("% error for", as.character(index(temp), "%A (%d %B %Y) |"), polloi::compress(temp[[1]]), "actual vs.", polloi::compress(temp[[2]]), "predicted by", toupper(.model[1])),
               color = polloi::cond_color(temp[[3]] > 0, ifelse(.up_is_good, "green", "red")))
    }
  })
}

value_box_prediction <- function(.data, .model = c("arima", "bsts"), .confidence = c("80", "95"), .terms) {
  cols_to_keep <- paste0(.model[1], c("_point_est", paste0(c("_lower_", "_upper_"), .confidence[1])))
  temp <- tail(.data, 1)[, cols_to_keep]
  return({
    if (any(grepl("(rate|%|ctr)", .terms$units))) {
      valueBox(value = sprintf("~%.2f%% (%.1f%%-%.1f%%)", 100*temp[[1]], 100*temp[[2]], 100*temp[[3]]),
               subtitle = paste0("Expected ", .terms$units, " and ", .confidence, "% Confidence Interval for ", as.character(index(temp), "%A (%d %B %Y)")),
               color = "black")
    } else {
      valueBox(value = sprintf("~%s (%s-%s)", polloi::compress(temp[[1]]), polloi::compress(temp[[2]]), polloi::compress(temp[[3]])),
               subtitle = paste0("Expected ", .terms$units, " and ", .confidence, "% Confidence Interval for ", as.character(index(temp), "%A (%d %B %Y)")),
               color = "black")
    }
  })
}

dygraph_predictions <- function(.data, .model, .confidence, .terms, .dygroup = NULL) {
  cols_to_keep <- "actual"
  if (.model == "both" || .model == "arima") {
    cols_to_keep <- c(cols_to_keep,  "arima_point_est", "arima_lower_80", "arima_upper_80")
  }
  if (.model == "both" || .model == "bsts") {
    cols_to_keep <- c(cols_to_keep,  "bsts_point_est", "bsts_lower_80", "bsts_upper_80")
  }
  if (.confidence == "95") {
    cols_to_keep <- sub("80", "95", cols_to_keep, fixed = TRUE)
  }
  if (any(grepl("(rate|%|ctr)", .terms$units))) {
    .data <- 100 * .data
  }
  dyOut <- dygraph(.data[, cols_to_keep],
                   ylab = .terms$units, group = .dygroup,
                   main = paste(.terms$title, "modeled with ARIMA & BSTS")) %>%
    dySeries("actual", label = "Actual", color = "black")
  if (.model == "both" || .model == "arima") {
    if (.confidence == "95") {
      dyOut <- dySeries(dyOut, c("arima_lower_95", "arima_point_est", "arima_upper_95"), label = "ARIMA",
                        color = RColorBrewer::brewer.pal(3, "Set1")[1])
    } else {
      dyOut <- dySeries(dyOut, c("arima_lower_80", "arima_point_est", "arima_upper_80"), label = "ARIMA",
                        color = RColorBrewer::brewer.pal(3, "Set1")[1])
    }
  }
  if (.model == "both" || .model == "bsts") {
    if (.confidence == "95") {
      dyOut <- dySeries(dyOut, c("bsts_lower_95", "bsts_point_est", "bsts_upper_95"), label = "BSTS",
                        color = RColorBrewer::brewer.pal(3, "Set1")[2])
    } else {
      dyOut <- dySeries(dyOut, c("bsts_lower_80", "bsts_point_est", "bsts_upper_80"), label = "BSTS",
                        color = RColorBrewer::brewer.pal(3, "Set1")[2])
    }
  }
  return({
    dyOut %>%
    dyOptions(labelsKMB = !any(grepl("(rate|%|ctr)", .terms$units))) %>%
    dyLegend(width = 400) %>%
    dyCSS(css = system.file("custom.css", package = "polloi"))
  })
}

dygraph_diagnostics <- function(.data, .model, .terms, .dygroup = NULL) {
  switch(.model,
         both = {
           cols_to_keep = c("arima_percent_error", "bsts_percent_error")
         },
         arima = {
           cols_to_keep = "arima_percent_error"
         },
         bsts = {
           cols_to_keep = "bsts_percent_error"
         })
  dyOut <- dygraph(.data[, cols_to_keep],
                   ylab = "% Error", group = .dygroup,
                   main = paste("Percent error between predicted and observed", .terms$title)) %>%
    dyLimit(limit = 0)
  if (.model == "both" || .model == "arima") {
    dyOut <- dySeries(dyOut, "arima_percent_error", label = "ARIMA's % Error",
                      color = RColorBrewer::brewer.pal(3, "Set1")[1])
  }
  if (.model == "both" || .model == "bsts") {
    dyOut <- dySeries(dyOut, "bsts_percent_error", label = "BSTS's % Error",
                      color = RColorBrewer::brewer.pal(3, "Set1")[2])
  }
  return({
    dyOut %>%
    dyAxis("y", valueRange = c(-1, 1) * max(abs(as.numeric(.data[, c("arima_percent_error", "bsts_percent_error")])), na.rm = TRUE)) %>%
    dyLegend(width = 400) %>%
    dyCSS(css = system.file("custom.css", package = "polloi"))
  })
}

