#!/usr/bin/env Rscript

# Reproduce the simulated example figures shown in PhD/README.md.

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) == 0) {
  stop("Run this file with Rscript so its location can be resolved.")
}

script_path <- normalizePath(sub("^--file=", "", script_arg[[1]]), winslash = "/")
script_dir <- dirname(script_path)
images_dir <- file.path(script_dir, "images")
dir.create(images_dir, recursive = TRUE, showWarnings = FALSE)

example_dir <- tempfile("phd-example-data-")
dir.create(example_dir)
on.exit(unlink(example_dir, recursive = TRUE, force = TRUE), add = TRUE)

set.seed(20260806)

# Shared simulated regional-association data.
chromosome <- 6L
lead_position <- 52500000L
lead_snp <- "rsSimLead"
positions <- as.integer(seq(lead_position - 495000L, lead_position + 495000L, length.out = 901))
snps <- sprintf("rsSim%04d", seq_along(positions))
lead_index <- which.min(abs(positions - lead_position))
positions[[lead_index]] <- lead_position
snps[[lead_index]] <- lead_snp

distance <- abs(positions - lead_position)
neg_log10_p <- pmax(
  0.15,
  1.0 + 9.4 * exp(-distance / 78000) + rnorm(length(positions), sd = 0.55)
)
p_values <- pmin(1, 10^(-neg_log10_p))
p_values[[lead_index]] <- 2e-12

gwas <- data.frame(
  CHR = chromosome,
  POS = positions,
  SNP = snps,
  p = p_values
)

ld_r2 <- pmax(0, pmin(1, exp(-distance / 135000) + rnorm(length(positions), sd = 0.055)))
ld_r2[[lead_index]] <- 1
plink_ld <- data.frame(
  CHR_A = chromosome,
  BP_A = lead_position,
  SNP_A = lead_snp,
  CHR_B = chromosome,
  BP_B = positions,
  SNP_B = snps,
  R2 = ld_r2
)

pip <- pmax(0, pmin(1, 0.01 + 0.86 * exp(-distance / 52000) + runif(length(positions), 0, 0.055)))
pip[[lead_index]] <- 0.97
gwfm <- data.frame(
  Chrom = chromosome,
  Position = positions,
  Name = snps,
  PIP = pip
)

genes <- data.frame(
  CHR = chromosome,
  START = c(52070000, 52215000, 52320000, 52405000, 52535000, 52640000, 52765000, 52890000),
  END = c(52210000, 52305000, 52455000, 52520000, 52615000, 52745000, 52865000, 52970000),
  GENE = c("SIM1", "REG2", "MAPKX", "LEAD1", "GENE5", "QTL6", "LOC7", "SIM8"),
  ORIENTATION = c("+", "-", "+", "+", "-", "+", "-", "+")
)

gwas_path <- file.path(example_dir, "simulated_gwas.tsv")
ld_path <- file.path(example_dir, "simulated_plink.ld")
gwfm_path <- file.path(example_dir, "simulated_gwfm.tsv")
gene_path <- file.path(example_dir, "simulated_genes.tsv")
data.table::fwrite(gwas, gwas_path, sep = "\t")
data.table::fwrite(plink_ld, ld_path, sep = "\t")
data.table::fwrite(gwfm, gwfm_path, sep = "\t")
data.table::fwrite(genes, gene_path, sep = "\t")

# LocusZoom-style regional association plot.
source(file.path(script_dir, "plot_LocusZoom.r"))
locus_data <- ReadLocusZoomData(
  gwas = gwas_path,
  ld_info = ld_path,
  snp = lead_snp,
  flank = 500000
)
png(
  file.path(images_dir, "locuszoom_simulated.png"),
  width = 2400,
  height = 1600,
  res = 300,
  type = "cairo",
  bg = "white"
)
plot_locuszoom(data = locus_data, genelist = gene_path, flank = 500000)
dev.off()

# Genome-wide fine-mapping regional plot.
source(file.path(script_dir, "plot_GWFM.r"))
gwfm_data <- ReadPvalueFromFiles(
  gwas = gwas_path,
  gwfm = gwfm_path,
  glist = gene_path,
  windowsize = 500000,
  highlight = lead_snp
)
png(
  file.path(images_dir, "gwfm_simulated.png"),
  width = 2400,
  height = 2400,
  res = 300,
  type = "cairo",
  bg = "white"
)
MultiPvalueLocusPlot(data = gwfm_data)
dev.off()

# Multi-trait QQ plot.
source(file.path(script_dir, "qqplot_multi.r"))
set.seed(20260108)
n_pvalues <- 30000L
p_null <- runif(n_pvalues)
p_polygenic <- runif(n_pvalues)
polygenic_signal <- rbinom(n_pvalues, 1, 0.03) == 1
p_polygenic[polygenic_signal] <- rbeta(sum(polygenic_signal), shape1 = 0.4, shape2 = 1)
z_inflated <- rnorm(n_pvalues, mean = 0, sd = 1.2)
p_inflated <- 2 * pnorm(-abs(z_inflated))
p_strong <- runif(n_pvalues)
strong_index <- sample.int(n_pvalues, size = round(0.01 * n_pvalues))
p_strong[strong_index] <- 10^(-runif(length(strong_index), min = 6, max = 10))

pvalue_sets <- list(
  Null = p_null,
  Polygenic = p_polygenic,
  Inflated = p_inflated,
  Strong = p_strong
)

png(
  file.path(images_dir, "qqplot_multi_simulated.png"),
  width = 2400,
  height = 2400,
  res = 300,
  type = "cairo",
  bg = "white"
)
qqplot_multi(
  pvalue_sets,
  ylim = 11,
  cols = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"),
  pch = c(16, 17, 15, 18),
  cex = 0.55,
  ci_scale = seq(0.82, 1.0, length.out = 4),
  ci_alpha = 0.35,
  ci_border = FALSE,
  diag_col = "#3F3F46"
)
dev.off()

message("Generated R example images in: ", images_dir)
