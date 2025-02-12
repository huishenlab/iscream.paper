#' Benchmark iscream::query_all on varying region, thread and file counts
#'
#' @param bedfiles A vector of bedfiles to run tests on
#' @param gr A GRanges of the regions
#' @param merged Whether the files are CG merged
#' @param threads The number of threads to run mclapply with
readbis <- function(bedfiles, gr, threads, merged) {
  bsseqs <- mclapply(bedfiles, function(file) {
    readBiscuit(
      file,
      VCFfile = gsub("(_mergecg)?.bed.gz", ".vcf.gz", file),
      merged = merged,
      which = gr
    )
  }, mc.cores = threads)
  if (length(bedfiles) == 1) return(bsseqs)
  do.call(BiocGenerics::combine, bsseqs)
}

readbis_sc <- function(files, threads, merged) {
  bsseqs <- mclapply(files, function(file) {
    readBiscuit(
      file,
      VCFfile = gsub("(_mergecg)?.bed.gz", ".vcf.gz", file),
      merged = merged
    )
  }, mc.cores = threads)
  if (length(files) == 1) return(bsseqs)
  do.call(BiocGenerics::combine, bsseqs)
}

#' Benchmark iscream::query_all on varying region, thread and file counts
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
#' @importFrom parallel mclapply
#' @importFrom GenomicRanges GRanges seqnames
#' @importFrom IRanges IRanges start
#' @importFrom bench mark
#' @importFrom biscuiteer readBiscuit unionize
#' @importFrom tidyr unnest
#' @import iscream
#' @export
benchmark_biscuiteer <- function(
  bedfiles,
  regions,
  merged,
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
          readbis_sc(bedfiles[1:file_count], thread_count, merged),
          min_iterations = min_iterations,
          max_iterations = min_iterations,
          check = F
        )
      }
    )
  } else {
    if (length(regions) < max(n_regions)) {
      stop("Too few regions provided - change the benchmarked `n_regions`")
    }
    gr <- GRanges(regions)
    query_all_benchmark <- bench::press(
      region_count = n_regions,
      file_count = n_files,
      thread_count = n_threads,
      {
        bench::mark(
          readbis(bedfiles[1:file_count], gr[1:region_count], thread_count, merged),
          min_iterations = min_iterations,
          max_iterations = min_iterations,
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

  benchmark <- benchmark[, thread_count := as.factor(thread_count)][, expression := "biscuiteer"]
  colnames(benchmark)[1] <- "package"

  if (!is.null(outfile)) {
    fwrite(benchmark, outfile, quote = TRUE)
  }
  benchmark
}

