library(biscuiteer)
library(parallel)
files <- list.files("./data/wgbs/sc/biscuit/snmcseq2/", full.names = TRUE, pattern = "*.bed.gz$")[1:100]
regions <- data.table::fread("./data/references/canary_dmrs.bed", col.names = c("chr", "start", "end"))[1:30000] |> GenomicRanges::GRanges()

bsseqs <- mclapply(files, function(file) {
  readBiscuit(
    file,
    which = regions,
    VCFfile = gsub("(_mergecg)?.bed.gz", ".vcf.gz", file),
    merged = FALSE,
  )
}, mc.cores = 16)

bisc <- do.call(BiocGenerics::combine, bsseqs)
