library(ggplot2)

source("miami.r")


smr_dir <- "/work/home/shilulu/project_beta_impute/results/INTERVAL/eas26trait"
out_dir <- file.path(smr_dir, "Miami_plot")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)


# The first file is plotted on top.
eas_files <- list.files(
    smr_dir,
    pattern = "_eQTLeas\\.smr$",
    full.names = TRUE
)

# The second file is plotted on the bottom.
eur_files <- list.files(
    smr_dir,
    pattern = "_eQTLeur\\.smr$",
    full.names = TRUE
)

names(eas_files) <- sub("_eQTLeas\\.smr$", "", basename(eas_files))
names(eur_files) <- sub("_eQTLeur\\.smr$", "", basename(eur_files))

traits <- intersect(names(eas_files), names(eur_files))


for (trait in traits) {
    MiamiData <- ReadMiamiData(
        smr1 = eas_files[[trait]],
        smr2 = eur_files[[trait]],
        heidi.threshold = 0.01,
        smr.alpha = 0.05
    )

    p <- MiamiPlot(
        data = MiamiData,
        plot.name = c("transSMR", "SMR (mismatch)"),
        highlight = TRUE,
        highlight.text = TRUE,
        highlight.text.cex = 1,
        max.labels = 30
    )

    ggsave(
        filename = file.path(out_dir, paste0(trait, "_Miami.pdf")),
        plot = p,
        width = 14,
        height = 8
    )
}
