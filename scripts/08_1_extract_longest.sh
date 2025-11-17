#!/bin/bash
#SBATCH --job-name=extract_longest
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
prefix="Edi-0"
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/08_1_BUSCO/prep"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

OUT="${OUTDIR}/${prefix}.proteins.longest.fasta"
OUTTRANSCRIPT="${OUTDIR}/${prefix}.transcripts.longest.fasta"


transcript="${WORKDIR}/output/07_Final/FilteredFASTA/Edi-0.transcripts.renamed.filtered.fasta"
protein="${WORKDIR}/output/07_Final/FilteredFASTA/Edi-0.protein.renamed.filtered.fasta"


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Load Modules-----
module load SeqKit/2.6.1
module load SAMtools/1.13-GCC-10.3.0

#*-----Proteins-----
echo "== Proteins =="
echo "Input: ${protein}"
#*-----Get IDs and lengths-----
seqkit fx2tab -nl "$protein" | awk '{split($1,a," "); print a[1]"\t"$NF}' > ${OUTDIR}/protein_lengths.txt

#*-----Keep longest isoform per genes-----

awk -F'\t' '{
  id=$1; len=$2;
  split(id,a,"-R"); gene=a[1];
  if (len > max[gene]) {max[gene]=len; keep[gene]=id}
} END {
  for (g in keep) print keep[g]
}' ${OUTDIR}/protein_lengths.txt > ${OUTDIR}/protein_longest_ids.txt

echo "Longest IDs (proteins): $(wc -l < protein_longest_ids.txt)"

# index the fasta (creates .fai file)
samtools faidx "${protein}"

# start with an empty output file
> "${OUT}"

# extract one sequence at a time
while read -r id; do
    samtools faidx "${protein}" "$id" >> "${OUT}"
done < "${OUTDIR}/protein_longest_ids.txt"

echo "Wrote: ${OUT}  (sequences: $(grep -c '^>' "${OUT}"))"


#*-----Transcripts-----
echo "== Transcripts =="
echo "Input: ${transcript}"
#*-----Get IDs and lengths-----
seqkit fx2tab -nl "$transcript" | awk '{split($1,a," "); print a[1]"\t"$NF}' > ${OUTDIR}/transcript_lengths.txt

#*-----Keep longest isoform per genes-----

awk -F'\t' '{
  id=$1; len=$2;
  split(id,a,"-R"); gene=a[1];
  if (len > max[gene]) {max[gene]=len; keep[gene]=id}
} END {
  for (g in keep) print keep[g]
}' ${OUTDIR}/transcript_lengths.txt > ${OUTDIR}/transcript_longest_ids.txt

echo "Longest IDs (transcripts): $(wc -l < transcript_longest_ids.txt)"
# index the fasta (creates .fai file)
samtools faidx "${transcript}"

# start with an empty output file
> "${OUTTRANSCRIPT}"

# extract one sequence at a time
while read -r id; do
    samtools faidx "${transcript}" "$id" >> "${OUTTRANSCRIPT}"
done < "${OUTDIR}/transcript_longest_ids.txt"

echo "Wrote: ${OUTTRANSCRIPT}  (sequences: $(grep -c '^>' "${OUTTRANSCRIPT}"))"
echo "All done."