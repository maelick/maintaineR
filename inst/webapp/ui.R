library(shiny)
library(shinydashboard)

shinyUI(tagList(
  tags$head(
    tags$link(rel="stylesheet", href="lib/d3sankey/css/sankey.css"),
    tags$script(src="lib/d3sankey/js/d3.v3.js"),
    tags$script(src="lib/d3sankey/js/sankey.js"),
    tags$style("
      .rChart {
        display: block;
        margin-left: auto;
        margin-right: auto;
        width: 960px;
        height: 700px;
      }")),
  dashboardPage(dashboardHeader(title="maintaineR"),
                dashboardSidebar(sidebarMenu(id="menu", sidebarMenuOutput("sidebar"))),
                dashboardBody(uiOutput("body")))
))
