# JuliaAtScale

## Usage

1. `module load Julia` (or similar - Julia must be in the PATH)
2. (remove depot - optional for minimal depot file later - to find depot use `] status`)
3. add all packages required by your application(s) to be run at scale (`] add <packages...>`) - make sure your application runs as expected
4. do `git clone https://github.com/omlins/JuliaAtScale jas` from the folder with you Julia application(s)
5. do `chmod +x jas/*`
6. do `./jas/s1_get_julia_soft.sh`
7. do `./jas/s2_get_julia_depot.sh`
8. do `./jas/s3_copy_libs.sh`
9. use `./jas/s4_submit_jas.sh`, e.g., `JAS_DIR=$SCRATCH/julia_scaling/ JAS_APPS='myapp1.jl myapp2.jl myapp3.jl' JAS_NEXP=1 JAS_SCALING=1 JAS_MAX_POW2=6 JAS_NPROCS_MAX=64 ./jas/s4_submit_jas.sh --ntasks=64 -Acsstaff` (the `JAS_` prefixed environment variables need to be set; any argument after `./jas/s4_submit_jas.sh` is passed as is to `sbatch` used for job submission); *This will delete the content in `$JAS_DIR/out` and `$JAS_DIR/prog`.
