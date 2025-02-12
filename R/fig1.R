#' Plot Fig 1
#'
#' @param legend_position Where to position the legend in the figure
#' @param outfile Where to write the plot to file
#'
#' @importFrom data.table fread
#' @importFrom patchwork plot_layout plot_annotation
#' @importFrom ggplot2 theme guides theme
#' @export
fig1 <- function(threads = c(1, 16), legend_position = "bottom", outfile = NULL) {

  tabix_results <- iscream_run_conf$results$tabix
  query_all_results <- iscream_run_conf$results$query_all
  summarize_regions_results <- iscream_run_conf$results$summarize_regions
  bsseq_results <- iscream_run_conf$results$bsseq
  biscuiteer_results <- iscream_run_conf$results$biscuiteer

  # Figure 1 A
  tabix_sc <- fread(tabix_results$sc$data)
  tabix_bulk <- fread(tabix_results$bulk$data)
  tabix_combined <- join_exp_types(tabix_sc, tabix_bulk) 
  tabix_combined.plot <- plot_tabix(tabix_combined) + guides(color = 'none')

  # Figure 1 B
  bsseq_sc <- fread(bsseq_results$sc$data)[, thread_count := as.factor(thread_count)]
  query_all_sc <- fread(query_all_results$sc$data)[, thread_count := as.factor(thread_count)]
  biscuiteer_sc <- fread(biscuiteer_results$sc$data)[, thread_count := as.factor(thread_count)]

  all_bsseq_sc <- rbind(bsseq_sc, query_all_sc, biscuiteer_sc)[thread_count %in% c(1, 16)]
  all_bsseq_sc$package <- factor(
    all_bsseq_sc$package,
    levels = c("Rsamtools", "biscuiteer", "BSseq", "iscream")
  )

  all_bsseq_sc.plot_data <- all_bsseq_sc[thread_count %in% threads]
  all_bsseq_sc.plot <- plot_bsseq(
    all_bsseq_sc.plot_data,
    files_or_regions = "files",
    other_max_count = 10000,
    alpha = 0.5
  )

  bsseq_bulk <- fread(bsseq_results$bulk$data)[, thread_count := as.factor(thread_count)]
  query_all_bulk <- fread(query_all_results$bulk$data)[, thread_count := as.factor(thread_count)]
  biscuiteer_bulk <- fread(biscuiteer_results$bulk$data)[, thread_count := as.factor(thread_count)]
  all_bsseq_bulk <- rbind(bsseq_bulk, query_all_bulk, biscuiteer_bulk)
  all_bsseq_bulk.plot_data <- all_bsseq_bulk[thread_count %in% threads]
  all_bsseq_bulk.plot <- plot_bsseq(
    all_bsseq_bulk,
    files_or_regions = "files",
    other_max_count = 10000,
    alpha = 0.5
  ) + guides(color = 'none')

  p <- tabix_combined.plot + all_bsseq_sc.plot + all_bsseq_bulk.plot +
    plot_annotation(tag_levels = "A") +
    plot_layout(guides = 'collect', widths = c(1, 1, 1)) &
    theme(legend.position = legend_position)

  if (!is.null(outfile)) {
    pdf(outfile, width = 10, height = 5)
    print(p)
    dev.off()
  }

  p
}
