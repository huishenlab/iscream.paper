get_runtime_diff <- function(files = 100) {
  runtime_dt_sc <- read_sc()[, exp_type := "single-cell"][]
  runtime_dt_bulk <- read_bulk()[, exp_type := "bulk"][]
  runtime_dt <- rbind(runtime_dt_sc, runtime_dt_bulk)[file_count == files]

  runtime_dt[,
    time.mean := mean(time),
    by = .(package, file_count, thread_count, exp_type)
  ]

  iscream_means <- runtime_dt[
    package == 'iscream',
    .(iscream.min = min(time.mean)),
    by = .(package, thread_count, file_count, exp_type)
  ]
  (runtime_dt[iscream_means, on = .(thread_count, file_count, exp_type)][,
    time.relative := time.mean / iscream.min
  ][, .(package, exp_type, thread_count, file_count, time.relative)]) |>
    unique()
}

#' Plot relative differences in runtime
#
#' @importFrom ggplot2 ggplot aes geom_bar position_dodge2 labs scale_fill_manual theme_bw facet_grid theme element_text scale_y_continuous
#' @import data.table
#' @export
plot_runtime_diff <- function(files = 100) {
  rdiff <- get_runtime_diff(files)
  rdiff <- get_runtime_diff(files)
  rdiff$package <- factor(
    rdiff$package,
    levels = c("iscream", "BSseq", "biscuiteer")
  )

  thread_colors_fill <<- scale_fill_manual(
    values = c("16" = "#E66100", "1" = "#5D3A9B")
  )

  ggplot(rdiff, aes(x = package, y = time.relative, fill = thread_count)) +
    geom_bar(
      stat = 'identity',
      position = position_dodge2(reverse = TRUE, padding = 0)
    ) +
    labs(
      x = "Package",
      y = "Relative runtime difference to iscream",
      fill = "Thread count"
    ) +
    thread_colors_fill +
    theme_bw() +
    facet_grid(~exp_type) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    scale_y_continuous(breaks = seq(0, round(max(rdiff$time.relative)), 2))
}
