library(shiny)
library(shinydashboard)
library(dygraphs)
library(markdown)

#Header elements for the visualisation
header <- dashboardHeader(title = "Daily Forecasts", disable = FALSE)

#Sidebar elements for the search visualisations.
sidebar <- dashboardSidebar(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css"),
    tags$script(src = "custom.js")
  ),
  sidebarMenu(
    menuItem(text = "Summary", tabName = "summary", icon = icon("line-chart")),
    menuItem(text = "Search Metrics", icon = icon("search"),
             menuSubItem(text = "Overall ZRR", tabName = "zrr_overall")),
    menuItem(text = "WDQS Usage", icon = icon("barcode"),
             menuSubItem(text = "Homepage traffic", tabName = "wdqs_homepage"),
             menuSubItem(text = "SPARQL endpoint", tabName = "wdqs_sparql"))
  ),
  checkboxGroupInput("models", "Model to show", c("ARIMA" = "arima", "BSTS" = "bsts", "Prophet" = "prophet"), selected = c("bsts"), inline = FALSE),
  radioButtons("confidence", "Confidence", c("80%" = "80", "95%" = "95"), inline = FALSE)
)

#Body elements for the search visualisations.
body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "summary",
      h2("Overall zero search results rate"),
      conditionalPanel(
        "input.models.indexOf( 'arima' ) != -1",
        h3("ARIMA Forecast"),
        fluidRow(
          valueBoxOutput("zrr_overall_arima_previous", width = 7),
          valueBoxOutput("zrr_overall_arima_prediction", width = 5)
        )
      ),
      conditionalPanel(
        "input.models.indexOf( 'bsts' ) != -1",
        h3("BSTS Forecast"),
        fluidRow(
          valueBoxOutput("zrr_overall_bsts_previous", width = 7),
          valueBoxOutput("zrr_overall_bsts_prediction", width = 5)
        )
      ),
      conditionalPanel(
        "input.models.indexOf( 'prophet' ) != -1",
        h3("Prophet Forecast"),
        fluidRow(
          valueBoxOutput("zrr_overall_prophet_previous", width = 7),
          valueBoxOutput("zrr_overall_prophet_prediction", width = 5)
        )
      ),
      h2("Wikidata Query Service SPARQL endpoint usage"),
      conditionalPanel(
        "input.models.indexOf( 'arima' ) != -1",
        h3("ARIMA Forecast"),
        fluidRow(
          valueBoxOutput("wdqs_sparql_arima_previous", width = 7),
          valueBoxOutput("wdqs_sparql_arima_prediction", width = 5)
        )
      ),
      conditionalPanel(
        "input.models.indexOf( 'bsts' ) != -1",
        h3("BSTS Forecast"),
        fluidRow(
          valueBoxOutput("wdqs_sparql_bsts_previous", width = 7),
          valueBoxOutput("wdqs_sparql_bsts_prediction", width = 5)
        )
      ),
      conditionalPanel(
        "input.models.indexOf( 'prophet' ) != -1",
        h3("Prophet Forecast"),
        fluidRow(
          valueBoxOutput("wdqs_sparql_prophet_previous", width = 7),
          valueBoxOutput("wdqs_sparql_prophet_prediction", width = 5)
        )
      ),
      HTML('<hr style="border-color: gray;">
<p style="font-size: small;">
  <strong>Link to this dashboard:</strong> <a href="https://discovery.wmflabs.org/forecasts/">https://discovery.wmflabs.org/forecasts/</a>
  | Page is available under <a href="https://creativecommons.org/licenses/by-sa/3.0/" title="Creative Commons Attribution-ShareAlike License">CC-BY-SA 3.0</a>
  | <a href="https://github.com/bearloga/wmf-delphi" title="Usage Forecasts Dashboard source code repository">Code</a> is licensed under <a href="https://github.com/bearloga/wmf-delphi/blob/master/LICENSE.md" title="MIT License">MIT</a>
  | Part of <a href="https://discovery.wmflabs.org/">Discovery Dashboards</a>
  | Forecasting Code available as part of <a href="https://github.com/wikimedia/wikimedia-discovery-golden" title="GitHub mirror of wikimedia/discovery/golden">this repository</a>
</p>')
    ),
    tabItem(
      tabName = "zrr_overall",
      dygraphOutput("zrr_overall_predictions", height = "300px"),
      dygraphOutput("zrr_overall_diagnostics", height = "250px"),
      includeMarkdown("tab_documentation/zrr_overall.md")
    ),
    tabItem(
      tabName = "wdqs_homepage",
      dygraphOutput("wdqs_homepage_predictions", height = "300px"),
      dygraphOutput("wdqs_homepage_diagnostics", height = "250px"),
      includeMarkdown("tab_documentation/wdqs_homepage.md")
    ),
    tabItem(
      tabName = "wdqs_sparql",
      dygraphOutput("wdqs_sparql_predictions", height = "300px"),
      dygraphOutput("wdqs_sparql_diagnostics", height = "250px"),
      includeMarkdown("tab_documentation/wdqs_sparql.md")
    )
  )
)

dashboardPage(
  header, sidebar, body, skin = "black",
  title = "Search Platforms's Predictive Analytics Dashboard | Wikimedia Foundation"
)
