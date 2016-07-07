tabItems(
  tabItem(
    tabName="repository-list",
    fluidRow(
      box(
        title="Repositories",
        dataTableOutput("repos.table"),
        width=10
      ),
      box(
        title="Controls",
        width=2,
        checkboxGroupInput(
          "repos.filters", "Show",
          c("Only last version"="last",
            "CRAN"="cran",
            "Github"="github"),
          selected=c("cran", "github")
        )
      )
    )
  ),
  tabItem(
    tabName="package-list",
    h2("Widgets tab content")
  )
)
