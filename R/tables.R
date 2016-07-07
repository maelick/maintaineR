RepositoryLink <- function(source, repository, ref=NULL, date=NULL,
                           include.ref=FALSE) {
  opt <- if (!is.null(ref)) sprintf("&ref=%s", ref) else ""
  opt <- if (!is.null(date)) {
    sprintf("%s&d=%s", opt,
            if (class(date) == "Date") {
              strftime(date, "%Y%m%d")
            } else {
              strftime(date, "%Y%m%d-%H%M%S")
            })
  } else opt
  name <- if (include.ref) paste(repository, ref) else repository
  sprintf('<a href="?src=%s&repo=%s%s">%s</a>',
          source, repository, opt, name)
}

RepositoryLinks <- function(index, date=NULL, include.ref=FALSE) {
  mapply(RepositoryLink, index$source, index$repository, index$ref,
         MoreArgs=list(date=date, include.ref=include.ref))
}
