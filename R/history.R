PackageHistory <- function(p, packages, index, src=NULL,
                           range=c(as.Date("0-1-1"), Sys.Date())) {
  res <- merge(packages[Package == p], index,
               by=c("source", "repository", "ref"))
  if (!is.null(src) && src %in% res$source) {
    res <- res[source == src]
  }
  res$time <- as.POSIXct(res$time)
  res <- setkey(res, time)
  if (nrow(res)) {
    res$time2 <- Sys.time()
    res$time2[-nrow(res)] <- res$time[2:nrow(res)]
  } else {
    res$time2 <- res$time
  }
  res <- res[as.Date(time2) > range[1] & as.Date(time) <= range[2], ]
  res[as.Date(time2) > range[2], time2 := as.POSIXct(range[2])]
  res[as.Date(time) < range[1], time := as.POSIXct(range[1])]
  res
}
