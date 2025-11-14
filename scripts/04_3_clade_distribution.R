#**Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae).**#
# Load Gypsy classification data (adjust path as needed)
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)

#-------------------------------------------------------------
# Load Copia and Gypsy classification tables
#-------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]

copia <- read_tsv(file.path(wd,"/output/04_TEsorter/Copia.cls.tsv"))
gypsy <- read_tsv(file.path(wd,"/output/04_TEsorter/Gypsy.cls.tsv"))

# Add Superfamily column (if not already in file)
copia <- copia %>% mutate(Superfamily = "Copia")
gypsy <- gypsy %>% mutate(Superfamily = "Gypsy")

# Merge both
combined <- bind_rows(copia, gypsy)

#-------------------------------------------------------------
# Focus on key clades
#-------------------------------------------------------------
# Keep important/known clades
key_clades <- c("Athila", "CRM", "Reina", "Ale", "Angela", "Bianca", "Retand", "Tekay")
filtered <- combined %>%
  filter(Clade %in% key_clades)
#all clades
filtered <- combined

#-------------------------------------------------------------
# Summarize counts
#-------------------------------------------------------------
summary_tbl <- filtered %>%
  group_by(Superfamily, Clade, Complete) %>%
  summarise(count = n(), .groups = "drop")

#-------------------------------------------------------------
# Plot 1: Barplot (counts per clade, complete vs incomplete)
#-------------------------------------------------------------
p1 <- ggplot(summary_tbl, aes(x = reorder(Clade, -count), y = count, fill = Complete)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_wrap(~Superfamily, scales = "free_x") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Distribution of Major LTR Retrotransposon Clades",
    x = "Clade",
    y = "Number of elements",
    fill = "Complete TE"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("#FF9999", "#99CCFF"))

ggsave(file.path(wd, "/output/04_TEsorter/plots/04_LTR_clade_distribution_barplot.png"), p1, width = 10, height = 6, dpi = 300)

#-------------------------------------------------------------
# Plot 2: Pie chart showing proportion of each clade in both superfamilies
#-------------------------------------------------------------
prop_tbl <- combined %>%
  group_by(Superfamily, Clade) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(Superfamily) %>%
  mutate(percentage = count / sum(count) * 100)

p2 <- ggplot(prop_tbl, aes(x = "", y = percentage, fill = Clade)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  facet_wrap(~Superfamily) +
  theme_void(base_size = 14) +
  labs(title = "Proportion of LTR Clades within Each Superfamily") +
  scale_fill_brewer(palette = "Set3")

ggsave(file.path(wd, "/output/04_TEsorter/plots/04_LTR_clade_proportions_piechart.png"), p2, width = 8, height = 5, dpi = 300)

#-------------------------------------------------------------
# Summary table export
#-------------------------------------------------------------
write_tsv(summary_tbl, file.path(wd, "/output/04_TEsorter/plots/04_LTR_clade_summary_counts.tsv"))
write_tsv(prop_tbl, file.path(wd, "/output/04_TEsorter/plots04_LTR_clade_proportions.tsv"))

library(readr)
library(ggplot2)
library(dplyr)

# Load
df <- read_tsv(file.path(wd, "/output/04_TEsorter/LTR_clade_counts.tsv"),
               col_names = c("Count","Superfamily","Clade"))

# Plot
p3 <- ggplot(df, aes(x = reorder(Clade, -Count), y = Count, fill = Superfamily)) +
  geom_col(position = "dodge") +
  theme_minimal(base_size = 14) +
  labs(title = "Distribution of LTR Retrotransposon Clades",
       x = "Clade",
       y = "Number of annotated elements",
       fill = "Superfamily") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(wd, "/output/04_TEsorter/plots/04_Distr_LTR_RetroTE_clades.png"), p3, width = 8, height = 5, dpi = 300)
