#' Plot iscream::summarize_regions - Rsamtools::scanTabix benchmark
#'
#' @param summarize_regions The benchmark to plot (from `benchmark_summarize_regions`)
#' @param linewidth The linewidth to use for the mean runtime line
#' @param dot_size The size for the jitter runtime points
#' @param alpha The alpha level for the points
#' @param outfile Optional file to write the plot to
#'
#' @importFrom data.table setDT fwrite
#' @importFrom bench mark
#' @importFrom GenomicRanges GRanges
#' @importFrom Rsamtools scanTabix
#' @importFrom iscream summarize_regions
#' @importFrom ggplot2 ggplot aes geom_jitter stat_summary labs expand_limits scale_color_manual theme_bw facet_grid
#' @export
plot_summarize_regions <- function(
  summarize_regions_benchmark,
  linewidth = 1,
  dot_size = 0.5,
  alpha = 0.8,
  outfile = NULL
) {
  if ('exp_type' %in% colnames(summarize_regions_benchmark)) {
    p <- ggplot(
      summarize_regions_benchmark,
      aes(x = region_count, y = time, color = package, shape = exp_type)
    ) +
      geom_jitter() +
      stat_summary(
        aes(
          y = time,
          group = interaction(package, exp_type),
          linetype = exp_type,
          color = package
        ),
        fun = mean,
        geom = "line",
        linewidth = linewidth,
      ) +
      labs(
        y = "Runtime (seconds)",
        x = "No. of regions",
        shape = "Experiment type",
        linetype = "Experiment type"
      )
  } else {
    p <- ggplot(
      summarize_regions_benchmark,
      aes(x = region_count, y = time, color = package)
    ) +
      geom_jitter() +
      stat_summary(
        aes(y = time, group = package),
        fun = mean,
        geom = "line",
        linewidth = linewidth,
      ) +
      labs(y = "Runtime (seconds)", x = "No. of regions")
  }

  p <- p + expand_limits(y = 0) + package_colors + theme_bw()

  if (!is.null(outfile)) {
    pdf(outfile)
    print(p)
    dev.off()
  }

  p
}
