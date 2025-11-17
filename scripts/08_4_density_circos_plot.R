library(circlize)
library(tidyverse)
library(ComplexHeatmap)
library(Cairo)

#-------------------------------------------------
# Load inputs
#-------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]

te_gff <-  file.path(wd, "/output/01_EDTA_annotation/hifiasm_Edi-0.fasta.mod.EDTA.TEanno.gff3")
gene_gff <- file.path(wd, "/output/07_Final/UpdateFilter/Edi-0.filtered.genes.renamed.gff3")
window_size <- 100000   # 100 kb
output_file <-  file.path(wd, "/output/08_2_AGAT/plots/Edi-0_gene_TE_circos_option1.png")

genes <- read.table(gene_gff, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
tes   <- read.table(te_gff,   header = FALSE, sep = "\t", stringsAsFactors = FALSE)

colnames(genes) <- c("seqid","source","type","start","end","score","strand","phase","attributes")
colnames(tes)   <- c("seqid","source","type","start","end","score","strand","phase","attributes")

genes <- genes[genes$type == "gene",]
tes   <- tes


#-------------------------------------------------
# 1. Select IMPORTANT scaffolds only
#-------------------------------------------------

# Compute scaffold lengths
scaffold_lengths <- bind_rows(
  genes %>% group_by(seqid) %>% summarise(max_end = max(end)),
  tes   %>% group_by(seqid) %>% summarise(max_end = max(end))
) %>%
  group_by(seqid) %>%
  summarise(length = max(max_end)) %>%
  arrange(desc(length))

# -----------------------
# Choose filtering method:
# -----------------------

TOP_N <- 10           # keep the largest 10 scaffolds
MIN_LENGTH <- 2e6     # or: keep only scaffolds > 2 Mb

important_scaffolds <- scaffold_lengths %>%
  filter(length >= MIN_LENGTH) %>%
  slice_head(n = TOP_N) %>%
  pull(seqid)

cat("Selected scaffolds:\n")
print(important_scaffolds)


# Filter feature tables to these scaffolds
genes_filt <- genes %>% filter(seqid %in% important_scaffolds)
tes_filt   <- tes   %>% filter(seqid %in% important_scaffolds)


#-------------------------------------------------
# 2. Create windows only for these scaffolds
#-------------------------------------------------

window_list <- list()

for (chr in important_scaffolds) {
  chr_len <- max(c(genes_filt$end[genes_filt$seqid == chr],
                   tes_filt$end[tes_filt$seqid == chr]))
  
  bins <- seq(1, chr_len, by = window_size)
  
  window_list[[chr]] <- data.frame(
    chr   = chr,
    start = bins,
    end   = pmin(bins + window_size - 1, chr_len)
  )
}

windows <- bind_rows(window_list)


#-------------------------------------------------
# 3. Count gene & TE density
#-------------------------------------------------

count_overlap <- function(features, windows){
  sapply(seq_len(nrow(windows)), function(i){
    sum(features$seqid == windows$chr[i] &
          features$start <= windows$end[i] &
          features$end   >= windows$start[i])
  })
}

windows$gene_density <- count_overlap(genes_filt, windows)
windows$te_density   <- count_overlap(tes_filt, windows)

windows$gene_density_scaled <- windows$gene_density / max(windows$gene_density)
windows$te_density_scaled   <- windows$te_density   / max(windows$te_density)


#-------------------------------------------------
# 4. Circos plot
#-------------------------------------------------

chrom_info <- windows %>%
  group_by(chr) %>%
  summarise(start = min(start), end = max(end)) %>%
  as.data.frame()

CairoPNG(output_file, width = 2000, height = 2000, res = 200)


circos.clear()
circos.par(
  start.degree = 90,
  gap.after = rep(1, nrow(chrom_info)),  # safe for <20 scaffolds
  track.height = 0.1,
  cell.padding = c(0,0,0,0)
)

circos.initialize(factors = chrom_info$chr,
                  xlim = chrom_info[,c("start","end")])

# TE density track
circos.trackPlotRegion(
  factors = windows$chr, ylim = c(0,1), track.height = 0.1,
  bg.border = NA,
  panel.fun = function(region, value, ...) {
    chr <- CELL_META$sector.index
    sel <- windows$chr == chr
    circos.lines(windows$start[sel], windows$te_density_scaled[sel],
                 col = "red", lwd = 2)
  }
)

# Gene density track
circos.trackPlotRegion(
  factors = windows$chr, ylim = c(0,1), track.height = 0.1,
  bg.border = NA,
  panel.fun = function(region, value, ...) {
    chr <- CELL_META$sector.index
    sel <- windows$chr == chr
    circos.lines(windows$start[sel], windows$gene_density_scaled[sel],
                 col = "blue", lwd = 2)
  }
)

# Label scaffolds
circos.trackPlotRegion(track.index = 1, bg.border = NA,
                       panel.fun = function(x, y){
                         circos.text(CELL_META$xcenter, CELL_META$ycenter + 0.5,
                                     CELL_META$sector.index, cex = 0.7,
                                     facing = "bending.inside")
                       }
)
lgd <- Legend(
  title = "Density Tracks",
  at = c("TE density", "Gene density"),
  legend_gp = gpar(
    fill = c("red", "blue")
  )
)

draw(
  lgd,
  x = unit(15, "cm"),
  y = unit(15, "cm"),
  just = c("center")
)
dev.off()

cat("Circos plot saved to:", output_file, "\n")


# option 2
genes <- genes %>% 
  filter(type == "gene") %>%
  transmute(chr = seqid, start, end)

tes_all <- tes %>% 
  transmute(chr = seqid, start, end, class = type)


CairoPNG(file.path(wd, "/output/08_2_AGAT/plots/Edi-0_gene_TE_circos_option2.png"), width = 2000, height = 2000, res = 200)

#---------------------------------------------
# 1. FILTER IMPORTANT SCAFFOLDS (optional)
#---------------------------------------------
custom_ideogram <- chrom_info %>%
  transmute(chr, start = start, end = end)

# GAP STYLE
gaps <- c(rep(1, nrow(custom_ideogram) - 1), 5)

circos.clear()
circos.par(
  start.degree = 90,
  gap.after = gaps,
  track.margin = c(0, 0)
)

#---------------------------------------------
# 2. INIT CIRCOS (your style)
#---------------------------------------------
circos.genomicInitialize(
  custom_ideogram,
  plotType = c("axis", "labels"),
  labels.cex = 0.5
)

#---------------------------------------------
# 3. TE DENSITY (all TEs, or choose a class)
#---------------------------------------------
circos.genomicDensity(
  tes_all,
  col = "darkgreen",
  count_by = "number",
  window.size = 1e5,
  track.height = 0.1
)

#---------------------------------------------
# 4. GENE DENSITY
#---------------------------------------------
circos.genomicDensity(
  genes,
  col = "darkred",
  count_by = "number",
  window.size = 1e5,
  track.height = 0.1
)

#---------------------------------------------
# 5. LEGEND — SAME STYLE AS BEFORE
#---------------------------------------------
lgd <- Legend(
  title = "Density Tracks",
  at = c("TE density", "Gene density"),
  legend_gp = gpar(
    fill = c("darkgreen", "darkred")
  )
)

draw(lgd, x = unit(15, "cm"), y = unit(15, "cm"), just = "center")

dev.off()

