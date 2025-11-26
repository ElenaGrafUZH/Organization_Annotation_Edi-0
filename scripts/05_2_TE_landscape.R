library(reshape2)
# library(hrbrthemes)
library(tidyverse)
library(data.table)
library(viridis)


# get data from parameter
args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]

data <- file.path(wd, "/output/05_perl/hifiasm_Edi-0.fasta.mod.out.landscape.Div.Rname.tab")

rep_table <- fread(data, header = FALSE, sep = "\t")
rep_table %>% head()
# How does the data look like?

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table %>% filter(Rfam != "unknown")
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

table(rep_table$fam)
# How many elements are there in each Superfamily?

rep_table.m <- melt(rep_table)

rep_table.m <- rep_table.m[-c(which(rep_table.m$variable == 1)), ] # remove the peak at 1, as the library sequences are copies in the genome, they inflate this low divergence peak

# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", "DNA/DNA","DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/hAT-Tip100", "DNA/MULE-MuDR", "DNA/PIF-Harbinger", "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM", "LINE/L1", "RC/Helitron"
))

# NOTE: Check that all the superfamilies in your dataset are included above

rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100 # as it is percent divergence

# Question:
substitution_rate <- 8.22e-9
rep_table.m$age <- rep_table.m$distance/(2*substitution_rate) # Calculate using the substitution rate and the formula provided in the tutorial


# options(scipen = 999)

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron", fam!="RC/Helitron")


ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_viridis_d(option = "turbo") +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

ggsave(filename = file.path(wd, "/output/05_perl/plots/05_TE_landscape_plot.png"), width = 10, height = 6, dpi=300)

write.table(rep_table.m,
            file = file.path(wd, "/output/05_perl/plots/rep_table.tsv"),
            sep = "\t",
            quote = FALSE,
            row.names = FALSE)

# Why is it important to have this plot in Mbp instead of counts? 
# Hint: 
# Consider a scenario where there is a lot of small fragments of TEs due to nested insertions and deletions.
# How would that affect the plot if you used counts instead of Mbp?
#

rep_table.copia.gypsy <- rep_table.m %>% filter(fam %in% c("LTR/Copia", "LTR/Gypsy"))
#Plot
ggplot(bla, aes(fill = fam, x = distance, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

ggsave(
  file.path(wd, "/output/05_perl/plots/05_Copia_vs_Gypsy.png"),
  width = 10, 
  height = 6, 
  dpi=300
)