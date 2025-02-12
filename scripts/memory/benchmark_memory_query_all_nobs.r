library(bsseq)
library(iscream)

set_threads(16)
files <- list.files("./data/wgbs/sc/biscuit/snmcseq2/", full.names = TRUE, pattern = "*.bed.gz$")[1:100]
regions <- data.table::fread("./data/references/canary_dmrs.bed")[, paste0(V1, ":", V2, "-", V3)][1:30000]
system.time(query_all(files, regions, sparse = FALSE, merged = FALSE))
