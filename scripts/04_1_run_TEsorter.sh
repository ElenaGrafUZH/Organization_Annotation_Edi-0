#!/bin/bash
#SBATCH --job-name=run_TEsorter
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/04_TEsorter"
TELIB="${WORKDIR}/output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.TElib.fa"

INPUTCOPIA="${OUTDIR}/Copia_sequences.fa"
INPUTGYPSY="${OUTDIR}/Gypsy_sequences.fa"

CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"

#*-----Load Module-----
module load SeqKit/2.6.1

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Extract Copia & Gypsy sequences-----
echo "Extracting Copia and Gypsy sequences..."
seqkit grep -r -p "Copia" ${TELIB} > ${INPUTCOPIA}
seqkit grep -r -p "Gypsy" ${TELIB} > ${INPUTGYPSY}


#*-----Run TEsorter-----
echo "Running TEsorter for Copia..."
apptainer exec --bind ${WORKDIR} ${CONTAINER} TEsorter \
    ${INPUTCOPIA} \
    -db rexdb-plant \
    -pre Copia

echo "Running TEsorter for GYPSY..."
apptainer exec --bind ${WORKDIR} ${CONTAINER} TEsorter \
    ${INPUTGYPSY} \
    -db rexdb-plant \
    -pre Gypsy