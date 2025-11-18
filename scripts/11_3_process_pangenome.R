library(tidyverse)
library(readr)

# -----------------
# 0) Inputs
# -----------------
args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]
focal_genome <- "Edi_0" # Your focal accession name
pangenome <- readRDS(file.path(wd, "pangenome_matrix.rds"))

# genome columns are list-columns produced by query_pangenes()
genome_cols <- names(pangenome)[sapply(pangenome, is.list)]

# Check that the genomes are as expected
genome_cols

pg <- as_tibble(pangenome)


# Remove out-of-synteny genes (IDs ending with '*') from all genome list-columns
clean_gene_list <- function(v) {
  if (is.null(v) || length(v) == 0) {
    return(character(0))
  }
  v <- as.character(v)
  v <- v[!is.na(v)]
  v <- trimws(v)
  v <- v[!grepl("\\*$", v)] # drop genes ending with '*'
  unique(v)
}

pg <- pg %>%
  mutate(across(all_of(genome_cols), ~ lapply(.x, clean_gene_list)))

# Remove orthogroups that are now empty in ALL genomes after cleaning
# (i.e., all genome columns have length 0)
pg <- pg %>%
  rowwise() %>%
  filter(
    sum(sapply(c_across(all_of(genome_cols)), length)) > 0
  ) %>%
  ungroup()


# Check the pangenome table
head(pg)


# How many orthogroups are there?
nrow(pg)

# -----------------
# 1) Presence/absence per genome (orthogroup-level)
#    TRUE if the cell has a non-empty list of gene IDs
# -----------------
presence_tbl <- pg %>%
  transmute(
    pgID,
    across(
      all_of(genome_cols),
      ~ lengths(.x) > 0,
      .names = "{.col}"
    )
  )

# Check the presence table
head(presence_tbl)
write.csv(presence_tbl, file=file.path(wd, "plots/presence_tbl.csv"))

# -----------------
# 2) Global orthogroup flags
# -----------------
n_genomes <- length(genome_cols)

pg_flags <- presence_tbl %>%
  mutate(
    # Count how many genomes have each orthogroup
    n_present = select(., all_of(genome_cols)) %>% rowSums(),

    # Core = present in ALL genomes
    is_core_all = (n_present == n_genomes),

    # Accessory = present in SOME genomes (not all)
    is_accessory = (n_present < n_genomes),

    # Is this orthogroup in our focal genome?
    present_in_focal = .data[[focal_genome]],

    # Focal-specific = ONLY in focal genome
    focal_specific = (present_in_focal & n_present == 1),

    # Lost in focal = present in other genomes but NOT focal
    lost_in_focal = (!present_in_focal & n_present > 0),

    # Almost-core lost in focal = in all genomes EXCEPT focal
    lost_core_without_focal = (!present_in_focal & n_present == (n_genomes - 1)),

    # Identify genes lost compared to TAIR10
    lost_vs_TAIR10 = (!present_in_focal) & .data[["TAIR10"]]
  ) %>%
  # Add simple category labels
  mutate(
    category = case_when(
      is_core_all ~ "core",
      n_present == 1 ~ "species_specific",
      TRUE ~ "accessory"
    )
  )

# Check the flags table
head(data.frame(pg_flags))
table(pg_flags$category)

write.csv(table(pg_flags$category), file=file.path(wd, "plots/pg_flags_categroy.csv"))
write.csv(table(pg_flags$n_present), file=file.path(wd, "plots/pg_flags_n_present.csv"))

og_summary <- pg_flags %>%
  group_by(category) %>%
  summarise(n_orthogroups = n())

write.csv(og_summary, file=file.path(wd, "plots/og_summary.csv"))

shared_with_TAIR10 <- pg_flags %>%
    filter(Edi_0 == TRUE & TAIR10 == TRUE) %>%
    nrow()
write.csv(shared_with_TAIR10, file=file.path(wd, "plots/shared_with_TAIR10.csv"))

unique_to_focal <- pg_flags %>%
    filter(category == "species_specific" & Edi_0 == TRUE) %>%
    nrow()
write.csv(unique_to_focal, file=file.path(wd, "plots/unique_to_focal.csv"))

unique_to_TAIR10 <- pg_flags %>%
    filter(category == "species_specific" & TAIR10 == TRUE) %>%
    nrow()
write.csv(unique_to_TAIR10, file=file.path(wd, "plots/unique_to_TAIR10.csv"))

my_accessions <- c("Edi_0", "Are_6", "Ice_1", "Etna_2", "TAIR10")

shared_all <- pg_flags %>%
  filter(if_all(all_of(my_accessions), ~ .x == TRUE)) %>%
  nrow()

write.csv(shared_all, file=file.path(wd, "plots/shared_all.csv"))


unique_by_genome <- lapply(my_accessions, function(gen) {
  tibble(
    genome = gen,
    unique_orthogroups =
      pg_flags %>%
        filter(.data[[gen]] == TRUE &
               rowSums(across(all_of(my_accessions), ~ .x == TRUE)) == 1) %>%
        nrow()
  )
}) %>% bind_rows()

write.csv(unique_by_genome, file=file.path(wd, "plots/unique_by_genome.csv"))


