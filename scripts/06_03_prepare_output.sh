#!/bin/bash
#SBATCH --job-name=prepare_output
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=1-00:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/06_MAKER/PrepOutput"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"


#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

$MAKERBIN/gff3_merge -s -d /data/users/egraf/organization_annotation_course/output/06_MAKER/hifiasm_Edi-0.maker.output/hifiasm_Edi-0_master_datastore_index.log > hifiasm_Edi-0.all.maker.gff
$MAKERBIN/gff3_merge -n -s -d /data/users/egraf/organization_annotation_course/output/06_MAKER/hifiasm_Edi-0.maker.output/hifiasm_Edi-0_master_datastore_index.log > hifiasm_Edi-0.all.maker.noseq.gff
$MAKERBIN/fasta_merge -d /data/users/egraf/organization_annotation_course/output/06_MAKER/hifiasm_Edi-0.maker.output/hifiasm_Edi-0_master_datastore_index.log -o hifiasm_Edi-0