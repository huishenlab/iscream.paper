#' Plot all package memory usage
#'
#' @param peak Whether to plot peaks or memory usage over time
#' @param sc Whether to plot sc or bulk
#' @importFrom ggplot2 ggplot aes geom_point stat_summary labs expand_limits
#' scale_color_manual theme_bw scale_fill_brewer
#' @export
plot_mem <- function(peak = TRUE, sc = TRUE) {

  iscream_results <- iscream_run_conf$results$query_all
  summarize_regions_results <- iscream_run_conf$results$summarize_regions
  bsseq_results <- iscream_run_conf$results$bsseq
  biscuiteer_results <- iscream_run_conf$results$biscuiteer

  if (sc) {
    bsseq <- fread(bsseq_results$memory$sc$data)
    iscream <- fread(iscream_results$memory$sc$data)
    iscream_nobs <- fread(iscream_results$memory$sc$data_nobs)
    biscuiteer <- fread(biscuiteer_results$memory$sc$data)
  } else {
    bsseq <- fread(bsseq_results$memory$bulk$data)
    iscream <- fread(iscream_results$memory$bulk$data)
    biscuiteer <- fread(biscuiteer_results$memory$bulk$data)
  }

  bsseq[, package := "BSseq"]
  iscream[, package := "iscream"]
  iscream_nobs[, package := "iscream sparse"]
  biscuiteer[, package := "biscuiteer"]

  plot_data <- rbind(bsseq, iscream, biscuiteer, iscream_nobs)[, rep := as.factor(rep)]
  plot_data[, peak_mem := max(memory), by = .(rep, package)]

  if (peak) {
    ggplot(plot_data, aes(x = package, y = peak_mem, fill = rep)) +
      geom_bar(stat = 'identity', position = 'dodge') +
      theme_bw() +
      scale_fill_brewer(palette = "Dark2") +
      labs(x = "Package", y = "Peak memory used (GiB)")
  } else {
    ggplot(plot_data, aes(x = time, y = memory, color = package)) +
      geom_point(size = 0.5) +
      stat_summary(
        aes(
          x = time,
          group = interaction(package, rep)
        ),
        fun = mean,
        geom = "line",
        linewidth = 0.5,
        show.legend = TRUE
      ) +
      labs(x = "Time (seconds)", y = "Memory usage (GiB)") +
      theme_bw() + package_colors
  }


}
