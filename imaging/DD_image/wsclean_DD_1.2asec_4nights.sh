#!/bin/bash
#SBATCH -c 60
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jurjendejong@strw.leidenuniv.nl
#SBATCH --constraint=amd
#SBATCH -p infinite
#SBATCH --exclusive
#SBATCH --constraint=mem950G
#SBATCH --job-name=DD_1_imaging

OUT_DIR=$PWD

#SINGULARITY SETTINGS
SING_BIND=$( python3 $HOME/parse_settings.py --BIND )
SIMG=$( python3 $HOME/parse_settings.py --SIMG )

#source ../prep_data/1asec_4nights.sh
cp -r ../avg*.ms .
cp ../*.h5 .

LIST=(*.ms)
H5S=(*.h5)
HH=${H5S[@]}

singularity exec -B ${SING_BIND} ${SIMG} python \
/home/lofarvwf-jdejong/scripts/lofar_vlbi_helpers/extra_scripts/ds9facetgenerator.py \
--h5 ${H5S[0]} \
--DS9regionout facets.reg \
--imsize 22500 \
--ms ${LIST[0]} \
--pixelscale 0.4

echo "Move data to tmpdir..."
mkdir "$TMPDIR"/wscleandata
mv *.h5 "$TMPDIR"/wscleandata
mv facets.reg "$TMPDIR"/wscleandata
mv avg*.ms "$TMPDIR"/wscleandata
cd "$TMPDIR"/wscleandata

echo "----------START WSCLEAN----------"

singularity exec -B ${SING_BIND} ${SIMG} \
wsclean \
-update-model-required \
-gridder wgridder \
-minuv-l 80.0 \
-size 22500 22500 \
-weighting-rank-filter 3 \
-reorder \
-weight briggs -1.5 \
-parallel-reordering 6 \
-mgain 0.65 \
-data-column DATA \
-auto-mask 2.5 \
-auto-threshold 1.0 \
-pol i \
-name 1.2image \
-scale 0.4arcsec \
-taper-gaussian 1.2asec \
-niter 150000 \
-log-time \
-multiscale-scale-bias 0.7 \
-parallel-deconvolution 2600 \
-multiscale \
-multiscale-max-scales 9 \
-nmiter 9 \
-facet-regions facets.reg \
-apply-facet-solutions ${HH// /,} amplitude000,phase000 \
-parallel-gridding 6 \
-apply-facet-beam \
-facet-beam-update 600 \
-use-differential-lofar-beam \
-channels-out 6 \
-deconvolution-channels 3 \
-join-channels \
-fit-spectral-pol 3 \
-dd-psf-grid 3 3 \
avg*.ms

rm -rf avg*.ms
#
tar cf output.tar *
cp "$TMPDIR"/wscleandata/output.tar ${OUT_DIR}

cd ${OUT_DIR}
tar -xf output.tar *fits

echo "----FINISHED----"
