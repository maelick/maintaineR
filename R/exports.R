ReadExports <- function(datadir, index) {
  exports <- index[, file.path(datadir, "exports-expanded",
                               source, repository, sprintf("%s.rds", ref))]
  exports <- rbindlist(lapply(exports[file.exists(exports)], readRDS))
  setkey(exports, source, repository, ref)
}
