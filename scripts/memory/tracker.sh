#!/usr/bin/env bash
#SBATCH --time=05:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=shen
#SBATCH -o slurm-%x-%j.out
#SBATCH -e slurm-%x-%j.err

module load bbc2/htslib/htslib-1.22

sleep_time=1
nohup bash scripts/memory/track.sh $sleep_time > $2 2>&1 &
pgrep -P $$
Rscript $1
sleep $sleep_time
pkill -P $$

sleep 5

nohup bash scripts/memory/track.sh $sleep_time >> $2 2>&1 &
pgrep -P $$
Rscript $1
sleep $sleep_time
pkill -P $$

sleep 5

nohup bash scripts/memory/track.sh $sleep_time >> $2 2>&1 &
pgrep -P $$
Rscript $1
sleep $sleep_time
pkill -P $$
