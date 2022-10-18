#!/bin/bash
# EXAMPLE: ./jas/s3_copy_libs.sh
#
# Requirements: 
# 1. julia must be in PATH
#
# Args:
# julia, libcuda, libmpi (get from module CUDA_HOME...)

libs=$*
echo $libs
LIBDIR=./mylib
julia_home=$(dirname $(which julia))/..

rm -rf $LIBDIR
mkdir $LIBDIR

for f in $libs; do
    cp $f .
    ldd $f | perl -ne 'print "$1\n" if /(\S*)\s\(\dx[\d\w]+\)/' | xargs cp -f -t $LIBDIR/
    mv $f $LIBDIR/
done

ldd $(which julia) | perl -ne 'print "$1\n" if /(\S*)\s\(\dx[\d\w]+\)/' | xargs cp -f -t $LIBDIR/
cp $julia_home/lib/* $LIBDIR/
cp $julia_home/lib64/* $LIBDIR/
cp $julia_home/lib/julia/* $LIBDIR/
cp $julia_home/lib64/julia/* $LIBDIR/

#TODO: remove? just add julia above?
# exes=''
# exe=julia
# cp $(which $exe) .
# ldd $exe | perl -ne 'print "$1\n" if /(\S*)\s\(\dx[\d\w]+\)/' | xargs cp -f -t $LIBDIR/
# exes="$exes $exe"

# exes=$(echo $exes | xargs) # trim string
# echo "exes=$exes"
# file=scaling.sbatch; cat $file | perl -pe "s/exes=[^\n]*/exes='$exes'/" | tee $file