# -----------------
# 3) GENE counts per orthogroup × genome
#    convert list entries to integer counts = number of unique gene IDs
# -----------------
count_genes <- function(gene_list) {
  if (is.null(gene_list) || length(gene_list) == 0) {
    return(0)
  }
  # Count unique genes
  length(unique(gene_list))
}

# Apply the function to all genome columns
gene_counts_matrix <- pg %>%
  select(pgID, all_of(genome_cols)) %>%
  mutate(across(
    all_of(genome_cols),
    ~ sapply(.x, count_genes)
  ))

# Check the gene counts matrix
head(gene_counts_matrix)

# -----------------
# 4) GENE counts per genome & category
# -----------------
# add category to the matrix
gene_counts_w_cat <- pg_flags %>%
  select(pgID, category) %>%
  left_join(gene_counts_matrix, by = "pgID")

# Calculate total genes per genome (sum gene counts by category)
gene_by_cat <- gene_counts_w_cat %>%
  pivot_longer(cols = all_of(genome_cols), names_to = "genome", values_to = "gene_count") %>%
  group_by(genome, category) %>%
  summarise(gene_count = sum(gene_count), .groups = "drop")

# Total genes per genome (sum across all categories)
gene_totals <- gene_by_cat %>%
  group_by(genome) %>%
  summarise(gene_total = sum(gene_count), .groups = "drop")

# spread categories for a per-genome wide table
gene_counts_per_genome <- gene_by_cat %>%
  pivot_wider(names_from = category, values_from = gene_count, values_fill = 0) %>%
  rename(
    gene_core = core,
    gene_accessory = accessory,
    gene_specific = species_specific
  ) %>%
  left_join(gene_totals, by = "genome") %>%
  mutate(
    # Calculate percentages of genes by category
    percent_core = round(100 * gene_core / pmax(gene_total, 1), 2),
    percent_specific = round(100 * gene_specific / pmax(gene_total, 1), 2)
  )

# Check the gene counts per genome
head(data.frame(gene_counts_per_genome))

write.csv(data.frame(gene_counts_per_genome), file=file.path(wd, "plots/gene_counts_per_genome.csv"))

focal_gene_summary <- gene_counts_per_genome %>%
  filter(genome == focal_genome) %>%
  select(genome, gene_core, gene_accessory, gene_specific, gene_total, percent_core, percent_specific)

write.csv(focal_gene_summary, file=file.path(wd, "plots/focal_gene_summary.csv"))



# -----------------
# 5) Pangenome frequency plot: OGs and genes in n genomes
# -----------------

#  Count orthogroups by number of genomes they're present in
og_freq <- pg_flags %>%
  count(n_present, name = "count") %>%
  mutate(type = "Orthogroups")

# Count gene, how many present in orthogroups present in n genomes
# Create a long table of (pgID, genome, gene) and attach the orthogroup-level n_present
all_genes_with_presence <- pg %>%
  select(pgID, all_of(genome_cols)) %>%
  pivot_longer(cols = all_of(genome_cols), names_to = "genome", values_to = "genes_list") %>%
  # drop empty/null lists
  filter(!sapply(genes_list, is.null) & sapply(genes_list, length) > 0) %>%
  unnest_longer(genes_list) %>%
  rename(gene = genes_list) %>%
  filter(!is.na(gene)) %>%
  mutate(gene = as.character(gene)) %>%
  distinct(pgID, genome, gene) %>% # one row per distinct gene occurrence in a pgID/genome
  left_join(select(pg_flags, pgID, n_present), by = "pgID")



# Count genes by the n_present of their orthogroup.
# This counts unique gene × orthogroup occurrences.
gene_freq <- all_genes_with_presence %>%
  distinct(pgID, gene, n_present) %>% # unique gene in each orthogroup
  count(n_present, name = "count") %>%
  mutate(type = "Genes")

# Combine both
freq_data <- bind_rows(og_freq, gene_freq)

# Plot with better formatting
ggplot(freq_data, aes(x = n_present, y = count, fill = type)) +
  geom_col(position = "dodge", alpha = 0.8, width = 0.7) +
  scale_x_continuous(
    breaks = 1:n_genomes,
    labels = 1:n_genomes
  ) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("Genes" = "#0072B2", "Orthogroups" = "#D55E00")) +
  labs(
    x = "Number of genomes",
    y = "Count",
    fill = NULL,
    title = "Pangenome composition: distribution across genomes",
    subtitle = paste("Total genomes:", n_genomes)
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold")
  )

ggsave(file.path(wd, "plots/pangenome_frequency_plot.png"), width = 10, height = 6)

# Summary table
freq_summary <- freq_data %>%
  pivot_wider(names_from = type, values_from = count, values_fill = 0) %>%
  mutate(
    label = case_when(
      n_present == n_genomes ~ "Core (all genomes)",
      n_present == 1 ~ "Species-specific (1 genome)",
      TRUE ~ paste0("Shared (", n_present, " genomes)")
    )
  ) %>%
  arrange(desc(n_present)) %>%
  select(n_present, label, Orthogroups, Genes)

print(freq_summary)
write.csv(freq_summary, file=file.path(wd, "plots/freq_summary.csv"))
