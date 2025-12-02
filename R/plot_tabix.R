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

#' Plot iscream::tabix - benchmarks against the shell tabix
#'
#' @importFrom ggplot2 ggplot aes labs geom_bar
#' @export
plot_tabix_shell <- function() {
  tabix_exec_sc <- fread(
    iscream_run_conf$results$tabix_shell$sc_exec$data,
    col.names = "time"
  )[, .(package = "tabix shell", region_count = 5000, time, record_count = NA)]
  tabix_exec_bulk <- fread(
    iscream_run_conf$results$tabix_shell$bulk_exec$data,
    col.names = "time"
  )[, .(package = "tabix shell", region_count = 5000, time, record_count = NA)]
  tabix_shell_sc <- fread(iscream_run_conf$results$tabix_shell$sc_shell$data)
  tabix_shell_bulk <- fread(
    iscream_run_conf$results$tabix_shell$bulk_shell$data
  )
  tabix_sc <- fread(iscream_run_conf$results$tabix_shell$sc$data)
  tabix_bulk <- fread(iscream_run_conf$results$tabix_shell$bulk$data)

  tabix_benchmark <- rbind(
    tabix_exec_sc[, exp_type := "single-cell"],
    tabix_exec_bulk[, exp_type := "bulk"],
    tabix_shell_sc[, exp_type := "single-cell"][
      package == "iscream",
      package := "iscream shell"
    ],
    tabix_shell_bulk[, exp_type := "bulk"][
      package == "iscream",
      package := "iscream shell"
    ],
    tabix_sc[, exp_type := "single-cell"][
      package == "iscream",
      package := "iscream htslib"
    ],
    tabix_bulk[, exp_type := "bulk"][
      package == "iscream",
      package := "iscream htslib"
    ]
  )

  pd <- tabix_benchmark[,
    package := factor(
      package,
      levels = c(
        "tabix shell",
        "iscream shell",
        "iscream htslib",
        "Rsamtools"
      )
    )
  ]
  ggplot(pd, aes(x = package, y = time)) +
    geom_bar(stat = "summary", fun = "mean", position = "dodge") +
    facet_grid(cols = vars(exp_type)) +
    labs(x = "Query method", y = "Runtime (seconds)") +
    theme_bw() +
    theme(axis.text.x = element_text(size = 7))
}
