#!/bin/bash
#SBATCH --job-name=run_TEsorter
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=2-00:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/02_LTR_RT"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"

INPUT_LTR="${WORKDIR}/EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.raw/hifiasm_Edi-0.fasta.mod.LTR.raw.fa"


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"


#*-----Run TEsorter-----
echo "Running TEsorter..."
apptainer exec --bind ${WORKDIR} ${CONTAINER} TEsorter \
    ${INPUT_LTR} \
    -db rexdb-plant 
