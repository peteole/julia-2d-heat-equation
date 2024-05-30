nvhpc_mod=$(module avail nvhpc-22 | grep -o 'nvhpc-[0-9.]*' | sort -V | tail -n 1)
module load $nvhpc_mod
nvcc -o main main.cu
module unload $nvhpc_mod