read_methrix <- function(bedfiles, cpgs, threads) {
  meth <- methrix::read_bedgraphs(
    files = bedfiles,
    ref_cpgs = cpgs,
    chr_idx = 1,
    start_idx = 2,
    beta_idx = 4,
    cov_idx = 5,
    stranded = FALSE,
    zero_based = TRUE,
    vect = TRUE,
    n_threads = threads
  ) |> remove_uncovered() |> methrix2bsseq()
}

#' Benchmark methrix on varying thread and file counts
#'
#' @param bedfiles A vector of bedfiles to run tests on
#' @param regions A vector of regions to query from
#' @param merged Whether the files are CG merged
#' @param threads The number of threads to run on
#' @param min_iterations The min iterations for bench::mark to run
#' @param max_iterations The max iterations for bench::mark to run
#' @param n_regions A vector of region counts to benchmark
#' @param n_files A vector of file counts to benchmark
#' @param n_threads A vector of thread counts to benchmark
#' @param outfile Optional file to write the benchmark to
#'
#' @importFrom data.table setDT fwrite
#' @importFrom methrix extract_CPGs read_bedgraphs remove_uncovered methrix2bsseq
#' @importFrom bench mark
#' @importFrom tidyr unnest
#' @import iscream
#' @export
benchmark_methrix <- function(
  bedfiles,
  exp_type,
  min_iterations = 3,
  max_iterations = 10,
  n_regions = c(1, 100, 500, 1000, 5000, 10000),
  n_files = round(10^c(0, 1, 1.4, 1.7, 1.875, 2)),
  n_threads = 2^c(0, 1, 2, 3, 4),
  outfile = NULL
) {

  setDTthreads(4L)

  if (length(bedfiles) < max(n_files)) {
    stop("Too few bedfiles provided - change the benchmarked `n_files`")
  }

  cpgs <- methrix::extract_CPGs(ref_genome = "BSgenome.Hsapiens.UCSC.hg38")

  if (is.null(n_regions)) {
    methrix_benchmark <- bench::press(
      file_count = n_files,
      thread_count = n_threads,
      {
        bench::mark(
          read_methrix(bedfiles[1:file_count], cpgs, thread_count),
          min_iterations = min_iterations,
          max_iterations = min_iterations,
          check = F
        )
      }
    )
  } else {
    methrix_benchmark <- bench::press(
      file_count = n_files,
      region_count = n_regions,
      thread_count = n_threads,
      {
        regs <- regions
        regs$cpgs <- regs$cpgs[1:n_regions]
        bench::mark(
          read_methrix(bedfiles[1:file_count], regs, thread_count),
          min_iterations = min_iterations,
          max_iterations = min_iterations,
          check = F
        )
      }
    )
  }


  bm_unwrapped <- setDT(methrix_benchmark |> unnest(c(time, gc)))
  benchmark <- bm_unwrapped[gc != "None"][, .(expression, thread_count, file_count, time)]
  # if (!is.null(regions)) {
  #   benchmark[, region_count := bm_unwrapped$region_count]
  # }

  benchmark <- benchmark[, thread_count := as.factor(thread_count)][, expression := "methrix"]
  colnames(benchmark)[1] <- "package"

  if (!is.null(outfile)) {
    fwrite(benchmark, outfile, quote = TRUE)
  }
  benchmark
}
