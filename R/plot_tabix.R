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
  alpha = 0.5,
  outfile = NULL
) {
  p <- ggplot(
    tabix_benchmark,
    aes(x = region_count, y = time, color = package)
  ) +
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


#' Plot iscream::tabix - Rsamtools::scanTabix benchmark per record
#'
#' @param sc_tabix The single-cell benchmark to plot (from `benchmark_tabix`)
#' @param bulk_tabix The bulk benchmark to plot (from `benchmark_tabix`)
#' @param linewidth The linewidth to use for the mean runtime line
#' @param dot_size The size for the jitter runtime points
#' @param alpha The alpha level for the points
#' @param outfile Optional file to write the plot to
#'
#' @importFrom ggplot2 ggplot aes stat_summary labs expand_limits
#' @importFrom ggplot2 scale_color_manual scale_linetype_manual scale_shape_manual theme_bw
#' @importFrom ggplot2 scale_x_continuous margin
#' @export
plot_tabix_per_record <- function() {
  tabix_sc <- fread(iscream_run_conf$results$tabix$sc$data)
  tabix_bulk <- fread(iscream_run_conf$results$tabix$bulk$data)
  tabix_benchmark <- rbind(
    tabix_sc[, exp_type := "single-cell"],
    tabix_bulk[, exp_type := "bulk"]
  )
  pd <- tabix_benchmark[, label := paste0(package, ", ", exp_type)][,
    label := as.factor(label)
  ]
  legend_name <- "Package & experiment type"
  ggplot(
    pd,
    aes(
      x = record_count,
      y = time,
      color = package,
      shape = exp_type,
      linetype = exp_type
    )
  ) +
    stat_summary(
      aes(y = time, group = interaction(package, exp_type)),
      fun = mean,
      geom = "line",
      linewidth = 0.6,
    ) +
    labs(
      title = "Runtime (seconds)",
      x = "No. of records returned",
      y = NULL
    ) +
    geom_jitter(alpha = 0.6, size = 2) +
    package_colors +
    theme_bw() +
    theme(
      legend.position = "bottom",
      text = element_text(size = 12),
      plot.margin = margin(1, 10, 1, 1, "pt")
    )
}
