library(iscream.paper)
options("iscream.threads" = 1)

sc_beds_bismark <- search_beds(dataset_name = 'snmc', aligner = 'bismark')
bulk_beds_bismark <- search_beds(dataset_name = 'canary', aligner = 'bismark')
canary_regions <- read_bed(iscream_run_conf$datasets$reference$dmrs$file) |> create_regions()

bsseq_results <- iscream_run_conf$results$bsseq
bsseq_sc_loci <- iscream_run_conf$datasets$reference$bsseq_sc_loci
bsseq_bulk_loci <- iscream_run_conf$datasets$reference$bsseq_bulk_loci

benchmark_bsseq(
  sc_beds_bismark,
  regions = bsseq_sc_loci,
  outfile = bsseq_results$sc$data
)

benchmark_bsseq(
  bulk_beds_bismark,
  regions = bsseq_bulk_loci,
  outfile = bsseq_results$bulk$data
)
