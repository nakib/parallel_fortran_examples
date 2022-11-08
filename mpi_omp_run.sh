#!/bin/bash

workdir="./mpi_omp_2x4"
mkdir $workdir
cd $workdir

let num_nodes=2
let num_ranks_per_node=1
let num_threads=4
let num_ranks_tot=num_nodes*num_ranks_per_node
echo "Number of MPI ranks: " $num_ranks_tot
echo "Number of OMP threads/rank: " $num_threads

cat>run.slurm<<EOF
#!/bin/bash
#SBATCH --job-name="test" # Job name
#SBATCH --partition=cpu36memory192 #cpu16memory128 #cpu32memory512
##SBATCH --mail-type=END,FAIL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=<email address>    # Where to send mail
#SBATCH --ntasks=$num_ranks_tot #Number of cores requested
#SBATCH --nodes=$num_nodes #Number of nodes
#SBATCH --cpus-per-task=$num_threads #Number of threads per node 
#SBATCH --time=0:01:00             # Time limit hrs:min:sec
#SBATCH --output=slurmjob_%j.log     # Standard output and error log
date;hostname;pwd

module load intel-oneapi/2021.4.0

export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so # Depends on mashine. Find path: whereis libmpi.so 
export KMP_AFFINITY=scatter
export OMP_NUM_THREADS=$num_threads

time srun ../parallel_dot_mpi_omp_test.x > parallel_dot_caf_omp_test.out

date

EOF

chmod 750 run.slurm
sbatch run.slurm

cd ..