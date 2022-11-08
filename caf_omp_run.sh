#!/bin/bash

workdir="./caf_omp_2x4"
mkdir $workdir
cd $workdir

let num_nodes=2
let num_threads_per_node=4
let num_threads_tot=num_nodes*num_threads_per_node
echo "Number of coarray images: " $num_nodes
echo "Number of OMP threads/coarray image: " $num_threads_per_node
echo "Total number of OMP threads: " $num_threads_tot

cat>run.slurm<<EOF
#!/bin/bash
#SBATCH --job-name="test" # Job name
#SBATCH --partition=cpu36memory192 #cpu16memory128 #cpu32memory512
##SBATCH --mail-type=END,FAIL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=<email address>    # Where to send mail
#SBATCH --ntasks=$num_threads_tot #Number of cores requested
#SBATCH --nodes=$num_nodes #Number of nodes
#SBATCH --ntasks-per-node=$num_threads_per_node #Number of threads per node 
#SBATCH --time=0:01:00             # Time limit hrs:min:sec
#SBATCH --output=slurmjob_%j.log     # Standard output and error log
date;hostname;pwd

module load intel-oneapi/2021.4.0

export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so # This depends on your mashine. Find path: >whereis libmpi.so 
export FOR_COARRAY_NUM_IMAGES=$num_nodes
export OMP_NUM_THREADS=$num_threads_per_node

time ../parallel_dot_caf_omp_test.x > parallel_dot_caf_omp_test.out

date

EOF

chmod 750 run.slurm
sbatch run.slurm

cd ..

