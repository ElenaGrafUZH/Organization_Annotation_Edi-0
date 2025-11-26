#!/bin/bash
#SBATCH --job-name=process_pangenome
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


mkdir -p "$GENESPACEDIR/plots"

#*-----Load modules-----
module load BioPerl/1.7.8-GCCcore-10.3.0
module load R/4.3.2-foss-2021a
module load R-bundle-CRAN/2023.11-foss-2021a
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

#*-----Run R Script-----
Rscript scripts/11_3_process_pangenome.R ${GENESPACEDIR}