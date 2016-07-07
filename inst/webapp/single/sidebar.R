sidebarMenu(
  menuItem("Summary", tabName="summary", icon=icon("list")),
  menuItem("History", tabName="history", icon=icon("calendar")),
  menuItem("Dependencies", tabName="dependencies", icon=icon("code-fork")),
  menuItem("Namespace", tabName="namespace", icon=icon("tags")),
  menuItem("Clones", tabName="clones", icon=icon("copy")),
  radioButtons("deps.priority", "Dependency source priority",
               c(Same="same", CRAN="cran", Github="github"), selected="same")
)
