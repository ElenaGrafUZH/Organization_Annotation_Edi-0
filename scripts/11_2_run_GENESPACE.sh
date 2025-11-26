#!/bin/bash
#SBATCH --job-name=run_GENESPACE
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
GENESPACEDIR="${WORKDIR}/output/11_GENESPACE"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
CONTAINER="${COURSEDIR}/containers/genespace_latest.sif"

#*-----Run Genespace-----
apptainer exec \
    --bind ${COURSEDIR} \
    --bind ${WORKDIR} \
    --bind $SCRATCH:/temp \
    ${CONTAINER} Rscript scripts/genespace.R ${GENESPACEDIR}