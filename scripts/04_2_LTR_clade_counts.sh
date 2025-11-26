#!/bin/bash
#SBATCH --job-name=run_LTR_clade_counts
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"

#*-----Step 1: Build a mapping of TE base ID -> Superfamily -> Clade-----
# take the first column (TE id), strip anything after '#' to get base ID
# take column 3 as Superfamily and column 4 as Clade

cd "${WORKDIR}/output/04_TEsorter"
awk -F'\t' '!/^#/{split($1,a,"#"); te=a[1]; sf=$3; cl=$4; print te "\t" sf "\t" cl}' Copia.cls.tsv Gypsy.cls.tsv | sort -u > LTR_cls.map.tsv

#*-----Step 2: Prepare list of one TE id per annotated TE feature-----
cd "$WORKDIR"
awk 'BEGIN{FS=OFS="\t"}
{
  if (match($9, /Name=([^;]+)/, m)) {
    name=m[1]
    sub(/#.*/,"",name)         # drop anything after '#'
    print name
  }
}' output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.TEanno.gff3 \
| sort -u > output/04_TEsorter/teanno.ids

#*-----Step 3: Join TE annotation ids with the TEsorter clade mapping-----
cd "$WORKDIR/output/04_TEsorter"
join -t $'\t' -1 1 -2 1 \
  <(sort teanno.ids) \
  <(sort LTR_cls.map.tsv) \
  > teanno_with_clade.tsv

#*-----Step 4: Count totals per clade within each superfamily-----
awk -F'\t' '{ key=$2"\t"$3; c[key]++ } END{ for(k in c) print c[k]"\t"k }' teanno_with_clade.tsv \
| sort -k2,2 -k3,3 -nr \
> LTR_clade_counts.tsv

#*----- print header then table to stdout-----
column -t LTR_clade_counts.tsv | sed '1i Count  Superfamily  Clade'
