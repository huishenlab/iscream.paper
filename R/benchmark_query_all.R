#' Benchmark iscream::query_all on varying region, thread and file counts
#'
#' @param bedfiles A vector of bedfiles to run tests on
#' @param regions A vector of regions to query from
#' @param threads The number of threads to run on
#' @param min_iterations The min iterations for bench::mark to run
#' @param max_iterations The max iterations for bench::mark to run
#' @param sparse Whether to use sparse matrices for single-cell data
#' @param n_regions A vector of region counts to benchmark
#' @param n_files A vector of file counts to benchmark
#' @param n_threads A vector of thread counts to benchmark
#' @param outfile Optional file to write the benchmark to
#'
#' @importFrom data.table setDT fwrite
#' @importFrom BiocGenerics sort
#' @importFrom bsseq BSseq
#' @importFrom bench mark
#' @importFrom tidyr unnest
#' @import iscream
#' @export
benchmark_query_all <- function(
  bedfiles,
  regions,
  min_iterations = 3,
  max_iterations = 10,
  sparse = FALSE,
  n_regions = 10000,
  n_files = c(1, 10, 50, 100),
  n_threads = c(1, 16),
  outfile = NULL
) {

  if (length(regions) < max(n_regions)) {
    stop("Too few regions provided - change the benchmarked `n_regions`")
  }
  if (length(bedfiles) < max(n_files)) {
    stop("Too few bedfiles provided - change the benchmarked `n_files`")
  }

  query_all_benchmark <- bench::press(
    region_count = n_regions,
    file_count = n_files,
    thread_count = n_threads,
    {
      bench::mark(
        sort(do.call(BSseq, query_all(bedfiles[1:file_count], regions[1:region_count], nthreads = thread_count, sparse = sparse))),
        min_iterations = min_iterations,
        check = F
      )
    }
  )

  bm_unwrapped <- setDT(query_all_benchmark |> unnest(c(time, gc)))
  benchmark <- (
    bm_unwrapped[gc != "None"][, .(expression, thread_count, file_count, time, region_count)]
    [, thread_count := as.factor(thread_count)]
    [, expression := "iscream"]
  )
  colnames(benchmark)[1] <- "package"

  if (!is.null(outfile)) {
    fwrite(benchmark, outfile, quote = TRUE)
  }
  benchmark
}
