output$repos.table <- renderDataTable({
  src <- mode()$src
  date <- if (is.null(mode()$date)) Sys.Date() else mode()$date
  index <- index[as.Date(time) <= as.Date(date)][order(source, repository, time)]
  if (!is.null(src)) index <- index[source == src]
  index <- index[source %in% setdiff(input$repos.filters, "last")]
  if ("last" %in% input$repos.filters) {
    index <- State(index)
  }
  index <- merge(index, packages, by=c("source", "repository", "ref"))
  index$repository <- RepositoryLinks(index, date)
  index
}, escape=FALSE)

isolate({updateTabItems(session, "menu", "repository-list")})
