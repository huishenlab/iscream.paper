get_runtime_diff <- function(sc = TRUE, file_count = 90) {
  if (sc) {
    runtime_dt <- read_sc()
  } else {
    runtime_dt <- read_bulk()
  }

  runtime_dt[,
    time.mean := mean(time),
    by = .(package, file_count, thread_count)
  ]

  iscream_means <- runtime_dt[
    package == 'iscream',
    .(iscream.min = min(time.mean)),
    by = .(package, thread_count, file_count)
  ]
  (runtime_dt[iscream_means, on = .(thread_count, file_count)][,
    time.relative := time.mean / iscream.min
  ][, .(package, thread_count, file_count, time.relative)]) |>
    unique()
}

#' Plot relative differences in runtime
#
#' @importFrom ggplot2 ggplot aes geom_bar position_dodge2 labs scale_fill_manual theme_bw facet_grid theme element_text scale_y_continuous
#' @import data.table
#' @export
plot_runtime_diff <- function(sc = TRUE, file_count = 90) {
  rdiff <- get_runtime_diff(sc, file_count)
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
    facet_grid(~file_count, labeller = 'label_both') +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    scale_y_continuous(breaks = seq(0, round(max(rdiff$time.relative)), 2))
}
