#!/bin/bash
TMPDIR=/tmp
DEPOTDIR=.julia
SOFTDIR=julia
workdir=$(pwd)

cd $TMPDIR
mkdir $DEPOTDIR
mkdir $SOFTDIR

tar -xzf julia_depot.tar.gz -C $DEPOTDIR/
tar -xzf julia_soft.tar.gz -C $SOFTDIR/

LD_LIBRARY_PATH=$TMPDIR/  $TMPDIR/julia/bin/julia --color=no --banner=no -e "import Pkg; Pkg.build(\"LLVM\")" &> $TMPDIR/prepare.log

if (($SLURM_NODEID == 1)); then
    cp $TMPDIR/prepare.log $workdir/prepare.log
fi

cd $workdir   # (`cd -`` causes a print of the directory returned to... on every process)