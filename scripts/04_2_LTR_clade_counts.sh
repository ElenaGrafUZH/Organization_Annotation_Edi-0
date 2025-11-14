
WORKDIR="/data/users/${USER}/organization_annotation_course"

# 1
cd "${WORKDIR}/output/04_TEsorter"
awk -F'\t' '!/^#/{split($1,a,"#"); te=a[1];sf=$3; cl=$4;print te "\t" sf "\t" cl}' Copia.cls.tsv Gypsy.cls.tsv | sort -u > LTR_cls.map.tsv

#2
cd "$WORKDIR"

# Get one ID per annotated TE feature.
# Keeps rows whose type looks like LTR retrotransposons (adjust the pattern if needed).
awk 'BEGIN{FS=OFS="\t"}
 {
  if (match($9, /Name=([^;]+)/, m)) {
    name=m[1]
    sub(/#.*/,"",name)         # drop anything after '#'
    print name
  }
}' output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.TEanno.gff3 \
| sort -u > output/04_TEsorter/teanno.ids

#3
cd "$WORKDIR/output/04_TEsorter"

# Left join by TE id base; keep only those that have a TEsorter clade
join -t $'\t' -1 1 -2 1 \
  <(sort teanno.ids) \
  <(sort LTR_cls.map.tsv) \
  > teanno_with_clade.tsv
# Columns: TE_id_base \t Superfamily \t Clade

#4
cd "$WORKDIR/output/04_TEsorter"
Totals per clade within each superfamily
awk -F'\t' '{key=$2"\t"$3; c[key]++} END{for(k in c) print c[k]"\t"k}' teanno_with_clade.tsv \
| sort -k2,2 -k3,3 -nr \
> LTR_clade_counts.tsv

column -t LTR_clade_counts.tsv | sed '1i Count  Superfamily  Clade'
