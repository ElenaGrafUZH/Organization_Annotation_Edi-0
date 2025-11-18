#!/bin/bash
#SBATCH --job-name=run_BLAST_TAIR10
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/10_BLAST"
TAIR10="/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_pep_20110103_representative_gene_model"
PROTEIN="${WORKDIR}/output/08_1_BUSCO/prep/Edi-0.proteins.longest.fasta"

#*-----Create Output directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Load module-----
module load BLAST+/2.15.0-gompi-2021a

#*-----Run BLAST-----
blastp -query ${PROTEIN} \
    -db ${TAIR10} \
    -num_threads ${SLURM_CPUS_PER_TASK} \
    -outfmt 6 -evalue 1e-5 -max_target_seqs 10 \
    -out "${OUTDIR}/blastp_output_TAIR10"

#*-----Select best hit per query-----
sort -k1,1 -k12,12g "${OUTDIR}/blastp_output_TAIR10" | sort -u -k1,1 --merge > "${OUTDIR}/blastp_output_TAIR10.besthits"


echo "BLAST and functional annotation with TAIR10 completed successfully at $(date)"
