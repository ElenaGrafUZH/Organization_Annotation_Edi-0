#!/bin/bash
#SBATCH --job-name=extract_mRNA
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/07_Final/FilteredFASTA"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
FILTERED_GFF="${WORKDIR}/output/07_Final/UpdateFilter/Edi-0.filtered.genes.renamed.gff3"



prefix="Edi-0"
gff="${WORKDIR}/output/07_Final/hifiasm_Edi-0.all.maker.noseq.gff.renamed.gff"
transcript="${WORKDIR}/output/07_Final/hifiasm_Edi-0.all.maker.transcripts.fasta.renamed.fasta"
protein="${WORKDIR}/output/07_Final/hifiasm_Edi-0.all.maker.proteins.fasta.renamed.fasta"


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Load Modules-----
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0

#*-----Extract mRNA IDs from filtered GFF-----
echo "Extracting mRNA IDs..."
grep -P "\tmRNA\t" ${FILTERED_GFF} | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt

#*-----Filter transcript and protein FASTA files-----
echo "Filtering FASTA files..."
faSomeRecords ${transcript} list.txt "${OUTDIR}/${prefix}.transcripts.renamed.filtered.fasta"
faSomeRecords ${protein} list.txt "${OUTDIR}/${prefix}.protein.renamed.filtered.fasta"

echo "Done! Filtered FASTA files saved in:"
echo "  ${OUTDIR}/${prefix}.transcripts.renamed.filtered.fasta"
echo "  ${OUTDIR}/${prefix}.proteins.renamed.filtered.fasta"