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
    menuItem(text = "Search Metrics (ARIMA)",
             menuSubItem(text = "Cirrus API", tabName = "arima_search_api_cirrus"))
  )
)

#Body elements for the search visualisations.
body <- dashboardBody(
  tabItems(
    tabItem(tabName = "arima_search_api_cirrus",
            fluidRow(valueBoxOutput("arima_search_api_cirrus_previous", width = 7),
                     valueBoxOutput("arima_search_api_cirrus_prediction", width = 5)
            ),
            dygraphOutput("arima_search_api_cirrus_predictions", height = "300px"),
            dygraphOutput("arima_search_api_cirrus_diagnostics", height = "250px"),
            includeMarkdown("docs/arima_search_api_cirrus.md"))
  )
)


dashboardPage(header, sidebar, body, skin = "black",
              title = "Forecasting Dashboard | Discovery | Engineering | Wikimedia Foundation")
