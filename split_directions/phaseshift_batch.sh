#!/bin/bash
#SBATCH -c 6 --job-name=phaseshift --array=0-4999%1000 --constraint=amd

export SIMG=/project/lofarvwf/Software/singularity/lofar_sksp_v4.1.0_znver2_znver2_noavx512_aocl3_cuda_ddf.sif

OFFSET=$1 # OFFSET BECAUSE SLURM CAN ONLY HAVE MAX 1000

echo "Job landed on $(hostname)"

pattern="*MHz*.parset"
files=( $pattern )
N=$(( ${SLURM_ARRAY_TASK_ID}+${OFFSET} ))

singularity exec -B $PWD,/project,/home/lofarvwf-jdejong/scripts $SIMG DP3 ${files[${N}]}
echo "Launched script for ${files[${N}]}"
