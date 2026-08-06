# Generate two reproducible 13,000-gene SMR result sets and a Miami plot.

args_all <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_all, value = TRUE)
script_dir <- if (length(file_arg)) {
    dirname(normalizePath(sub("^--file=", "", file_arg[[1L]])))
} else {
    getwd()
}

source(file.path(script_dir, "miami.r"))

set.seed(20260801)

n_gene <- 13000L
chr_lengths <- c(
    248956422, 242193529, 198295559, 190214555, 181538259, 170805979,
    159345973, 145138636, 138394717, 133797422, 135086622, 133275309,
    114364328, 107043718, 101991189, 90338345, 83257441, 80373285,
    58617616, 64444167, 46709983, 50818468
)

# Allocate genes roughly in proportion to chromosome length, then place each
# probe independently along its chromosome.
probe_chr <- sample(
    seq_along(chr_lengths),
    size = n_gene,
    replace = TRUE,
    prob = chr_lengths
)
probe_bp <- vapply(
    probe_chr,
    function(chr) sample.int(chr_lengths[[chr]], 1L),
    integer(1L)
)

probe_id <- sprintf("SIMPROBE%05d", seq_len(n_gene))
gene <- sprintf("GENE%05d", seq_len(n_gene))

make_background <- function() {
    data.frame(
        probeID = probe_id,
        ProbeChr = probe_chr,
        Gene = gene,
        Probe_bp = probe_bp,
        p_SMR = stats::runif(n_gene, min = 1e-4, max = 1),
        p_HEIDI = stats::runif(n_gene, min = 0.02, max = 1),
        nsnp_HEIDI = sample(10:40, n_gene, replace = TRUE),
        stringsAsFactors = FALSE
    )
}

smr1 <- make_background()
smr2 <- make_background()

# Predefined non-overlapping signal groups make the comparison interpretable.
signal_ids <- sample(seq_len(n_gene), 120L)
shared_ids <- signal_ids[1:40]
top_specific_ids <- signal_ids[41:65]
bottom_specific_ids <- signal_ids[66:90]
top_heidi_rejected_ids <- signal_ids[91:105]
bottom_heidi_rejected_ids <- signal_ids[106:120]

strong_p <- function(n) 10^(-stats::runif(n, min = 7, max = 14))
heidi_pass_p <- function(n) stats::runif(n, min = 0.05, max = 0.95)
heidi_fail_p <- function(n) stats::runif(n, min = 1e-5, max = 0.005)

# Signals significant and HEIDI-passing in both datasets.
smr1$p_SMR[shared_ids] <- strong_p(length(shared_ids))
smr2$p_SMR[shared_ids] <- strong_p(length(shared_ids))
smr1$p_HEIDI[shared_ids] <- heidi_pass_p(length(shared_ids))
smr2$p_HEIDI[shared_ids] <- heidi_pass_p(length(shared_ids))

# Signals unique to the first/top dataset: these are highlighted automatically.
smr1$p_SMR[top_specific_ids] <- strong_p(length(top_specific_ids))
smr1$p_HEIDI[top_specific_ids] <- heidi_pass_p(length(top_specific_ids))

# Signals unique to the second/bottom dataset.
smr2$p_SMR[bottom_specific_ids] <- strong_p(length(bottom_specific_ids))
smr2$p_HEIDI[bottom_specific_ids] <- heidi_pass_p(length(bottom_specific_ids))

# SMR-significant signals that fail the user-specified HEIDI threshold.
smr1$p_SMR[top_heidi_rejected_ids] <- strong_p(length(top_heidi_rejected_ids))
smr1$p_HEIDI[top_heidi_rejected_ids] <- heidi_fail_p(length(top_heidi_rejected_ids))
smr2$p_SMR[bottom_heidi_rejected_ids] <- strong_p(length(bottom_heidi_rejected_ids))
smr2$p_HEIDI[bottom_heidi_rejected_ids] <- heidi_fail_p(length(bottom_heidi_rejected_ids))

