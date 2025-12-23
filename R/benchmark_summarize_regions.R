#' Benchmark iscream::summarize regions on varying region, thread and file counts
#'
#' @param bedfile A bedfile to run test on
#' @param regions_file A bed file containing the regions of interest
#' @param sfun The functions to use
#' @param min_iterations The min iterations for bench::mark to run
#' @param max_iterations The max iterations for bench::mark to run
#' @param n_regions A vector of region counts to benchmark
#' @param n_files A vector of file counts to benchmark
#' @param n_threads A vector of thread counts to benchmark
#' @param outfile Optional file to write the benchmark to
#'
#' @importFrom data.table setDT fread fwrite
#' @importFrom bedtoolsr bt.map
#' @importFrom bench mark
#' @importFrom tidyr unnest
#' @import iscream
#' @export
benchmark_summarize_regions <- function(
  bedfile,
  regions_file,
  sfun,
  min_iterations = 3,
  max_iterations = 10,
  n_regions = 30000,
  outfile = NULL
) {
  regions <- fread(regions_file, col.names = c("chr", "start", "end")) |>
    create_regions()
  if (length(regions) < max(n_regions)) {
    stop("Too few regions provided - change the benchmarked `n_regions`")
  }
  tmpfiles <- lapply(n_regions, function(i) {
    tmpfile <- tempfile(pattern = as.character(i), fileext = ".bed")
    system(sprintf("head %s -n %d > %s", regions_file, i, tmpfile))
    tmpfile
  })
  names(tmpfiles) <- n_regions

  summarize_regions_benchmark <- bench::press(
    region_count = n_regions,
    {
      bench::mark(
        summarize_regions(
          bedfile,
          regions[1:region_count],
          columns = 4,
          fun = sfun
        ),
        bt.map(
          tmpfiles[as.character(region_count)],
          bedfile,
          o = sfun,
          c = 4,
          nonamecheck = TRUE
        ),
        min_iterations = min_iterations,
        check = F
      )
    }
  )

  bm_unwrapped <- setDT(summarize_regions_benchmark |> unnest(c(time, gc)))
  benchmark <- (bm_unwrapped[gc != "None"][, .(
    expression,
    region_count,
    time
  )][,
    expression := ifelse(expression %like% "summarize", "iscream", "bedtoolsr")
  ])
  colnames(benchmark)[1] <- "package"

  if (!is.null(outfile)) {
    fwrite(benchmark, outfile, quote = TRUE)
  }
  benchmark
}
