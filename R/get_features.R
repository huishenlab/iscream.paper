#' Get a feature from a regulatory gtf
#'
#' @param feature The regulatory feature to extract ("promoter" or "enhancer")
#'
#' @importFrom data.table fread
#' @export
get_feature <- function(feature) {
  reg_features <- run_conf$datasets$reference$reg_features
  reg_features.file <- reg_features$file
  reg_features.url <- reg_features$url

  colnames <- c("chr", "description", "start", "end", "annot")
  if (!file.exists(reg_features.file))
    download.file(reg_features.url, reg_features.file)

  reg_features.dt <- fread(reg_features.file, drop = c(2, 6, 7, 8), col.names = colnames)
  reg_features.dt[description == feature][, .(chr, start, end)]
}

#' Get CpG islands from a CpG island bed
#'
#' @importFrom data.table fread
#' @export
get_cpg_islands <- function() {
  colnames = c("chr", "start", "end")
  if (!file.exists(cpg_islands.file)) download.file(cpg_islands.url, cpg_islands.file)
  fread(cpg_islands.file, drop = c(1, 5:11), col.names = colnames)
}

#' Read a generic BED file
#'
#' @param bed_path The path to the BED file
#'
#' @importFrom data.table fread
#' @export
read_bed <- function(bed_path) {
  colnames = c("chr", "start", "end")
  fread(bed_path, col.names = colnames)
}

#' Get bed data frame as vector of region strings
#'
#' @import data.table
#' @export
create_regions <- function(bed_dt) {
  bed_dt[, paste0(chr, ':', start, '-', end)]
}
