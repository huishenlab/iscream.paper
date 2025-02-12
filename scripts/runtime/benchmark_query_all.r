library(iscream.paper)
options("iscream.threads" = 1)

sc_beds_biscuit <- search_beds(dataset_name = 'snmc', aligner = 'biscuit', mergecg = FALSE)
bulk_beds_biscuit <- search_beds(dataset_name = 'canary', aligner = 'biscuit')
canary_regions <- read_bed(iscream_run_conf$datasets$reference$dmrs$file) |> create_regions()

query_all_results <- iscream_run_conf$results$query_all

benchmark_query_all(
  sc_beds_biscuit,
  canary_regions,
  outfile = query_all_results$sc$data
)

benchmark_query_all(
  bulk_beds_biscuit,
  canary_regions,
  outfile = query_all_results$bulk$data
)
