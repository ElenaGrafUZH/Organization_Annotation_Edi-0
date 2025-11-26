#!/bin/bash
#SBATCH --job-name=run_BUSCO
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/data/users/egraf/organization_annotation_course/logs/%x_%j.out
#SBATCH --error=/data/users/egraf/organization_annotation_course/logs/%x_%j.err


#*-----User-editable variables-----
WORKDIR="/data/users/${USER}/organization_annotation_course"
OUTDIR="${WORKDIR}/output/08_1_BUSCO/final"
prefix="Edi-0"

PROTEIN="${WORKDIR}/output/08_1_BUSCO/prep/${prefix}.proteins.longest.fasta"
TRANSCRIPT="${WORKDIR}/output/08_1_BUSCO/prep/${prefix}.transcripts.longest.fasta"

#*-----Create Ouput directory-----
mkdir -p "$OUTDIR"
cd "$OUTDIR"

#*-----load module-----
module load BUSCO/5.4.2-foss-2021a

#*-----run BUSCO-----
busco -i ${PROTEIN} -l brassicales_odb10 -o busco_protein_output -m proteins \
    --cpu ${SLURM_CPUS_PER_TASK} \
    --out_path "${OUTDIR}"
busco -i ${TRANSCRIPT} -l brassicales_odb10 -o busco_transcript_output -m transcriptome \
    --cpu ${SLURM_CPUS_PER_TASK} \
    --out_path "${OUTDIR}"

#*-----BUSCO summary files-----
PROTEIN_SUMMARY="${OUTDIR}/busco_protein_output/short_summary.specific.brassicales_odb10.busco_protein_output.txt"
TRANSCRIPT_SUMMARY="${OUTDIR}/busco_transcript_output/short_summary.specific.brassicales_odb10.busco_transcript_output.txt"

# Copy BUSCO summary files to output directory with proper names
echo "Copying BUSCO summary files..."
cp "${PROTEIN_SUMMARY}" "short_summary.specific.brassicales_odb10.proteins.txt"
cp "${TRANSCRIPT_SUMMARY}" "short_summary.specific.brassicales_odb10.transcripts.txt"

# Download the generate_plot.py script from GitLab (correct URL)
wget -O generate_plot.py "https://gitlab.com/ezlab/busco/-/raw/5.4.2/scripts/generate_plot.py"

# Check if download was successful
if [ ! -f "generate_plot.py" ]; then
    echo "Error: Failed to download generate_plot.py"
    exit 1
fi

#*-----generate BUSCO plot-----
python3 generate_plot.py -wd "${OUTDIR}"