#' Plot iscream::tabix - Rsamtools::scanTabix benchmark
#'
#' @param tabix_benchmark The benchmark to plot (from `benchmark_tabix`)
#' @param linewidth The linewidth to use for the mean runtime line
#' @param dot_size The size for the jitter runtime points
#' @param alpha The alpha level for the points
#' @param outfile Optional file to write the plot to
#'
#' @importFrom ggplot2 ggplot aes geom_jitter stat_summary labs expand_limits scale_color_manual theme_bw vars
#' @export
plot_tabix <- function(
  tabix_benchmark,
  linewidth = 1,
  dot_size = 1,
  alpha = 0.7,
  outfile = NULL
) {

  p <- ggplot(tabix_benchmark, aes(x = region_count, y = time, color = package)) +
    stat_summary(
      aes(y = time, group = package),
      fun = mean,
      geom = "line",
      linewidth = linewidth,
    ) +
    labs(y = "Runtime (seconds)", x = "No. of regions", color = "Package") +
    geom_jitter(size = dot_size, alpha = alpha) +
    expand_limits(y = 0) +
    package_colors +
    theme_bw()

  if ('exp_type' %in% colnames(tabix_benchmark)) {
    p <- p + facet_grid(rows = vars(exp_type))
  }

  if (!is.null(outfile)) {
    pdf(outfile)
    print(p)
    dev.off()
  }

  p
}
