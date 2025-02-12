library(bsseq)
files <- list.files("./data/wgbs/sc/bismark/snmcseq2", full.names = TRUE, pattern = "*.cov.gz$")[1:100]
# loci <- readRDS("./data/references/bsseq_sc_canary_cpgs")
loci <- readRDS("./snmc_canary_100_30000.Rds")
system.time(bs <- read.bismark(files, loci = loci, BPPARAM = BiocParallel::MulticoreParam(workers = 16)))
