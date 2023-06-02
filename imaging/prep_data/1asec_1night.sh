#!/bin/bash
#SBATCH -c 6
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jurjendejong@strw.leidenuniv.nl
#SBATCH --job-name=prep_1asec_1sec

echo $SLURM_JOB_NAME

#SINGULARITY SETTINGS
SING_BIND=$( python3 $HOME/parse_settings.py --BIND )
SIMG=$( python3 $HOME/parse_settings.py --SIMG )

re="L[0-9][0-9][0-9][0-9][0-9][0-9]"
re_subband="([^.]+)"
if [[ $PWD =~ $re ]]; then OBSERVATION=${BASH_REMATCH}; fi

OUT_DIR=$PWD
cd ${OUT_DIR}

echo "Copy data from applycal folder..."

cp -r /project/lofarvwf/Share/jdejong/output/ELAIS/${OBSERVATION}/apply_delaycal/applycal*.ms .

echo "...Finished copying from applycal folder"

echo "Average data in DPPP..."

#Average to 4seconds and 4ch/SB
for MS in applycal*.ms
do
  singularity exec -B ${SING_BIND} ${SIMG} DP3 \
  msin=${MS} \
  msout=avg_${MS} \
  msin.datacolumn=DATA \
  msout.storagemanager=dysco \
  msout.writefullresflag=False \
  steps=[avg] \
  avg.type=averager \
  avg.freqstep=4 \
  avg.timeresolution=4

  rm -rf ${MS}

done

echo "... Finished averaging data in DPPP"

#MSLIST
ls -1 -d avg_applycal* > mslist.txt


# check output
singularity exec -B $PWD,/project,/home/lofarvwf-jdejong/scripts $SIMG \
python ../../extra_scripts/check_missing_freqs_in_ms.py \
--ms avg*.ms

#rm -rf applycal*

mkdir DATA
cp -r *.ms DATA