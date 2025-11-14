#!/bin/bash
#SBATCH --job-name=run_perl
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err

#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/05_perl"
PERLSCRIPT="${WORKDIR}/scripts/parseRM.pl"
INPUTFILE="${WORKDIR}/output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.anno/hifiasm_Edi-0.fasta.mod.out"

module load BioPerl/1.7.8-GCCcore-10.3.0

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----Create Control Files-----
perl ${PERLSCRIPT} -i ${INPUTFILE} -l 50,1 -v