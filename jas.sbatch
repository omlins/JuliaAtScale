#!/bin/bash -l
#SBATCH --job-name="test"
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive
#SBATCH --hint=nomultithread
#SBATCH --output="jas.out"
#SBATCH --error="jas.err"
#SBATCH --constraint=gpu
##SBATCH --switches=1
#export MV2_USE_CUDA=1
#export MPICH_RDMA_ENABLED_CUDA=1
#export MPICH_G2G_PIPELINE=0

(>&2 echo "job id: " $SLURM_JOB_ID)
(>&2 echo "nodelist: " $SLURM_JOB_NODELIST)

TMPDIR=/tmp
PROGDIR=../prog
nfiles=$(ls $PROGDIR  | wc -l)
nprocs_bcast=$(( $SLURM_JOB_NUM_NODES < $nfiles ? $SLURM_JOB_NUM_NODES : $nfiles )) # min

export JULIA_DEPOT_PATH="$TMPDIR/.julia":"$TMPDIR/julia/local/share/julia":"$TMPDIR/julia/share/julia"

(>&2 echo; >&2 echo "Time for broadcast [s]: ")
time srun --bcast=$TMPDIR/tmpbcast.sh --nodes $nprocs_bcast --ntasks $nprocs_bcast --ntasks-per-node 1  $PROGDIR/bcast.sh
#time srun --ntasks $SLURM_JOB_NUM_NODES --ntasks-per-node 1 cp $PROGDIR/* $TMPDIR/

# keep it alive
#sleep 36000

(>&2 echo; >&2 echo "Time for untar + build LLVM [s]: ")
#TODO: RM: #time srun --bcast=/tmp/tmpprepare.sh --nodes $SLURM_JOB_NUM_NODES --ntasks $SLURM_JOB_NUM_NODES --ntasks-per-node 1  $PROGDIR/prepare.sh
time srun --nodes $SLURM_JOB_NUM_NODES --ntasks $SLURM_JOB_NUM_NODES --ntasks-per-node 1  $TMPDIR/prepare.sh

apps=$JAS_APPS
nexp=$JAS_NEXP
#for app in $apps; do #TODO: rm
if (($JAS_SCALING == 1)); then
    (>&2 echo; >&2 echo "Time for scaling [s]: ")
    time {    
    max_pow2=$JAS_MAX_POW2 #7 #-1 #13     # 2**12 = 4096 => choose 13 -> will be changed to nprocs_max
    nprocs_max=$JAS_NPROCS_MAX #5120 # 4096+1024 = 5120
    # Run on one node (concurrently with the following) to make sure that all nodes will have been used before the last, full allocation job is run (else there would be just one node missing and all other nodes would have to wait for this node to be initialized too)
    #cmd="srun --nodes 1 --ntasks 1 $TMPDIR/run.sh $nexp $apps"
    #$cmd &
    #(>&2 echo "$cmd &")
    for p in $(seq $(($max_pow2)) -1 0); do #10
        nprocs=$((2**$p))
        nprocs=$(( $nprocs < $nprocs_max ? $nprocs : $nprocs_max )) # min($nprocs, $nprocs_max)
        cmd="srun --nodes $nprocs --ntasks $nprocs --ntasks-per-node 1  $TMPDIR/run.sh $nexp $apps"
        #if (($p==$max_pow2 || $p==$max_pow2-1)); then  # block execution at second last and last (to make sure that all runs are finished before the largest run and that all runs are finished before the job script finishes!)
        if ((2*$nprocs>$SLURM_JOB_NUM_NODES)); then  # block execution for test with more than 50% of the nodes.
            $cmd
        else
            $cmd &
            cmd="$cmd &"
        fi
        (>&2 echo $cmd)
    done
    wait
    (>&2 echo wait)
    }
else
    (>&2 echo; >&2 echo "Time for run with fixed node-count [s]: ")
    nprocs=$SLURM_JOB_NUM_NODES
    time srun --nodes $nprocs --ntasks $nprocs --ntasks-per-node 1 $TMPDIR/run.sh $nexp $apps
fi
#done  #TODO: rm

#(>&2 echo "Time for srun [s]: ")
#app=a.out
#time srun --bcast=/tmp/tmprun.sh $PROGDIR/run.sh $nexp $app
#time srun $PROGDIR/$app

# keep it alive
#sleep 3600


# Content of folder after run(s):
echo; echo "New content of $JAS_DIR:"
ls -l $JAS_DIR

echo; echo "New content of $JAS_DIR/out:"
ls -l $JAS_DIR/out
