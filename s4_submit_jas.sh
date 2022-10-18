#!/bin/bash
# EXAMPLE: JAS_DIR=$SCRATCH/julia_scaling/ JAS_APPS='diff3D.jl' JAS_NEXP=1 JAS_SCALING=1 JAS_MAX_POW2=0 JAS_NPROCS_MAX=5120 ./jas/s4_submit_jas.sh --ntasks=1 <sbatch-args...>
# NOTE: All .jl files in the srcdir are considered part of the apps to be tested!
#
# Requirements: 
# 1. $JAS_DIR (e.g. $SCRATCH/julia_scaling/) must exist and contain a folder ./out, where striping should be preset!
#
# Args:
# 1. sbatch-args...
# if (($# < 1)); then
#     (>&2 echo "Usage: JAS_DIR=<...> JAS_APPS=<...> JAS_NEXP=<...> JAS_SCALING=<...> JAS_MAX_POW2=<...> JAS_NPROCS_MAX=<...> ./jas/submit_jas.sh <sbatch-args...>")
#     exit
# fi
set -o errexit

if [[ -z "${JAS_DIR}" ]]; then
    (>&2 echo "JAS_DIR is not set!"); exit 1
fi
if [[ -z "${JAS_APPS}" ]]; then
    (>&2 echo "JAS_APPS is not set!"); exit 1
else
    for app in $JAS_APPS; do
        if [ ! -f $app ]; then
            (>&2 echo "File $app not found!"); exit 1
        fi
    done
fi
if [[ -z "${JAS_NEXP}" ]]; then
    (>&2 echo "JAS_NEXP is not set!"); exit 1
# elif ! [[ $JAS_NEXP =~ '^[0-9]+$' ]] ; then
#     (>&2 echo "JAS_NEXP is not an integer!"); #exit 1
fi
if [[ -z "${JAS_SCALING}" ]]; then
    (>&2 echo "JAS_SCALING is not set!"); exit 1
# elif ! [[ $JAS_MAX_POW2 =~ '^[0-1]$' ]] ; then
#     (>&2 echo "JAS_MAX_POW2 is not 0 or 1!"); exit 1
fi
if (($JAS_SCALING == 1)); then
    if [[ -z "${JAS_MAX_POW2}" ]]; then
        (>&2 echo "JAS_MAX_POW2 is not set!"); exit 1
    # elif ! [[ $JAS_MAX_POW2 =~ '^[0-9]+$' ]] ; then
    #     (>&2 echo "JAS_MAX_POW2 is not an integer!"); exit 1
    fi
    if [[ -z "${JAS_NPROCS_MAX}" ]]; then
        (>&2 echo "JAS_NPROCS_MAX is not set!"); exit 1
    # elif ! [[ $JAS_NPROCS_MAX =~ '^[0-9]+$' ]] ; then
    #     (>&2 echo "JAS_NPROCS_MAX is not an integer!"); exit 1
    fi
fi

echo; echo "Current content of $JAS_DIR:"
ls -l $JAS_DIR             # also immediately aborts with error if does not exits...

echo; echo "Current content of $JAS_DIR/out:"
ls -l $JAS_DIR/out         # also immediately aborts with error if does not exits...

echo; echo; read -p "ALL FILES IN $JAS_DIR/out AND $JAS_DIR/prog WILL BE DELETED. ARE YOU SURE YOU WANT TO CONTINUE? (y/n)" -n 1 -r; echo; echo
if ! [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "ABORTED!"; echo; exit 1
fi

workdir=$JAS_DIR/out
progdir=../prog
projectdir=$(pwd)
srcdir=$projectdir/jas

rm -f $workdir/*
cd $workdir
rm -rf $progdir
mkdir $progdir
echo "workdir: " $(pwd)
echo "progdir: " $workdir/$progdir; echo

cp $srcdir/jas.sbatch $srcdir/bcast.sh  $srcdir/prepare.sh $srcdir/run.sh $progdir/
cp $projectdir/*.jl $projectdir/mylib/* $projectdir/julia_soft.tar.gz  $projectdir/julia_depot.tar.gz $progdir/

sbatch $* $progdir/jas.sbatch # NOTE: All arguments are passed further to sbatch.
