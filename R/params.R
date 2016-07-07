GetMode <- function(params) {
  if ("p" %in% names(params)) {
    packages <- merge(packages, index, by=c("source", "repository", "ref"))
    packages <- packages[Package == params$p]
    if ("v" %in% names(params)) {
      packages <- packages[Version == params$v]
    }
    if ("d" %in% names(params)) {
      packages <- packages[time <= params$d]
    }
    if (nrow(packages)) {
      repository <- packages[which.max(as.POSIXct(time))][1]
      list(mode="single", type="package", date=params$d,
           repository=repository[, list(source, repository, ref, time)])
    } else NULL
  } else if ("src" %in% names(params) && "repo" %in% names(params)) {
    index <- index[source == params$src & repository == params$repo]
    if ("ref" %in% names(params)) {
      index <- index[ref == params$ref]
    }
    if ("d" %in% names(params)) {
      index <- index[time <= params$d]
    }
    if (nrow(index)) {
      list(mode="single", type="repository", date=params$d,
           repository=index[which.max(as.POSIXct(time))][1])
    } else NULL
  } else {
    list(mode="overview", date=params$d, src=params$src)
  }
}

ParseParams <- function(session) {
  params <- parseQueryString(session$clientData$url_search)
  if ("d" %in% names(params)) {
    params$d <- if (grepl("\\d+-\\d+", params$d)) {
      as.POSIXct(strptime(params$d, tz="Z", format="%Y%m%d-%H%M%S"))
    } else {
      as.Date(strptime(params$d, tz="Z", format="%Y%m%d"))
    }
  }
  params
}
