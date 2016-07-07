core.packages <- c("R", "base", "compiler", "datasets", "graphics",
                   "grDevices", "grid", "methods", "parallel", "profile",
                   "splines", "stats", "stats4", "tcltk", "tools",
                   "translations", "utils")

DependencyGraph <- function(deps, state,
                            types=c("depends", "imports", "linkingto")) {
  deps <- merge(setkey(copy(deps), dependency)[!core.packages], state,
                by=c("source", "repository", "ref"))
  deps <- deps[, list(Package, dependency)]
  packages <- unique(union(state$Package, deps$dependency))
  g <- graph.empty(directed=TRUE) +
    vertices(packages, missing=!packages %in% state$Package)
  g + edges(t(as.matrix(deps)))
}

Dependencies <- function(graph, nodes, type="out", min.dist=1, max.dist=Inf) {
  if (length(nodes)) {
    paths <- apply(shortest.paths(graph, nodes, mode=type), 2, min)
    paths <- paths[min.dist <= paths & paths < max.dist]
    data.table(package=names(paths), order=paths)
  } else NULL
}
