#!/bin/bash -l
# ===========================================
# Slurm Header
# ===========================================
#SBATCH -J %JOBNAME
#SBATCH --partition=%QUEUE
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=%NCPUs
#SBATCH --nodes=1
#SBATCH --get-user-env
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.error
#SBATCH --time=168:00:00
#SBATCH --nodelist=%NODE
#SBATCH --mem-per-cpu=%MEMpCPU
# ===========================================
. startjob      # Do not remove this line!
# ===========================================
# Your Commands Go Here 
# ===========================================
echo "`pwd`" > localFolder.out
echo "`ls -l`" >> localFolder.out
# The initial srun will trigger the SLURM prologue on the compute nodes.
NPROCS=`srun --nodes=${SLURM_NNODES} bash -c 'hostname' |wc -l`
echo NPROCS=$NPROCS
module list
module purge

%RUN_COMMAND 

# ===========================================
# End Commands
# ===========================================
. endjob        # Do not remove this line!
#---------------------------------------------