# Add effect estimates consistent with each simulated two-sided SMR p-value.
add_effects <- function(dat) {
    dat$se_SMR <- stats::runif(nrow(dat), min = 0.03, max = 0.15)
    z_abs <- stats::qnorm(dat$p_SMR / 2, lower.tail = FALSE)
    dat$b_SMR <- sample(c(-1, 1), nrow(dat), replace = TRUE) * z_abs * dat$se_SMR
    dat[, c(
        "probeID", "ProbeChr", "Gene", "Probe_bp",
        "b_SMR", "se_SMR", "p_SMR", "p_HEIDI", "nsnp_HEIDI"
    )]
}

smr1 <- add_effects(smr1)
smr2 <- add_effects(smr2)

out_dir <- file.path(script_dir, "simulation_output")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

smr1_file <- file.path(out_dir, "simulated_SMR_top_13000.smr")
smr2_file <- file.path(out_dir, "simulated_SMR_bottom_13000.smr")
png_file <- file.path(out_dir, "simulated_SMR_miami.png")
pdf_file <- file.path(out_dir, "simulated_SMR_miami.pdf")
truth_file <- file.path(out_dir, "simulated_signal_groups.tsv")

data.table::fwrite(smr1, smr1_file, sep = "\t", quote = FALSE)
data.table::fwrite(smr2, smr2_file, sep = "\t", quote = FALSE)

signal_truth <- data.frame(
    probeID = probe_id[signal_ids],
    Gene = gene[signal_ids],
    signal_group = rep(c(
        "shared_pass",
        "top_specific_pass",
        "bottom_specific_pass",
        "top_heidi_rejected",
        "bottom_heidi_rejected"
    ), times = c(40, 25, 25, 15, 15)),
    stringsAsFactors = FALSE
)
data.table::fwrite(signal_truth, truth_file, sep = "\t", quote = FALSE)

MiamiData <- ReadMiamiData(
    smr1 = smr1_file,
    smr2 = smr2_file,
    heidi.threshold = 0.01,
    smr.alpha = 0.05
)

MiamiPlotObject <- MiamiPlot(
    data = MiamiData,
    plot.name = c("SMR dataset 1", "SMR dataset 2"),
    highlight = TRUE,
    highlight.text = TRUE,
    highlight.text.cex = 0.72,
    highlight.col = "#D73027",
    highlight.cex = 2.4,
    max.labels = 25,
    title = NULL
)

ggplot2::ggsave(
    filename = png_file,
    plot = MiamiPlotObject,
    width = 14,
    height = 8,
    units = "in",
    dpi = 300,
    bg = "white"
)
ggplot2::ggsave(
    filename = pdf_file,
    plot = MiamiPlotObject,
    width = 14,
    height = 8,
    units = "in",
    bg = "white"
)

summary_output <- data.frame(
    metric = c(
        "genes_per_dataset",
        "bonferroni_threshold_top",
        "bonferroni_threshold_bottom",
        "shared_pass",
        "top_specific_pass_and_highlighted",
        "bottom_specific_pass",
        "top_heidi_rejected",
        "bottom_heidi_rejected"
    ),
    value = c(
        n_gene,
        MiamiData$threshold[[1L]],
        MiamiData$threshold[[2L]],
        length(shared_ids),
        sum(MiamiData$dat$side == "top" & MiamiData$dat$specific),
        sum(MiamiData$dat$side == "bottom" & MiamiData$dat$specific),
        length(top_heidi_rejected_ids),
        length(bottom_heidi_rejected_ids)
    )
)
data.table::fwrite(
    summary_output,
    file.path(out_dir, "simulation_summary.tsv"),
    sep = "\t",
    quote = FALSE
)

print(summary_output, row.names = FALSE)
cat("\nFiles written to:\n", normalizePath(out_dir), "\n", sep = "")
