#' Plot iscream::query_all against bsseq::read.bismark and biscuiteer::readBiscuit
#'
#' @param benchmark The color to use for iscream::bsseq
#' @param files_or_regions Whether to plot files or region counts as x-axis.
#' @param other_max_count The count to fix either file or regions at - the opposite of the files_or_regions arg
#' @param linewidth The alpha level for the points
#' @param dot_size The size for the runtime geom_points
#' @param alpha The alpha level for the points
#' @param outfile Optional file to write the plot to
#'
#' @importFrom ggplot2 ggplot aes geom_point stat_summary labs expand_limits scale_color_manual theme_bw
#' @export
plot_bsseq <- function(
  benchmark,
  files_or_regions = "files",
  other_max_count = 10,
  linewidth = 0.6,
  dot_size = 0.5,
  alpha = 0.8,
  outfile = NULL
) {

  x_axis <- ifelse(files_or_regions == 'files', "file_count", "region_count")
  cap_axis <- ifelse(files_or_regions == 'files', "region_count", "file_count")
  plot_data <- benchmark
  if ( (files_or_regions == "files" & "region_count" %in% colnames(benchmark)) || (files_or_regions == "regions" & "region_count" %in% colnames(benchmark)) ) {
    plot_data <- benchmark[get(cap_axis) == other_max_count]
  }

  p <- ggplot(plot_data, aes(
    x = get(x_axis),
    y = time,
    color = package,
    linetype = thread_count,
    shape = thread_count
  )) +
    stat_summary(
      aes(y = time, group = interaction(package, thread_count), linetype = thread_count),
      fun = mean,
      geom = "line",
      linewidth = linewidth,
      show.legend = TRUE
    ) +
    geom_point(alpha = alpha, show.legend = TRUE) +
    expand_limits(y = 0) +
    labs(
      y = "Runtime (seconds)",
      x = paste("No. of", files_or_regions),
      color = "Package",
      linetype = "Thread count",
      shape = "Thread count"
    ) +
    package_colors +
    theme_bw()

  if ('exp_type' %in% colnames(plot_data)) {
    p <- p + facet_grid(rows = vars(exp_type))
  }

  if (!is.null(outfile)) {
    pdf(outfile)
    print(p)
    dev.off()
  }

  p
}
