#!/bin/bash
#SBATCH -c 6
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jurjendejong@strw.leidenuniv.nl
#SBATCH --job-name=prep_0.3asec

echo $SLURM_JOB_NAME

#SINGULARITY SETTINGS
SING_BIND=/project/lofarvwf/Share/jdejong,/home
SING_IMAGE_WSCLEAN=/project/lofarvwf/Software/singularity/lofar_sksp_v3.4_x86-64_generic_noavx512_ddf.sif

re="L[0-9][0-9][0-9][0-9][0-9][0-9]"
re_subband="([^.]+)"
if [[ $PWD =~ $re ]]; then OBSERVATION=${BASH_REMATCH}; fi

OUT_DIR=$PWD
cd ${OUT_DIR}

echo "Copy data from applycal folder..."

cp -r /project/lofarvwf/Share/jdejong/output/ELAIS/${OBSERVATION}/apply_delaycal/applycal*.ms .

echo "...Finished copying from applycal folder"

#MSLIST
ls -1 -d applycal* > mslist.txt

MS_VECTOR=[$(cat  mslist.txt |tr "\n" ",")]

echo "Concat data..."

#CONCAT
#singularity exec -B ${SING_BIND} ${SING_IMAGE_WSCLEAN} DP3 \
#msin=${MS_VECTOR} \
#msin.orderms=False \
#msin.missingdata=True \
#msin.datacolumn=DATA \
#msout=${OBSERVATION}_120_168MHz_applied.ms \
#msout.storagemanager=dysco \
#msout.writefullresflag=False \
#steps=[]

echo "...Finished concat"

# CHECK OUTPUT
singularity exec -B $PWD,/project,/home/lofarvwf-jdejong/scripts $SIMG \
python /home/lofarvwf-jdejong/scripts/prefactor_helpers/helper_scripts/check_missing_freqs_in_ms.py \
--ms applycal*

#rm -rf applycal*

mkdir DATA
cp -r *.ms DATA