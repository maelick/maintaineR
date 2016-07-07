ClonesWith <- function(packages, cran) {
  hashes <- unique(Clones(packages, cran)$hash)
  clones <- setkey(setkey(copy(cran$clones), hash)[hashes],
                   package, version, hash)
  clones[-clones[list(packages[[1]]), which=TRUE]]
}

Clones <- function(packages, cran) {
  cran$clones[packages]
}

FirstClones <- function(packages, clones) {
  # returns clones with first occurence
  first <- setkey(merge(packages[, list(package, version, mtime)],
                        clones), hash)
  setnames(first, c("package", "version"), c("first.package", "first.version"))
  setkey(merge(clones, first[first[, .I[which.min(mtime)], by=hash]$V1,
                             list(first.package, first.version, hash)],
               by="hash"), package, version, hash)
}

PackageCloneGraph <- function(packages, clones, min.size=10, min.loc=3) {
  g <- graph.empty() + vertices(packages$package)
  clones <- FirstClones(packages, clones)
  edges <- clones[package != first.package & size >= min.size &
                  loc >= min.loc]
  g <- g + edges(t(edges[, list(package, first.package)]),
                 loc=edges$loc, size=edges$size, hash=edges$hash,
                 is.global=edges$is.global, name=edges$name)
  E(g)$num.clones <- 1
  g
}

SimplifyCloneGraph <- function(g) {
  simplify(g, edge.attr.comb=list(num.clones="sum", size="sum", loc="sum"))
}
