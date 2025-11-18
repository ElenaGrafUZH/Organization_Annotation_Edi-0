#!/bin/bash
#SBATCH --job-name=run_BLAST
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course"
OUTDIR="${WORKDIR}/output/10_BLAST"
UNIPROTDB="/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa"
PROTEIN="${WORKDIR}/output/08_1_BUSCO/prep/Edi-0.proteins.longest.fasta"
GFF="${WORKDIR}/output/07_Final/UpdateFilter/Edi-0.filtered.genes.renamed.gff3"

MAKERBIN="$COURSEDIR/CDS_annotation/softwares/Maker_v3.01.03/src/bin"

#*-----Create Output directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Load module-----
module load BLAST+/2.15.0-gompi-2021a

#*-----Run BLAST-----
blastp -query ${PROTEIN} \
    -db ${UNIPROTDB} \
    -num_threads ${SLURM_CPUS_PER_TASK} \
    -outfmt 6 -evalue 1e-5 -max_target_seqs 10 \
    -out "${OUTDIR}/blastp_output"

#*-----Select best hit per query-----
sort -k1,1 -k12,12g "${OUTDIR}/blastp_output" | sort -u -k1,1 --merge > "${OUTDIR}/blastp_output.besthits"

#*-----Add functional annotation with MAKER-----
cp ${PROTEIN} ${OUTDIR}/maker_proteins.fasta.Uniprot
cp ${GFF} ${OUTDIR}/filtered.maker.gff3.Uniprot

$MAKERBIN/maker_functional_fasta ${UNIPROTDB} "${OUTDIR}/blastp_output.besthits" ${PROTEIN} > "${OUTDIR}/maker_proteins.fasta.Uniprot"
$MAKERBIN/maker_functional_gff ${UNIPROTDB} "${OUTDIR}/blastp_output" ${GFF} > "${OUTDIR}/filtered.maker.gff3.Uniprot.gff3"

echo "BLAST and functional annotation completed successfully at $(date)"
