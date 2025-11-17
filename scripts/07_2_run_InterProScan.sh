#!/bin/bash
#SBATCH --job-name=run_InterProScan
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/07_Final/InterProScan"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
protein="/data/users/egraf/organization_annotation_course/output/07_Final/hifiasm_Edi-0.all.maker.proteins.fasta.renamed.fasta"
IPRDATA="${COURSEDIR}/data/interproscan-5.70-102.0/data"

CONTAINER="$COURSEDIR/containers/interproscan_latest.sif"

prefix="Edi-0"

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

apptainer exec --bind ${IPRDATA}:/opt/interproscan/data --bind ${WORKDIR} --bind ${COURSEDIR} --bind ${SCRATCH}:/temp \
    ${CONTAINER} \
    /opt/interproscan/interproscan.sh \
    -appl pfam --disable-precalc -f TSV \
    --goterms --iprlookup --seqtype p \
    -i ${protein} -o "${prefix}_output.iprscan"
