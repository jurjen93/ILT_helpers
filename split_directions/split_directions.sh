#!/bin/bash
#SBATCH -N 1 -c 5 --job-name=split_directions

#List with L-numbers
L_LIST=$1
#Catalogue with sources
CATALOG=$2

SCRIPTS=/home/lofarvwf-jdejong/scripts/prefactor_helpers

re="L[0-9][0-9][0-9][0-9][0-9][0-9]"
if [[ $PWD =~ $re ]]; then OBSERVATION=${BASH_REMATCH}; fi

export RESULTS_DIR=$PWD
export SIMG=/project/lofarvwf/Software/singularity/lofar_sksp_v3.4_x86-64_generic_noavx512_ddf.sif

echo "Job landed on $(hostname)"

echo "-----------------STARTED SPLIT DIRECTIONS-----------------"

while read -r LNUM; do

  cp /project/lofarvwf/Share/jdejong/output/ELAIS/${LNUM}/subtract/boxfile.reg .
  cp /project/lofarvwf/Share/jdejong/output/ELAIS/L816272/imaging/DI_1asec/DI_I_test/1.2asec_I-dirty.fits .

  echo "Copy applycal ms"
  for MS in /project/lofarvwf/Share/jdejong/output/ELAIS/${LNUM}/apply_delaycal/applycal_sub6asec_${LNUM}*.ms; do
    cp -r ${MS} .
  done

  for MS in applycal_sub6asec_${LNUM}*.ms; do

    #Make calibrator parsets
    singularity exec -B $PWD,/project $SIMG python ${SCRIPTS}/split_directions/make_directions_parsets.py --catalog ${CATALOG} --prefix ${LNUM} --ms ${MS} --fits 1.2asec_I-dirty.fits --boxfile boxfile.reg
    echo "Made parsets for ${LNUM}"

  done

  #Run parsets
  for P in ${LNUM}*.parset; do
    sbatch ${SCRIPTS}/split_directions/phaseshift.sh ${P}
    echo "Launched script for ${P}"
  done


done <$L_LIST

echo "-----------------FINISHED SPLIT DIRECTIONS-----------------"