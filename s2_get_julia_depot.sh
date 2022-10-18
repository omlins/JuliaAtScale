#!/bin/bash
# EXAMPLE: ./jas/s2_get_julia_depot.sh
#
# requirements: 
# 1. julia must be in PATH
# 2. all packages to be used should be precompiled in the depot
set -o errexit

srcdir=$(pwd)
depot=$(julia -e 'print(DEPOT_PATH[1])') #NOTE: only the first part is considered for now (the others are in the Julia soft installation).
rm -f julia_depot.tar.gz
cd $depot
tar -czf $srcdir/julia_depot.tar.gz .
cd -
