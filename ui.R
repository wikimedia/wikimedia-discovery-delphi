library(shiny)
library(shinydashboard)
library(dygraphs)

#Header elements for the visualisation
header <- dashboardHeader(title = "Forecasts", disable = FALSE)

#Sidebar elements for the search visualisations.
sidebar <- dashboardSidebar(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css"),
    tags$script(src = "custom.js")
  ),
  sidebarMenu(
    menuItem(text = "Search Metrics",
             menuSubItem(text = "Summary", tabName = "search_summary"),
             menuSubItem(text = "Cirrus API", tabName = "cirrus_api"))
  ),
  radioButtons("confidence", "Confidence", c("80%" = "80", "95%" = "95"), inline = FALSE)
)

#Body elements for the search visualisations.
body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "search_summary",
      h2("Cirrus API Usage"),
      h3("ARIMA Forecast"),
      fluidRow(
        valueBoxOutput("cirrus_api_arima_previous", width = 7),
        valueBoxOutput("cirrus_api_arima_prediction", width = 5)
      ),
      h3("BSTS Forecast"),
      fluidRow(
        valueBoxOutput("cirrus_api_bsts_previous", width = 7),
        valueBoxOutput("cirrus_api_bsts_prediction", width = 5)
      )
    ),
    tabItem(
      tabName = "cirrus_api",
      radioButtons("models", "Model to show", list("Both" = "both", "ARIMA only" = "arima", "BSTS only" = "bsts"), inline = TRUE),
      dygraphOutput("cirrus_api_predictions", height = "300px"),
      dygraphOutput("cirrus_api_diagnostics", height = "250px"),
      includeMarkdown("docs/cirrus_api.md")
    )
  )
)


dashboardPage(header, sidebar, body, skin = "black",
              title = "Forecast Dashboard | Discovery | Engineering | Wikimedia Foundation")
