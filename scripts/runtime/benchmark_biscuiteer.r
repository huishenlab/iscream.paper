library(iscream.paper)
options("iscream.threads" = 1)

sc_beds_biscuit <- search_beds(dataset_name = 'snmc', aligner = 'biscuit', mergecg = FALSE)
bulk_beds_biscuit <- search_beds(dataset_name = 'canary', aligner = 'biscuit')
canary_regions <- read_bed(iscream_run_conf$datasets$reference$dmrs$file) |> create_regions()

biscuiteer_results <- iscream_run_conf$results$biscuiteer

benchmark_biscuiteer(
  sc_beds_biscuit,
  regions = canary_regions,
  merged = TRUE,
  outfile = biscuiteer_results$bulk$data
)

benchmark_biscuiteer(
  bulk_beds_biscuit,
  regions = canary_regions,
  merged = TRUE,
  outfile = biscuiteer_results$bulk$data
)

