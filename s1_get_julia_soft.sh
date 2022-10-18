#!/bin/bash
# EXAMPLE: ./jas/s1_get_julia_soft.sh
#
# requirements: 
# 1. julia must be in PATH
set -o errexit

srcdir=$(pwd)
julia_home=$(dirname $(which julia))/..
rm -f julia_soft.tar.gz
cd $julia_home
tar -czf $srcdir/julia_soft.tar.gz .
cd -