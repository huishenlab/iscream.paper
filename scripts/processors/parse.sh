#!/usr/bin/env bash
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=shen
#SBATCH -o slurm-%x-%j.out
#SBATCH -e slurm-%x-%j.err

python3 scripts/processors/parse.py data/results/benchmarks/mem_bsseq_sc.txt              > data/results/benchmarks/mem_bsseq_sc.tsv
python3 scripts/processors/parse.py data/results/benchmarks/mem_biscuiteer_sc.txt         > data/results/benchmarks/mem_biscuiteer_sc.tsv
python3 scripts/processors/parse.py data/results/benchmarks/mem_query_all_sc.txt          > data/results/benchmarks/mem_query_all_sc.tsv
python3 scripts/processors/parse.py data/results/benchmarks/mem_query_all_sc_all_nobs.txt > data/results/benchmarks/mem_query_all_sc_all_nobs.tsv

