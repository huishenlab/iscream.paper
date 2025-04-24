#' Benchmark iscream::tabix against Rsamtools::scanTabix
#'
#' @param bedfile A bedfile to run tests on
#' @param regions A vector of regions to query from
#' @param min_iterations The min iterations for bench::mark to run
#' @param max_iterations The max iterations for bench::mark to run
#' @param raw Whether to return raw strings in a named list as Rsamtools::scanTabix does
#' @param n_regions A vector of region counts to benchmark
#' @param outfile Optional file to write the benchmark to
#'
#' @importFrom data.table setDT fwrite
#' @importFrom bench mark
#' @importFrom tidyr unnest
#' @importFrom GenomicRanges GRanges
#' @importFrom Rsamtools scanTabix
#' @importFrom iscream tabix
#' @export
benchmark_tabix <- function(
  bedfile,
  regions,
  min_iterations = 5,
  max_iterations = 10,
  raw = TRUE,
  n_regions = c(1, 100, 500, 1000, 5000, 10000, 30000),
  outfile = NULL
) {

  if (length(regions) < max(n_regions)) {
    stop("Too few regions provided - change the benchmarked `n_regions`")
  }

  region_map_benchmark <- bench::press(
    region_count = n_regions,
    {
      gr <- GRanges(regions[1:region_count])
      bench::mark(
        iscream = tabix(bedfile, regions[1:region_count], aligner = "biscuit", raw = raw),
        Rsamtools = scanTabix(bedfile, param = gr),
        min_iterations = min_iterations,
        max_iterations = max_iterations,
        check = raw
      )
    }
  )

  bm_unwrapped <- setDT(region_map_benchmark |> unnest(c(time, gc)))
  benchmark <- (
    bm_unwrapped[gc != "None"][, .(expression, region_count, time)]
  )
  colnames(benchmark)[1] <- "package"

  if (!is.null(outfile)) {
    fwrite(benchmark, outfile, quote = TRUE)
  }
  benchmark
}
