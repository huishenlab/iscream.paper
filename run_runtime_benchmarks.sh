#!/usr/bin/env bash

export NAME="tabix"; sbatch -J "$NAME" scripts/runtime/benchmark_runtime.sh "$NAME" &
sleep 1
export NAME="bsseq"; sbatch -J "$NAME" scripts/runtime/benchmark_runtime.sh "$NAME" &
sleep 1
export NAME="biscuiteer"; sbatch -J "$NAME" scripts/runtime/benchmark_runtime.sh "$NAME" &
sleep 1
export NAME="query_all"; sbatch -J "$NAME" scripts/runtime/benchmark_runtime.sh "$NAME" &
sleep 1
export NAME="summarize_regions"; sbatch -J "$NAME" scripts/runtime/benchmark_runtime.sh "$NAME" &
