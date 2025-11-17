#!/bin/bash
#SBATCH --job-name=renaming_genes_transcripts
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/07_Final"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
prefix="Edi-0"

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Copying important files-----
protein="/data/users/egraf/organization_annotation_course/output/06_MAKER/PrepOutput/hifiasm_Edi-0.all.maker.proteins.fasta"
transcript="/data/users/egraf/organization_annotation_course/output/06_MAKER/PrepOutput/hifiasm_Edi-0.all.maker.transcripts.fasta"
gff="/data/users/egraf/organization_annotation_course/output/06_MAKER/PrepOutput/hifiasm_Edi-0.all.maker.noseq.gff"

cp $gff ${OUTDIR}/$(basename ${gff}).renamed.gff
cp $protein ${OUTDIR}/$(basename ${protein}).renamed.fasta
cp $transcript ${OUTDIR}/$(basename ${transcript}).renamed.fasta

#*-----Define filenames in OUTDIR-----
gff_renamed=$(basename $gff).renamed.gff
protein_renamed=$(basename $protein).renamed.fasta
transcript_renamed=$(basename $transcript).renamed.fasta

#*-----Mapping gene models-----
$MAKERBIN/maker_map_ids --prefix $prefix --justify 7 ${gff_renamed} > id.map
$MAKERBIN/map_gff_ids id.map ${gff_renamed}
$MAKERBIN/map_fasta_ids id.map ${protein_renamed}
$MAKERBIN/map_fasta_ids id.map ${transcript_renamed}