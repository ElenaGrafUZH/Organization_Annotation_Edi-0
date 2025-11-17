#!/bin/bash
#SBATCH --job-name=update_filter_gff
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/07_Final/UpdateFilter"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"


CONTAINER="$COURSEDIR/containers/interproscan_latest.sif"

prefix="Edi-0"
gff="${WORKDIR}/output/07_Final/hifiasm_Edi-0.all.maker.noseq.gff.renamed.gff"
iprscan="${WORKDIR}/output/07_Final/InterProScan/Edi-0_output.iprscan"

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Update GFF with InterProScan Results-----
echo "Updating GFF with InterProScan results..."
$MAKERBIN/ipr_update_gff ${gff} ${iprscan} > "${prefix}.maker.iprscan.gff"

#*-----Calculate AED Values-----
echo "Calculating AED values..."
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 "${prefix}.maker.iprscan.gff" > "${prefix}.maker.AED.txt"

#*-----Filter the GFF File for Quality-----
echo "Filtering by AED and Pfam support..."
perl $MAKERBIN/quality_filter.pl -s "${prefix}.maker.iprscan.gff" > "${prefix}.maker.iprscan_quality_filtered.gff"
# In the above command: -s Prints transcripts with an AED <1 and/or Pfam domain if in gff3

#*-----Filter the GFF File for Gene Features-----
# We only want to keep gene features in the third column of the gff file
echo "Extracting gene features..."
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" \
    "${prefix}.maker.iprscan_quality_filtered.gff" > "${prefix}.filtered.genes.renamed.gff3"
# Check
cut -f3 "${prefix}.filtered.genes.renamed.gff3" | sort | uniq -c > "${prefix}.features_list.txt"

echo "Done! Filtered annotation saved in:"
echo "  ${OUTDIR}/${prefix}.filtered.genes.renamed.gff3"