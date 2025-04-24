#!/bin/bash
#SBATCH --time=05:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=shen
#SBATCH -o slurm-%x-%j.out
#SBATCH -e slurm-%x-%j.err

Rscript "scripts/runtime/benchmark_$1.r"
