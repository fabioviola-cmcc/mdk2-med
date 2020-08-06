#!/bin/bash
wdir=/work/opa/witoil-dev/medslik-sanifs/medslik-med/EXE
source ${wdir}/set_env.sh
JJ=$1

# Invoke medslik
MSHome=/work/opa/witoil-dev/medslik-sanifs/medslik-med/EXE
MSCommand=./RUN_crop.sh
# bsub -e ${wdir}/log/%J.err -o ${wdir}/log/%J.out -q s_short -J ${JJ} $MSHome/$MSCommand
#bsub -R "span[ptile=1] rusage[mem=50GB]" -Is -q s_medium -P 0372 -J ${JJ} $MSHome/$MSCommand
bsub -n 5 -R "span[ptile=1] rusage[mem=50GB]" -Is -q s_short -P 0372 -J ${JJ} $MSHome/$MSCommand 
