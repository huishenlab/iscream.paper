#' Get relative runtime differences
#'
#' @param packages The set of packages to read. Either `c("tabix")` or `c("BSseq", "biscuiteer", "query_all")`
#' @param outfile Where to write the plot to file
#'
#' @importFrom data.table fread :=
#' @export
get_timediff <- function(packages) {

  benchmark <- lapply(packages, function(package) {
    rbind(
      fread(paste0("data/results/benchmarks/", tolower(package), "_sc.csv"))[, exp_type := "sc"],
      fread(paste0("data/results/benchmarks/", tolower(package), "_bulk.csv"))[, exp_type := "bulk"]
    )
  }) |> rbindlist()

  filtered <- benchmark[region_count == max(region_count)]
  if ("file_count" %in% colnames(filtered)) {
    filtered <- filtered[file_count == max(file_count)]
  }
  if ("thread_count" %in% colnames(filtered)) {
    filtered <- filtered[thread_count == max(thread_count)]
  }
  filtered[, .(time.mean = mean(time)), by = .(exp_type, package)][, .(package, time.mean/min(time.mean)), by = .(exp_type)]
}
