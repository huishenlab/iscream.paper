library(iscream.paper)
options("iscream.threads" = 1)

sc_beds_biscuit <- search_beds(dataset_name = 'snmc', aligner = 'biscuit', mergecg = FALSE)
bulk_beds_biscuit <- search_beds(dataset_name = 'canary', aligner = 'biscuit')
canary_regions <- read_bed(iscream_run_conf$datasets$reference$dmrs$file) |> create_regions()
genes <- read_bed(iscream_run_conf$datasets$reference$genes$file) |> create_regions()

summarize_regions_results <- iscream_run_conf$results$summarize_regions

benchmark_summarize_regions(
  sc_beds_biscuit,
  canary_regions,
  n_regions = 30000,
  n_files = 153,
  n_threads = 16,
  outfile = summarize_regions_results$sc$data
)

benchmark_summarize_regions(
  bulk_beds_biscuit,
  canary_regions,
  n_regions = 30000,
  n_files = 111,
  n_threads = 16,
  outfile = summarize_regions_results$bulk$data
)
