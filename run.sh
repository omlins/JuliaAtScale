#!/bin/bash
# NOTE: nexp was chosen to be the first argument of this script to permit that it may be straightforward adapted to receive a list of executables to be executed as argument.
if (($# < 2)); then
    (>&2 echo "Usage: run.sh <number-of-experiments> <julia-jl-apps>")
    exit
fi
nexp=$1
apps=${@:2} 
TMPDIR=/tmp

#cd $TMPDIR
#LD_LIBRARY_PATH=$TMPDIR/  ldd $TMPDIR/julia/bin/julia # NOTE: deactivate to time bcast!
for app in $apps; do
    for i in $(seq 1 $nexp); do
        LD_LIBRARY_PATH=$TMPDIR/ $TMPDIR/julia/bin/julia --color=no --banner=no -O3 --check-bounds=no --math-mode=fast $TMPDIR/$app
    done
done
#cd -
