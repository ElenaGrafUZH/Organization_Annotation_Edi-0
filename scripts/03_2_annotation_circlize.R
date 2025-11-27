# Load the circlize package
library(circlize)
library(tidyverse)
library(ComplexHeatmap)
library(Cairo)

# Load the TE annotation GFF3 file
args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]

gff_file <- file.path(wd,"/output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.TEanno.gff3")
gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Check the superfamilies present in the GFF3 file, and their counts
gff_data$V3 %>% table()


# custom ideogram data
## To make the ideogram data, you need to know the lengths of the scaffolds.
## There is an index file that has the lengths of the scaffolds, the `.fai` file.
## To generate this file you need to run the following command in bash:
## samtools faidx assembly.fasta
## This will generate a file named assembly.fasta.fai
## You can then read this file in R and prepare the custom ideogram data
custom_ideogram <- read.table("data/assemblies/hifiasm_Edi-0.fasta.fai", header = FALSE, stringsAsFactors = FALSE)
custom_ideogram$chr <- custom_ideogram$V1
custom_ideogram$start <- 1
custom_ideogram$end <- custom_ideogram$V2
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
sum(custom_ideogram$end[1:20])
total_scaffold_length <- sum(custom_ideogram$end[1:12])
assembly_length <- 149560242
coverage <- total_scaffold_length / assembly_length
coverage

# Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
custom_ideogram <- custom_ideogram[1:12, ]

# Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
    filtered_data <- gff_data[gff_data$V3 == superfamily, ] %>%
        as.data.frame() %>%
        mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
        select(chrom, start, end, strand) %>%
        filter(chrom %in% custom_ideogram$chr)
    return(filtered_data)
}

CairoPNG(file.path(wd,"/output/03_Circos/03-TE_density.png"), width = 3000, height = 3000, res=300)
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram, plotType = c("axis", "labels"), labels.cex = 0.5 )

# Plot te density
circos.genomicDensity(filter_superfamily(gff_data, "Gypsy_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "darkgreen", track.height = 0.1, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "Copia_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "darkred", track.height = 0.1, window.size = 1e5)
#**ME: add most abundant TE superfamilies**#
circos.genomicDensity(filter_superfamily(gff_data, "LTR_retrotransposon", custom_ideogram), count_by = "number", col = "purple", track.height = 0.1, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "Mutator_TIR_transposon", custom_ideogram), count_by = "number", col = "blue", track.height = 0.1, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "L1_LINE_retrotransposon", custom_ideogram), count_by = "number", col = "pink", track.height = 0.1, window.size = 1e5)

circos.clear()

lgd <- Legend(
    title = "Superfamily", at = c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon", "LTR_retrotransposon", "Mutator_TIR_transposon", "L1_LINE_retrotransposon"),
    legend_gp = gpar(fill = c("darkgreen", "darkred", "purple", "blue", "pink")),
    labels_gp = gpar(fontsize = 12),
)
draw(lgd, x = unit(0.5, "cm"), y = unit(0.5, "cm"), just = c("left", "bottom"))

dev.off()


# Now plot all your most abundant TE superfamilies in one plot




