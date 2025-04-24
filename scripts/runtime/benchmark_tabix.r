library(iscream.paper)
options("iscream.threads" = 1)

sc_beds_biscuit <- search_beds(dataset_name = 'snmc', aligner = 'biscuit', mergecg = FALSE)
bulk_beds_biscuit <- search_beds(dataset_name = 'canary', aligner = 'biscuit')
canary_regions <- read_bed(iscream_run_conf$datasets$reference$dmrs$file) |> create_regions()

tabix_results <- iscream_run_conf$results$tabix

benchmark_tabix(
  sc_beds_biscuit[1],
  regions = canary_regions,
  raw = T,
  outfile = tabix_results$sc$data
)

benchmark_tabix(
  bulk_beds_biscuit[1],
  regions = canary_regions,
  raw = T,
  outfile = tabix_results$bulk$data
)

