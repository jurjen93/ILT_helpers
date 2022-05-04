#!/bin/bash
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jurjendejong@strw.leidenuniv.nl

#1 --> html.txt
#2 --> path

wget -ci $1 -P $2
python3 ~/scripts/ILT_helpers/untar.py --path $2