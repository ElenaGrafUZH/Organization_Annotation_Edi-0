#!/bin/bash
#SBATCH --job-name=run_AGAT
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err


#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/08_2_AGAT"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
GFF="${WORKDIR}/output/07_Final/UpdateFilter/Edi-0.filtered.genes.renamed.gff3"

CONTAINER="$COURSEDIR/containers/agat_1.5.1--pl5321hdfd78af_0.sif"



#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Run AGAT-----
apptainer exec --bind ${WORKDIR} --bind ${COURSEDIR} ${CONTAINER} \
    agat_sp_statistics.pl -i "${GFF}" -o annotation.stat


