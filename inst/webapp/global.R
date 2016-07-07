library(data.table)
library(igraph)
library(timeline)
library(maintaineR)
library(ggplot2)

if (!exists("datadir")) {
  datadir <- "/data/rdata"
}

if (!file.exists(datadir)) {
  dir.create(datadir)
  message(sprintf("Directory %s not found. Created in %s", datadir, getwd()))
}

config <- file.path(datadir, "maintaineR.conf")

if (!file.exists(config)) {
  stop(sprintf("Please create file %s", config))
}

config <- as.list(read.dcf(config)[1, ])
config$Update <- as.logical(config$Update)
config$AllowDownload <- as.logical(config$AllowDownload)

core.packages <- c("R", "base", "compiler", "datasets", "graphics",
                   "grDevices", "grid", "methods", "parallel", "profile",
                   "splines", "stats", "stats4", "tcltk", "tools",
                   "translations", "utils")

index <- readRDS(file.path(datadir, "rds/index.rds"))
packages <- readRDS(file.path(datadir, "rds/packages.rds"))
descfiles <- readRDS(file.path(datadir, "rds/descfiles.rds"))
dependencies <- readRDS(file.path(datadir, "rds/deps.rds"))
dependencies <- dependencies[type.name %in% c("depends", "imports", "linkingto")]
namespaces <- readRDS(file.path(datadir, "rds/namespaces.rds"))
clones <- merge(readRDS(file.path(datadir, "rds/clones.rds")), packages,
                by=c("source", "repository", "ref"))
clones <- clones[, if (length(unique(Package)) > 1) .SD, by="body.hash"]
