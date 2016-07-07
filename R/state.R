## Date <- function(packages, p=NULL, v=NULL, d=NULL) {
##   if (is.null(d)) {
##     if (!is.null(p)) {
##       packages <- packages[package == p]
##       if (!is.null(v)) packages <- packages[version == v]
##     }
##     as.Date(max(packages$mtime))
##   } else as.Date(d)
## }

## State <- function(packages, date=Sys.Date()) {
##   packages[packages[as.Date(mtime) <= date, .I[which.max(mtime)],
##                     by=package]$V1]
## }

State <- function(index, date=NULL) {
  if (!is.null(date)) {
    index <- index[as.Date(time) <= as.Date(date)]
  }
  index[index[, .I[which.max(as.POSIXct(time))],
              by=c("source", "repository")]$V1]
}

## ReadDataFile <- function(filename) {
##   if (file.exists(filename)) readRDS(filename)
## }
