#!/bin/bash
#SBATCH --job-name=prep_GENESPACE
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/11_GENESPACE"
COURSDIR="/data/courses/assembly-annotation-course/CDS_annotation/data"

EDI_PROTEIN="${WORKDIR}/output/08_1_BUSCO/prep/Edi-0.proteins.longest.fasta"
EDI_GFF="${WORKDIR}/output/07_Final/UpdateFilter/Edi-0.filtered.genes.renamed.gff3"

ARE_PROTEIN="${COURSDIR}/Lian_et_al/protein/selected/Are-6.protein.faa"
ARE_GFF="${COURSDIR}/Lian_et_al/gene_gff/selected/Are-6.EVM.v3.5.ann.protein_coding_genes.gff"

ETNA_PROTEIN="${COURSDIR}/Lian_et_al/protein/selected/Etna-2.protein.faa"
ETNA_GFF="${COURSDIR}/Lian_et_al/gene_gff/selected/Etna-2.EVM.v3.5.ann.protein_coding_genes.gff"

ICE_PROTEIN="${COURSDIR}/Lian_et_al/protein/selected/Ice-1.protein.faa"
ICE_GFF="${COURSDIR}/Lian_et_al/gene_gff/selected/Ice-1.EVM.v3.5.ann.protein_coding_genes.gff"

TAIR10="${COURSDIR}/TAIR10_pep_20110103_representative_gene_model"
TAIR10_BED="${COURSDIR}/TAIR10.bed"


#*-----Create Output directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"
mkdir -p "$OUTDIR/peptide"
mkdir -p "$OUTDIR/bed"

#*-----Gene-to-BED conversion-----

# accession display names
ACCESSIONS=("Edi_0" "Are_6" "Etna_2" "Ice_1")

# variable-safe prefixes
ACCESSION_PREFIXES=("EDI" "ARE" "ETNA" "ICE")

for i in "${!ACCESSIONS[@]}"; do
    ACC="${ACCESSIONS[$i]}"             
    PREFIX="${ACCESSION_PREFIXES[$i]}"  

    # Indirect variable lookup using the underscore-safe variable names
    GFF_VAR="${PREFIX}_GFF"
    GFF=${!GFF_VAR}

    echo "Processing ${ACC}..."
    grep -P "\tgene\t" "$GFF" > "${ACC}_temp_genes.gff3"
    awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1,$4-1,$5,b[2]}' \
        "${ACC}_temp_genes.gff3" > "bed/${ACC}.bed"
    echo "Done for bed/${ACC}.bed"
done


#*-----copy fa files-----
#change FASTA headers to match MAKER
sed -E 's/-R[A-Z]+$//' "${EDI_PROTEIN}" > peptide/Edi_0.fa

cp ${ARE_PROTEIN} peptide/Are_6.fa
cp ${ETNA_PROTEIN} peptide/Etna_2.fa
cp ${ICE_PROTEIN} peptide/Ice_1.fa


#*-----copy TAIR files-----
#change FASTA headers to match MAKER
sed -E '/^>/ s/\|.*//; s/[[:space:]]+$//' "${TAIR10}" > peptide/TAIR10.fa

cp ${TAIR10_BED} bed/TAIR10.bed
