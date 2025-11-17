#!/bin/bash
#SBATCH --job-name=create_controll_files
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=1-00:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/03_MAKER/control_files"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

INPUT_LTR="${WORKDIR}/EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.raw/hifiasm_Edi-0.fasta.mod.LTR.raw.fa"


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Create Control Files-----
apptainer exec --bind ${WORKDIR} ${CONTAINER} maker -CTL