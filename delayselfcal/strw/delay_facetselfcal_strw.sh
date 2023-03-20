#!/bin/bash

SIMG=/net/lofar1/data1/sweijen/software/LOFAR/singularity/lofar_sksp_ddf_rijnX.sif
BIND=/tmp,/dev/shm,/disks/paradata,/data1,/net/lofar1,/net/rijn,/net/nederrijn/,/net/bovenrijn,/net/botlek,/net/para10,/net/lofar2,/net/lofar3,/net/lofar4,/net/lofar5,/net/lofar6,/net/lofar7,/disks/ftphome,/net/krommerijn,/net/voorrijn,/net/achterrijn,/net/tussenrijn,/net/ouderijn,/net/nieuwerijn,/net/lofar8,/net/lofar9,/net/rijn8,/net/rijn7,/net/rijn5,/net/rijn4,/net/rijn3,/net/rijn2

MSIN=$1

singularity exec -B $BIND $SIMG \
python /home/lofarvwf-jdejong/scripts/lofar_facet_selfcal/facetselfcal.py \
--imsize=1600 \
-i selfcal_allstations4_LBCS_final \
--pixelscale=0.075 \
--uvmin=20000 \
--robust=-1.5 \
--uvminim=1500 \
--skymodel=7C1604+5529.skymodel \
--soltype-list="['scalarphasediff','scalarphase','scalarphase','scalarphase','scalarcomplexgain','fulljones','scalarcomplexgain']" \
--soltypecycles-list="[0,0,0,0,0,0,0]" \
--solint-list="['8min','32s','32s','2min','20min','20min','40min']" \
--nchan-list="[1,1,1,1,1,1]" \
--smoothnessconstraint-list="[10.0,1.25,10.0,20.,7.5,5.0,7.5]" \
--normamps=False --smoothnessreffrequency-list="[120.,120.,120.,120,0.,0.,0.]" \
--antennaconstraint-list="['alldutch',None,None,None,None,'alldutch',None]" \
--forwidefield \
--avgfreqstep=5 \
--avgtimestep=4 \
--docircular \
--skipbackup \
--uvminscalarphasediff=0 \
--makeimage-ILTlowres-HBA \
--makeimage-fullpol \
--resetsols-list="[None,'alldutch','core',None,None,None,None]" \
--stop=1 \
${MSIN}