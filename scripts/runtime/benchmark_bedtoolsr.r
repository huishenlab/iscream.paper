library(iscream.paper)
library(data.table)
options("iscream.threads" = 1)

sc_beds_biscuit <- search_beds(
  dataset_name = 'snmc',
  aligner = 'biscuit',
  mergecg = FALSE
)
bulk_beds_biscuit <- search_beds(dataset_name = 'canary', aligner = 'biscuit')
canary_regions <- iscream_run_conf$datasets$reference$dmrs$file
genes <- iscream_run_conf$datasets$reference$genes$file

bedtoolsr_results <- iscream_run_conf$results$bedtoolsr

# wgbs for supplement
benchmark_summarize_regions(
  sc_beds_biscuit[1],
  regions_file = canary_regions,
  n_regions = c(100, 500, 1000, 5000, 10000, 30000),
  sfun = "sum",
  outfile = bedtoolsr_results$sc$data
)

benchmark_summarize_regions(
  sc_beds_biscuit[1],
  n_regions = c(100, 500, 1000, 5000, 10000),
  regions_file = "data/references/g.bed",
  sfun = "sum",
  outfile = bedtoolsr_results$sc_genes$data
)

benchmark_summarize_regions(
  bulk_beds_biscuit[1],
  n_regions = c(100, 500, 1000, 5000, 10000),
  regions_file = "data/references/g.bed",
  sfun = "sum",
  outfile = bedtoolsr_results$bulk_genes$data
)

# main fig
benchmark_summarize_regions(
  bulk_beds_biscuit[1],
  n_regions = c(100, 500, 1000, 5000, 10000, 30000),
  regions_file = canary_regions,
  sfun = "sum",
  outfile = bedtoolsr_results$bulk$data
)
