#!/bin/bash
#SBATCH --job-name=run_EDTA 
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=2-00:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/01_EDTA_annotation"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif"

INPUT_FASTA=$WORKDIR/data/assemblies/hifiasm_Edi-0.fasta


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"



#*-----Run EDTA-----
echo "Running EDTA..."
apptainer exec --bind ${WORKDIR} ${CONTAINER} EDTA.pl \
    --genome ${INPUT_FASTA} \
    --species others \
    --step all \
    --sensitive 1 \
    --cds "/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated" \
    --anno 1 \
    --threads ${SLURM_CPUS_PER_TASK}
