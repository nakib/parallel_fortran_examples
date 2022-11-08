#!/bin/bash

workdir="./omp_1x36"
mkdir $workdir
cd $workdir

let num_nodes=1
let num_threads_per_node=36
let num_threads_tot=num_nodes*num_threads_per_node
echo "Number of OMP threads: " $num_threads_per_node

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

export OMP_NUM_THREADS=$num_threads_per_node

time ../parallel_dot_omp_test.x > parallel_dot_omp_test.out

date

EOF

chmod 750 run.slurm
sbatch run.slurm

cd ..

