#!/bin/bash
#SBATCH -c 15
#SBATCH --job-name=subtract
#SBATCH --array=0-36%4
#SBATCH --constraint=amd
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jurjendejong@strw.leidenuniv.nl

NIGHT=$1

#SINGULARITY SETTINGS
SING_BIND=$( python3 $HOME/parse_settings.py --BIND )
SIMG=$( python3 $HOME/parse_settings.py --SIMG )

OUTPUTFOLDER=${PWD}/facet_${SLURM_ARRAY_TASK_ID}
RUNFOLDER=${TMPDIR}/facet_${SLURM_ARRAY_TASK_ID}/${NIGHT}

mkdir -p ${OUTPUTFOLDER}
mkdir -p ${RUNFOLDER}

cp -r apply*${NIGHT}*.ms ${RUNFOLDER}
cp poly_${SLURM_ARRAY_TASK_ID}.reg ${RUNFOLDER}
cp facets_1.2.reg ${RUNFOLDER}
cp merged_${NIGHT}.h5 ${RUNFOLDER}
cp polygon_info.csv ${RUNFOLDER}


cd ${RUNFOLDER}

#subtract ms with wsclean for each facet
singularity exec -B ${SING_BIND} ${SIMG} python \
/home/lofarvwf-jdejong/scripts/lofar_helpers/subtract_with_wsclean/subtract_with_wsclean.py \
--mslist apply*${NIGHT}*.ms \
--region poly_${SLURM_ARRAY_TASK_ID}.reg \
--model_image_folder /project/lofarvwf/Share/jdejong/output/ELAIS/ALL_L/imaging/DD_1.2/${NIGHT}_2606/ \
--facets_predict facets_1.2.reg \
--h5parm_predict merged_${NIGHT}.h5 \
--applycal \
--applybeam \
--forwidefield

mv sub*${NIGHT}.ms ${OUTPUTFOLDER}
mv *.log ${OUTPUTFOLDER}_${NIGHT}
mv *.txt ${OUTPUTFOLDER}_${NIGHT}

#
#K=$(( ${SLURM_ARRAY_TASK_ID}+2 ))
#AVG=$(cat polygon_info.csv | head -n $K | tail -n 1 | cut -d',' -f7)
#IMSIZE=$(( 22500/${AVG} ))
#
#sbatch /home/lofarvwf-jdejong/scripts/lofar_vlbi_helpers/imaging/split_facets/make_image_1.2.sh $IMSIZE

#apply solutions to new subtracted MS
#make image