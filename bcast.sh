#!/bin/bash -l
PROGDIR=../prog
TMPDIR=/tmp
nfiles=$(ls $PROGDIR  | wc -l)
file_id=$SLURM_NODEID
nnodes=$SLURM_JOB_NUM_NODES
declare -a files
files=($PROGDIR/*)

#echo "nnodes: " $nnodes
#echo "id: " $SLURM_NODEID
#echo "nfiles: " $nfiles

while (($file_id < $nfiles)); do
    file=${files[$file_id]}
    #echo "(node $SLURM_NODEID) file (id: $file_id) $file"
    sbcast -f -t 120  $file $TMPDIR/$(basename $file)    
    file_id=$(($file_id + $nnodes))
done
