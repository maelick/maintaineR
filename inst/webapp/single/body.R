summary <- tabItem(
  tabName="summary",
  fluidRow(
    box(
      title=textOutput("summary.title"),
      box(
        title="DESCRIPTION file",
        dataTableOutput("summary"),
        width=12
      ),
      width=12
    )
  )
)

history <- tabItem(
  tabName="history",
  fluidRow(
    box(
      title=textOutput("history.title"),
      box(
        title="Controls",
        width=3,
        dateRangeInput("history.range", "History range",
                       start="1997-01-01", end=mode()$date),
        checkboxGroupInput("history.show", "Show",
                           c("Dependencies"="deps",
                             "Reverse dependencies"="revdeps",
                             "All sources"="allsources"))
      ),
      box(
        title="History",
        plotOutput("history"),
        width=9
      ),
      box(
        title="Versions",
        dataTableOutput("history.versions"),
        width=12
      ),
      width=12
    )
  )
)

dependencies <- tabItem(
  tabName="dependencies",
  fluidRow(
    box(
      title=textOutput("dependencies.title"),
      box(
        title="Controls",
        numericInput("dependencies.order", label="Maximum order",
                     100, min=0, step=1),
        radioButtons("dependencies.show", "Show",
                     c("Dependencies"="deps",
                       "Reverse dependencies"="revdeps",
                       "Both"="both"), "deps"),
        width=2
      ),
      box(
        title="Dependencies",
        tabsetPanel(tabPanel("List", dataTableOutput("dependencies.list")),
                    tabPanel("Graph", uiOutput("dependencies.graph"))),
        width=10
      ),
      width=12
    )
  )
)

namespace <- tabItem(
  tabName="namespace",
  fluidRow(
    box(
      title=textOutput("namespace.title"),
      box(
        title="Controls",
        width=2
      ),
      box(
        title="Namespace",
        uiOutput("namespace.content"),
        width=10
      ),
      width=12
    )
  )
)

clones <- tabItem(
  tabName="clones",
  fluidRow(
    box(
      title=textOutput("clones.title"),
      box(
        title="Controls",
        width=2,
        numericInput("clones.minloc", "Minimum LOC", 6, 1),
        radioButtons("clones.sort", "Sort packages by",
                     c("Oldest first"="old",
                       "Alphabetical"="alpha")),
        checkboxGroupInput(
          "clones.filters", "Show only",
          c("Last package version"="last")
        )
      ),
      box(
        title="Clones",
        dataTableOutput("clones.table"),
        width=10
      ),
      width=12
    )
  )
)

tabItems(summary, history, dependencies, namespace, clones)
