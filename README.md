# iscream-paper

This repo contains the results used to produce the figures in the iscream paper
and the code to run the benchmarks. The code is set up as an R package that
can be installed.

## Requirements

- htslib dev libraries (should be available on your OS package manager/brew on
  MacOS). If using modules, the htslib module must be loaded before loading the
  `iscream-paper` package.

- R
  - GenomicRanges
  - RcppTOML
  - Rsamtools
  - bench
  - biscuiteer
  - bsseq
  - cowplot
  - dplyr
  - ggplot2
  - iscream
  - patchwork
  - rmarkdown

- [python3](https://www.python.org/downloads/)/[pypy3](https://pypy.org/)

- rename

If using [nix](nixos.org), you can use `default.nix` to get the requirements
installed.

## Package

All filepaths to datasets, results, and figures are specified in
[`inst/extdata/config.toml`](https://github.com/huishenlab/iscream-paper/blob/main/inst/extdata/config.toml).
If the defaults need to be changed, they should be changed before package
installation. Alternatively you can set the "iscream.paper.config" option to a
TOML file of your choice that contains all the elements of the one here.

```
data
├── references
│   ├── canary_dmrs.bed
│   └── genes.bed
├── results
│   ├── benchmarks
│   └── figures
│       └── fig1.pdf
└── wgbs
    ├── bulk
    │   ├── biscuit
    │   │   └── canary
    │   └── bismark
    │       └── canary
    └── sc
        ├── biscuit
        │   └── snmcseq
        └── bismark
            └── snmcseq
```

The BED files defining regions go in `data/references` while the WGBS datasets
go in `data/wgbs` as `bulk` or `sc`. The benchmarks and figures go in
`data/results`.

The only data and code that's not part of the package are the memory usage
benchmarks. These are run using
[`scripts/benchmark_memory.sh`](https://github.com/huishenlab/iscream-paper/blob/main/scripts/benchmark_memory.sh).

## Dataset setup

The datasets and regions used are on
[Zenodo](https://zenodo.org/records/14733834?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6ImQ3MDJjNDE2LTg1OGMtNGIyOS04ODAwLWQxNTRlNTU2MDU5YyIsImRhdGEiOnt9LCJyYW5kb20iOiIwZWY1ZWUxN2M5Yjc2OGUxNDVhYWNjYzVhYjAzM2I3MSJ9.B5SIW0-9i2-6g-7mDgPrH51lJFO4BctiOgmzifsy2R2apeVUCvHsOinBUvXNilQicQ5CYPojLoLU2y6ZLPFFow).

### Recreate figure

To recreate the figure from the paper without running the benchmarks, unzip the
`benchmark_results.zip` from the Zenodo repository into
`data/results/benchmarks` and run `fig1.R` With this datasets, you can also knit
supplement.rmd to produce the supplementary data and figures.

To run the benchmarks, you need to download the BED files.

WGBS BED files:

- `bulk_beds.zip`: contains bulk WGBS BED files, download and unzip to `data/wgbs/bulk/biscuit`
- `sc_beds.zip`: contains scWGBS BED files, download and unzip to `data/wgbs/sc/biscuit`

For both these datasets, they can be converted to the bismark BEDgraph format
using
[`scripts/biscuit2cov.py`](https://github.com/huishenlab/iscream-paper/blob/main/inst/scripts/biscuit2cov.py).
pypy3 tends to be a little faster than python3 but both will work. GNU
parallel may also be used to speed up the conversion.

```sh
# from data/wgbs/bulk directory
parallel pypy3 ../../../scripts/biscuit2cov.py {} '>' bismark/canary/{/.} ::: biscuit/canary/*mergecg.bed.gz
parallel tabix -b 2 -e 3 {} ::: bismark/canary/*mergecg.bed.gz
rename 's/.bed.gz/.cov.gz' bismark/canary/*mergecg.bed.gz

# from data/wgbs/sc directory
parallel pypy3 ../../../scripts/biscuit2cov.py {} '>' bismark/snmcseq2/{/.} ::: biscuit/canary/*.bed.gz
parallel tabix -b 2 -e 3 {} ::: bismark/canary/*.bed.gz
rename 's/.bed.gz/.cov.gz' bismark/snmcseq2/*.bed.gz
```

Regions BED files:

- `genes.bed`: Locations of genes used to benchmark `summarize_regions()`

- `canary_dmrs.bed`: Over 30,000 differentially methylated regions from an
  analysis of the bulk data used to benchmark creation of bsseq and tabix
  queries.

## Running the benchmarks

We recommend using an HPC with SLURM to run the benchmarks. If you want to run
it without a job scheduler you can get runtime benchmarks with
`run_runtime_benchmarks.R`.

**Note for SLURM**: `scripts/runtime/benchmark_runtime.sh` and
`scripts/memory/tracker.sh` have SLURM directives that would need modification
before job submission. Make sure the partition/queue name is correct and that
htslib is correctly loaded, either with a module (as in the script) or however
your system loads dependency libraries.

### Runtime

```bash
bash run_runtime_benchmarks.sh
```

### Memory

**Note:** When running memory benchmarks, each package's
benchmark is run three times and must be the only running R process on the
system for accurate measurements. This script uses SLURM's `--dependency` flag
to make jobs wait for the previous one before running. It uses `cut` to pull the
job ID, but this may need to be modified depending on how your SLURM
installation return the job ID message.

```bash
bash run_memory_benchmarks.sh
```

To get the data for figure 1, run run_benchmarks.R. If you want to run it on a
SLURM system, you can run `run_benchmarks.sh` *after* modifying the SLURM
partition parameter and the htslib module parameters in
`./scripts/runtime/benchmark_runtime.sh`. The system we ran the benchmarks on
had htslib as a module that needed loading. 
To run the memory usage benchmarks, run `scripts/benchmark_memory.sh`.
