#!/usr/bin/env bash

#jobid          name             run after previous         call tracker script       benchmark R script                                output file
id1=$(sbatch -J mem_bsseq                                   scripts/memory/tracker.sh scripts/memory/benchmark_memory_bsseq.r           data/results/benchmarks/mem_bsseq_sc.txt              | get_slurm_id)
id2=$(sbatch -J mem_biscuiteer   --dependency=afterany:$id1 scripts/memory/tracker.sh scripts/memory/benchmark_memory_biscuiteer.r      data/results/benchmarks/mem_biscuiteer_sc.txt         | get_slurm_id)
id3=$(sbatch -J mem_iscream      --dependency=afterany:$id2 scripts/memory/tracker.sh scripts/memory/benchmark_memory_query_all_bsseq.r data/results/benchmarks/mem_query_all_sc.txt          | get_slurm_id)
id4=$(sbatch -J mem_iscream_nobs --dependency=afterany:$id3 scripts/memory/tracker.sh scripts/memory/benchmark_memory_query_all_nobs.r  data/results/benchmarks/mem_query_all_sc_all_nobs.txt | get_slurm_id)

sbatch -J parse_mem2tsv --dependency=afterany:$id4 scripts/processors/parse.sh
