PrintMode <- function(mode) {
  if (mode$mode == "single") {
    with(mode$repository, {
      source <- switch(source, cran="CRAN", github="Github")
      mode.date <- if(is.null(mode$date)) time else mode$date
      sprintf("%s %s %s (%s, snapshot %s)",
              source, repository, ref, time, mode.date)
    })
  }
}

output$summary.title <- renderText(PrintMode(mode()))
output$history.title <- renderText(PrintMode(mode()))
output$dependencies.title <- renderText(PrintMode(mode()))
output$namespace.title <- renderText(PrintMode(mode()))
output$clones.title <- renderText(PrintMode(mode()))

package <- reactive({
  merge(mode()$repository, packages, by=c("source", "repository", "ref"))
})

descfile <- reactive({
  merge(mode()$repository, descfiles, by=c("source", "repository", "ref"))
})

state <- reactive({
  priority <- input$deps.priority
  if (priority == "same") priority <- package()$source
  res <- merge(State(index, mode()$date), packages,
               by=c("source", "repository", "ref"))
  res <- res[, {
    if (length(unique(source)) > 1) {
      .SD[(Package == package()$Package & source == package()$source) |
          (Package != package()$Package & source == priority)]
    } else .SD
  }, by="Package"]
  setkey(res, Package)
  res
})

deps.graph <- reactive(DependencyGraph(dependencies, state()))

deps <- reactive({
  direct <- if (input$dependencies.show %in% c("deps", "both")) {
    Dependencies(deps.graph(), package()$Package, "out",
                 1, input$dependencies.order + 1)
  }
  reverse <- if (input$dependencies.show %in% c("revdeps", "both")) {
    Dependencies(deps.graph(), package()$Package, "in",
                 1, input$dependencies.order + 1)
  }
  if (!is.null(direct) && nrow(direct)) {
    direct <- cbind(direct, type="Dependency")
    if (!is.null(reverse) && nrow(reverse)) {
      rbind(direct, cbind(reverse, type="Reverse dependency"))
     } else direct
  } else if (!is.null(reverse) && nrow(reverse)) {
    cbind(reverse, type="Reverse dependency")
  }
})

namespace <- reactive({
  res <- namespaces[[package()[, paste(source, repository, ref, sep=":")]]]
  res[sapply(res, length) > 0]
})

## clones <- reactive({
##   merge(clones, package())
## })

output$summary <- renderDataTable({
  if (nrow(package())) descfile()[, list(key, value)]
})

output$history <- renderPlot({
  pkgs <- package()$Package
  dependencies <- dependencies[!dependency %in% core.packages]
  if ("deps" %in% input$history.show) {
    deps <- merge(dependencies, package(), by=c("source", "repository", "ref"))
    pkgs <- c(pkgs, unique(deps$dependency))
  }
  if ("revdeps" %in% input$history.show) {
    deps <- merge(packages, dependencies, by=c("source", "repository", "ref"))
    deps <- deps[dependency == package()$Package, unique(Package)]
    if (length(deps) < 20) pkgs <- c(pkgs, deps)
  }
  src <- if (!"allsources" %in% input$history.show) mode()$repository$source
  history <- lapply(pkgs, PackageHistory, packages, index, src, input$history.range)
  history <- rbindlist(history[sapply(history, nrow) > 0])
  history <- history[, list(ref=mapply(function(src, r) {
    if (src == "cran") r else substr(r, 1, 8)
  }, source, ref), package=paste(source, repository), time, time2)]
  timeline(history)
})

output$history.versions <- renderDataTable({
  res <- merge(index, packages, by=c("source", "repository", "ref"))
  res <- res[(source == package()$source & repository == package()$repository &
              ref == package()$ref) | Package == package()$Package]
  res$repository <- RepositoryLinks(res)
  res
}, escape=FALSE)

output$dependencies.list <- renderDataTable({
  if (nrow(package())) {
    deps <- setkey(copy(deps()), type, order)
    deps[package %in% state()$Package,
         package := RepositoryLinks(state()[package], package()$time)]
  }
}, escape=FALSE)

output$dependencies.graph <- renderPrint({
  g <- induced.subgraph(deps.graph(), c(package()$Package, deps()$package))
  V(g)$name <- state()[V(g)$name, repository]
  V(g)$group <- 1
  V(g)[package()$Package]$group <- 2
  if (length(E(g))) {
    RenderSankey(g)
  }
})

output$namespace.content <- renderUI({
  lapply(names(namespace()), function(name) {
    box(title=name, dataTableOutput(sprintf("namespace.%s", name)))
  })
})

output$namespace.imports <- renderDataTable({
  rbindlist(lapply(namespace()$imports, function(import) {
    if (is.list(import)) {
      data.table(Package=import[[1]], Object=import[[1]])
    } else data.table(Package=import, Object="")
  }))
})

output$namespace.exports <- renderDataTable({
  data.table(Objects=namespace()$exports)
})

output$namespace.exportPatterns <- renderDataTable({
  data.table(Pattern=namespace()$exportPatterns)
})

output$namespace.S3methods <- renderDataTable({
  res <- as.data.table(namespace()$S3methods)
  setnames(res, c("Method", "Type", "Function"))
  res[is.na(Function), Function := paste(Method, Type, sep=".")]
  res
})

this.clones <- reactive({
  res <-
    if ("last" %in% input$clones.filters) {
      # FIXME: does not work if current version is not in snapshot
      clones <- merge(clones, state()[, list(source, repository, ref)],
                      by=c("source", "repository", "ref"))
      } else clones
})

code <- reactive({
  readRDS(sprintf("%s.rds", file.path(datadir, "functions", package()$source,
                                      package()$repository, package()$ref)))
})

output$clones.table <- renderDataTable({
  hashes <- merge(this.clones(), package(),
                  by=c("source", "repository", "ref"))$body.hash
  if (length(hashes)) {
    res <- this.clones()[body.hash %in% hashes,
                         if (length(unique(Package)) > 1) {
                           list(Repositories=do.call(paste, c(as.list({
                             RepositoryLinks(.SD[Package != package()$Package],
                                             include.ref=TRUE)
                         }), list(sep="<br>"))),
                                Name=name[repository == package()$repository][1],
                                Global=global[repository == package()$repository][1],
                                LOC=body.loc[repository == package()$repository][1])
                         },
                         by="body.hash"]
    res <- res[, list(Name, Global, LOC, Repositories,
                      Code=sapply(body.hash, function(h) code()$functions[body.hash == h][1, code]))]
    res[, LOC := sapply(strsplit(Code, "\n"), length)]
    res <- res[LOC >= input$clones.minloc]
    res[, Code := sprintf("<pre>%s</pre>", gsub("\n", "<br>", Code))]
    res
  }
}, escape=FALSE)

isolate({updateTabItems(session, "menu", "summary")})
