#!/bin/bash

#SBATCH --job-name=run_circos_TE_Gene_Density
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:45:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err


#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/03_Circos"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

#*-----Variables and File Setup------------------------------------------------*

# 1. Genome assembly FASTA file (for indexing and FAI path)
INPUT_FASTA="${WORKDIR}/data/assemblies/hifiasm_Edi-0.fasta"

# 2. Whole-genome TE annotation GFF3 file (Input 1 for R script)
TE_GFF_FILE="${WORKDIR}/output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.TEanno.gff3"
# 3. Whole-genome Gene annotation GFF3 file (Input 2 for R script)
GENE_GFF_FILE="${WORKDIR}/output/07_Final/UpdateFilter/Edi-0.filtered.genes.renamed.gff3" 

# 4. FAI Index file (Input 3 for R script)
FAIX_FILE="${INPUT_FASTA}.fai"

# 5. Output Directory (Argument 4 for R script)
OUTDIR="${WORKDIR}/output/03_Circos"


#*-----Prerequisites and Directory Setup---------------------------------------*
mkdir -p "$OUTDIR"

#*-----Load Modules and Run R Script-------------------------------------------*
echo "Loading required R module..."
module add BioPerl/1.7.8-GCCcore-10.3.0 
module add R/4.3.2-foss-2021a
module add R-bundle-CRAN/2023.11-foss-2021a
module add R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

R_SCRIPT="${WORKDIR}/scripts/03_4_circos_te_density.R" 
echo "Executing R plotting script: $R_SCRIPT"

# Run the R script, passing all four required files and the output directory
Rscript "$R_SCRIPT" \
    "$TE_GFF_FILE" \
    "$GENE_GFF_FILE" \
    "$FAIX_FILE" \
    "$OUTDIR"

echo "R script finished. Results should be in $OUTDIR."