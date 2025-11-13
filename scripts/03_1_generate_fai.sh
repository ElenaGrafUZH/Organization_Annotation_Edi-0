#!/bin/bash
#SBATCH --job-name=generate_fai 
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=8
#SBATCH --mem=200G
#SBATCH --time=1-00:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

INPUT_FASTA=$WORKDIR/data/assemblies/hifiasm_Edi-0.fasta

#*-----Create .fai file-----
apptainer exec --bind ${OUTDIR} --bind ${WORKDIR} ${CONTAINER} samtools faidx ${INPUT_FASTA}