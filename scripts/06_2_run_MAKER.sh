#!/bin/bash
#SBATCH --job-name=run_MAKER
#SBATCH --partition=pibu_el8 
#SBATCH --mem=200G
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
OUTDIR="${WORKDIR}/output/06_MAKER"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

#*-----Load moduels-----
module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Run MAKER-----
mpiexec --oversubscribe -n 50 \
    apptainer exec --bind $SCRATCH:/TMP --bind ${WORKDIR} --bind ${COURSEDIR} --bind ${AUGUSTUS_CONFIG_PATH} --bind ${REPEATMASKER_DIR} \
    ${COURSEDIR}/containers/MAKER_3.01.03.sif \
    maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl