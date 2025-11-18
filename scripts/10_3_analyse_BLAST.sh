#!/bin/bash
#SBATCH --job-name=analyse_BLAST
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/10_BLAST/plots"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
OUT="${WORKDIR}/output/10_BLAST/plots/annotation_summary.txt"
UNIPROTDB="${COURSEDIR}/data/uniprot/uniprot_viridiplantae_reviewed.fa"
BESTHITS="${WORKDIR}/output/10_BLAST/blastp_output.besthits"
LONGESTFASTA="${WORKDIR}/output/08_1_BUSCO/prep/Edi-0.proteins.longest.fasta"


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#* map UniProt ID to description
grep ">" ${UNIPROTDB} \
    | sed 's/^>//' \
    | awk '{id=$1; $1=""; sub(/^ /,""); print id"\t"$0}' \
    > uniprot_map.tsv



#* join best hits with description
join -1 2 -2 1 \
    <(sort -k2,2 ${BESTHITS}) \
    <(sort -k1,1 uniprot_map.tsv) \
    > query_with_desc.tsv



# Total queries with any UniProt hit
TOTAL=$(wc -l < query_with_desc.tsv)

# Uncharacterized queries
UNCHAR=$(grep -i -E "uncharacterized|hypothetical|putative|unknown" query_with_desc.tsv | wc -l)

# Well-annotated = total - uncharacterized
WELL=$((TOTAL - UNCHAR))

echo -e "Total_queries_with_hits\t$TOTAL" > annotation_summary.txt
echo -e "Uncharacterized_hits\t$UNCHAR" >> annotation_summary.txt
echo -e "Well_annotated_hits\t$WELL" >> annotation_summary.txt

#* Length bias test
# get query Ids 
#with uniprot hits
cut -f1 ${BESTHITS} | sort -u > with_hits.txt
# without hits
grep ">" ${LONGESTFASTA} \
    | sed 's/>//' \
    | sort -u > all_ids.txt

comm -23 all_ids.txt with_hits.txt > without_hits.txt

#extract fasta sequences
#with hits
awk 'BEGIN{
    while ((getline < "with_hits.txt") > 0) ids[$1]=1
    }
    (/^>/){
    header = substr($0,2)
    print_flag = (header in ids)
    }
    print_flag' \
    ${LONGESTFASTA} \
    > proteins_with_hits.fa

#without hits
awk 'BEGIN{
    while ((getline < "without_hits.txt") > 0) ids[$1]=1
    }
    (/^>/){
    header = substr($0,2)
    print_flag = (header in ids)
    }
    print_flag' \
    ${LONGESTFASTA} \
    > proteins_without_hits.fa


#compute protein lengths
#with hits
awk '
    /^>/ { if (len>0) print len; len=0; next }
    { len += length($0) }
    END { if (len>0) print len }
    ' proteins_with_hits.fa > len_with.txt

#without hits
awk '
    /^>/ { if (len>0) print len; len=0; next }
    { len += length($0) }
    END { if (len>0) print len }
    ' proteins_without_hits.fa > len_without.txt


#summary stats
echo "WITH HITS:"
sort -n len_with.txt | awk '
    { a[NR]=$1; sum+=$1 }
    END {
        if (NR>0){
            median = (NR%2 ? a[(NR+1)/2] : (a[NR/2] + a[NR/2+1])/2)
            printf "Count: %d\nMean: %.2f\nMedian: %.2f\n", NR, sum/NR, median
        }
    }'


echo "WITHOUT HITS:"
sort -n len_without.txt | awk '
    { a[NR]=$1; sum+=$1 }
    END {
        if (NR>0){
            median = (NR%2 ? a[(NR+1)/2] : (a[NR/2] + a[NR/2+1])/2)
            printf "Count: %d\nMean: %.2f\nMedian: %.2f\n", NR, sum/NR, median
        }
    }'

