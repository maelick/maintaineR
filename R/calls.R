MissingCalls <- function(packages, exports, calls) {
  packages <- packages[, list(source, repository, ref, package=Package)]
  exported.calls <- merge(unique(calls[, list(package, name)]),
                          merge(exports, packages),
                          by.x=c("package", "name"),
                          by.y=c("package", "export"))
  missings <- merge(exported.calls[, .N, by=c("package", "name")],
                    packages[source == "cran", .N, by=c("package")],
                    by="package")
  missings <- missings[N.y > N.x, list(package, name)]
  missings <- merge(packages, missings, by="package", allow.cartesian=TRUE)
  missings <- merge(missings, cbind(exports, valid=TRUE),
                    by.x=c("source", "repository", "ref", "name"),
                    by.y=c("source", "repository", "ref", "export"), all.x=TRUE)
  missings[is.na(valid), list(source, repository, ref, package, name)]
}
