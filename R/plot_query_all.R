#' Plot iscream::query_all - Rsamtools::scanTabix benchmark
#'
#' @param query_all The benchmark to plot (from `benchmark_query_all`)
#' @param linewidth The linewidth to use for the mean runtime line
#' @param dot_size The size for the jitter runtime points
#' @param alpha The alpha level for the points
#' @param outfile Optional file to write the plot to
#'
#' @importFrom data.table setDT fwrite
#' @importFrom bench mark
#' @importFrom GenomicRanges GRanges
#' @importFrom Rsamtools scanTabix
#' @importFrom iscream query_all
#' @importFrom ggplot2 ggplot aes geom_jitter stat_summary labs expand_limits scale_color_manual theme_bw facet_grid
#' @export
plot_query_all <- function(
  query_all_benchmark,
  linewidth = 1,
  dot_size = 0.5,
  alpha = 0.8,
  outfile = NULL
) {

  if ('exp_type' %in% colnames(query_all_benchmark)) {
    p <- ggplot(query_all_benchmark, aes(x = region_count, y = time, shape = exp_type)) +
      stat_summary(
        aes(y = time, group = interaction(thread_count, exp_type), linetype = exp_type),
        fun = mean,
        geom = "line",
        linewidth = linewidth,
      ) +
      facet_grid(file_count ~ thread_count, labeller = 'label_both') +
      labs(y = "Runtime (seconds)", x = "No. of regions", shape = "Experiment type", linetype = "Experiment type")
  } else {
    p <- ggplot(query_all_benchmark, aes(x = region_count, y = time)) +
      stat_summary(
        aes(y = time, group = thread_count),
        fun = mean,
        geom = "line",
        linewidth = linewidth,
      ) +
      facet_grid(file_count ~ thread_count, labeller = 'label_both')
      labs(y = "Runtime (seconds)", x = "No. of regions")
  }

  p <- p + geom_jitter(alpha = alpha) + expand_limits(y = 0) + theme_bw()

  if (!is.null(outfile)) {
    pdf(outfile)
    print(p)
    dev.off()
  }

  p
}

