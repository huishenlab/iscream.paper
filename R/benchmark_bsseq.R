#' Benchmark iscream::query_all on varying region, thread and file counts
#'
#' @param bedfiles A vector of bedfiles to run tests on
#' @param regions An Rds file containing the cpg loci for benchmarking across regions
#' @param threads The number of threads to run on
#' @param min_iterations The min iterations for bench::mark to run
#' @param max_iterations The max iterations for bench::mark to run
#' @param n_regions A vector of region counts to benchmark
#' @param n_files A vector of file counts to benchmark
#' @param n_threads A vector of thread counts to benchmark
#' @param outfile Optional file to write the benchmark to
#'
#' @importFrom data.table setDT fwrite
#' @importFrom bench mark
#' @importFrom bsseq read.bismark
#' @importFrom tidyr unnest
#' @importFrom BiocParallel MulticoreParam
#' @importFrom GenomicRanges GRanges seqnames
#' @importFrom IRanges IRanges start
#' @export
benchmark_bsseq <- function(
  bedfiles,
  regions,
  min_iterations = 3,
  max_iterations = 5,
  n_regions = 10000,
  n_files = c(1, 10, 50, 100),
  n_threads = c(1, 16),
  outfile = NULL
) {

  if (length(bedfiles) < max(n_files)) {
    stop("Too few bedfiles provided - change the benchmarked `n_files`")
  }

  if (is.null(regions)) {
    query_all_benchmark <- bench::press(
      file_count = n_files,
      thread_count = n_threads,
      {
        bench::mark(
          read.bismark(bedfiles[1:file_count], BPPARAM = MulticoreParam(workers = thread_count)),
          min_iterations = min_iterations,
          max_iterations = min_iterations,
          check = F
        )
      }
    )
  } else {
    cpg_loci <- readRDS(regions)
    max_loci <- lapply(cpg_loci, length) |> unlist() |> max()
    if (max_loci < max(n_regions)) {
      stop("Too few regions provided - change the benchmarked `n_regions`")
    }

    query_all_benchmark <- bench::press(
      region_count = n_regions,
      file_count = n_files,
      thread_count = n_threads,
      {
        bench::mark(
          read.bismark(
            bedfiles[1:file_count],
            cpg_loci[[paste0("r_", file_count)]],
            BPPARAM = MulticoreParam(workers = thread_count)
          ),
          min_iterations = min_iterations,
          max_iterations = max_iterations,
          check = F
        )
      }
    )
  }

  bm_unwrapped <- setDT(query_all_benchmark |> unnest(c(time, gc)))
  benchmark <- bm_unwrapped[gc != "None"][, .(expression, thread_count, file_count, time)]
  if (!is.null(regions)) {
    benchmark[, region_count := bm_unwrapped$region_count]
  }

  benchmark <- benchmark[, thread_count := as.factor(thread_count)][, expression := "BSseq"]
  colnames(benchmark)[1] <- "package"

  if (!is.null(outfile)) {
    fwrite(benchmark, outfile, quote = TRUE)
  }
  benchmark
}
