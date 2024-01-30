#!/bin/bash
#SBATCH -c 1
#SBATCH --output=download_lta_%A_%a.out
#SBATCH --error=download_lta_%A_%a.err

#1 --> html_calibrator.txt

CALHTML=$1


#INPUT PARAMETERS
if [ -n "$CALHTML" ]; then
  echo "You gave $CALHTML as calibrator html list"
  CALDAT=$( realpath $CALHTML )
else
  echo "No arguments supplied"
  echo "Please run script as [ download_lta.sh html_calibrator.txt ]"
  exit 0
fi


#GET SCRIPT RUN DIRECTORY
if [ -n "${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}" ] ; then
SCRIPT=$(scontrol show job "${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}" | awk -F= '/Command=/{print $TARHTML}')
export SCRIPT_DIR=$( echo ${SCRIPT%/*} )
else
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fi

#SINGULARITY SETTINGS
SIMG=$( python3 $SCRIPT_DIR/settings/parse_settings.py --SIMG )
BIND=$( python3 $SCRIPT_DIR/settings/parse_settings.py --BIND )

LNUM=$( grep -Po 'L[0-9][0-9][0-9][0-9][0-9][0-9]' $TARDAT | head -n 1 )
mkdir -p $LNUM
cd $LNUM

#CALIBRATOR
LNUM_CAL=$( grep -Po 'L[0-9][0-9][0-9][0-9][0-9][0-9]' $CALDAT | head -n 1 )
echo "DOWNLOAD DATA FOR CALIBRATOR $LNUM_CAL"
TYPE=calibrator
TARS=$CALDAT

# make data folder
mkdir -p $TYPE/data
cd $TYPE/data

# download data
wget -ci $TARS

# untar data
for TAR in *SB*.tar*; do
  mv $TAR tmp.tar
  tar -xvf tmp.tar
  rm tmp.tar
done

# find missing data
python3 $SCRIPT_DIR/download_scripts/findmissingdata.py

# remove bands above 168 MHz
singularity exec -B ${BIND} ${SIMG} python $SCRIPT_DIR/download_scripts/removebands.py --freqcut 168
