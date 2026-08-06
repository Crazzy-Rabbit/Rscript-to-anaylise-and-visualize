# Reusable Miami plot functions for comparing two SMR result sets.
#
# Required packages: data.table and ggplot2.
# Source this file, prepare the data, and then create a ggplot object:
#
#   source("miami.r")
#   MiamiData <- ReadMiamiData(
#     "result_1.smr", "result_2.smr",
#     heidi.threshold = 0.01
#   )
#   p <- MiamiPlot(
#     data = MiamiData,
#     plot.name = c("transSMR", "SMR (mismatch)"),
#     highlight = TRUE,
#     highlight.text = FALSE
#   )
#   print(p)
#   ggplot2::ggsave("miami.pdf", p, width = 12, height = 7)


# =============================================================================
# Stage 1: input helpers
# =============================================================================
CheckPkg <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
        stop(
            sprintf("Package `%s` is required. Install it with install.packages(\"%s\").",
                    package, package),
            call. = FALSE
        )
    }
}


PairCol <- function(x, name, allow.null = FALSE) {
    if (is.null(x)) {
        if (allow.null) {
            return(list(NULL, NULL))
        }
        stop(sprintf("`%s` cannot be NULL.", name), call. = FALSE)
    }
    if (!is.character(x) || !length(x) %in% c(1L, 2L) ||
        anyNA(x) || any(!nzchar(x))) {
        stop(sprintf("`%s` must contain one or two non-empty column names.", name),
             call. = FALSE)
    }
    as.list(rep(x, length.out = 2L))
}


NormChr <- function(x) {
    x <- trimws(as.character(x))
    x <- sub("^chr", "", x, ignore.case = TRUE)
    x[toupper(x) == "M"] <- "MT"
    x
}


ReadSMR <- function(
    x,
    side,
    probe.col,
    chr.col,
    gene.col,
    pos.col,
    p.col,
    heidi.col,
    heidi.threshold
) {
    if (is.character(x) && length(x) == 1L) {
        if (!file.exists(x)) {
            stop(sprintf("SMR result file does not exist: %s", x), call. = FALSE)
        }
        dat <- data.table::fread(x, data.table = TRUE, showProgress = FALSE)
    } else if (is.data.frame(x)) {
        dat <- data.table::as.data.table(x)
        dat <- data.table::copy(dat)
    } else {
        stop("Each SMR input must be a file path, data.frame, or data.table.",
             call. = FALSE)
    }

    requested <- c(probe.col, chr.col, pos.col, p.col, heidi.col, gene.col)
    requested <- requested[!is.na(requested)]
    missing_cols <- setdiff(requested, names(dat))
    if (length(missing_cols)) {
        stop(
            sprintf("Missing column(s) in the %s input: %s",
                    side, paste(missing_cols, collapse = ", ")),
            call. = FALSE
        )
    }

    gene <- if (is.null(gene.col)) {
        rep(NA_character_, nrow(dat))
    } else {
        as.character(dat[[gene.col]])
    }
    heidi <- if (is.null(heidi.col)) {
        rep(NA_real_, nrow(dat))
    } else {
        suppressWarnings(as.numeric(dat[[heidi.col]]))
    }

    out <- data.table::data.table(
        probeID = as.character(dat[[probe.col]]),
        Chr = NormChr(dat[[chr.col]]),
        Gene = gene,
        BP = suppressWarnings(as.numeric(dat[[pos.col]])),
        p_SMR = suppressWarnings(as.numeric(dat[[p.col]])),
        p_HEIDI = heidi,
        side = side
    )

    bad <- is.na(out$probeID) | !nzchar(out$probeID) |
        is.na(out$Chr) | !nzchar(out$Chr) |
        !is.finite(out$BP) | out$BP < 0 |
        !is.finite(out$p_SMR) | out$p_SMR < 0 | out$p_SMR > 1
    if (any(bad)) {
        warning(sprintf(
            "Removed %d invalid row(s) from the %s input.", sum(bad), side
        ), call. = FALSE)
        out <- out[!bad]
    }
    if (!nrow(out)) {
        stop(sprintf("No valid rows remain in the %s input.", side), call. = FALSE)
    }

    if (is.null(heidi.col)) {
        out[, heidi_pass := TRUE]
    } else {
        out[, heidi_pass := !is.na(p_HEIDI) & p_HEIDI > heidi.threshold]
    }
    out
}


ChrOrder <- function(x) {
    upper <- toupper(as.character(x))
    special <- c(X = 23, Y = 24, XY = 25, MT = 26)
    numeric_part <- suppressWarnings(as.numeric(upper))
    numeric_part[is.na(numeric_part) & upper %in% names(special)] <-
        special[upper[is.na(numeric_part) & upper %in% names(special)]]
    unknown <- is.na(numeric_part)
    if (any(unknown)) {
        numeric_part[unknown] <- 1000 + match(upper[unknown], sort(unique(upper[unknown])))
    }
    numeric_part
}


# =============================================================================
# Stage 2: read and prepare two SMR result sets (ReadMiamiData)
# =============================================================================
# smr1 is plotted above the chromosome axis.
# smr2 is plotted below the chromosome axis.
# Each input may be a .smr file path, data.frame, or data.table.
#
# p_SMR is Bonferroni-adjusted separately in the two result sets.
# A probe passes HEIDI when p_HEIDI > heidi.threshold.
# mid.gap = NULL keeps the chromosome band proportional across traits.
# Set mid.gap to a number only when a fixed data-coordinate gap is preferred.
# Pass the returned object directly to MiamiPlot().
# =============================================================================
ReadMiamiData <- function(
    smr1,
    smr2,
    probe.col = "probeID",
    chr.col = "ProbeChr",
    gene.col = "Gene",
    pos.col = "Probe_bp",
    p.col = "p_SMR",
    heidi.col = "p_HEIDI",
    heidi.threshold = 0.01,
    smr.alpha = 0.05,
    mid.gap = NULL,
    p.min = 1e-300
) {
    CheckPkg("data.table")

    if (!is.numeric(heidi.threshold) || length(heidi.threshold) != 1L ||
        is.na(heidi.threshold) || heidi.threshold < 0 || heidi.threshold > 1) {
        stop("`heidi.threshold` must be one number between 0 and 1.", call. = FALSE)
    }
    if (!is.numeric(smr.alpha) || length(smr.alpha) != 1L ||
        is.na(smr.alpha) || smr.alpha <= 0 || smr.alpha > 1) {
        stop("`smr.alpha` must be one number in (0, 1].", call. = FALSE)
    }
    if (!is.null(mid.gap) &&
        (!is.numeric(mid.gap) || length(mid.gap) != 1L ||
         !is.finite(mid.gap) || mid.gap < 0)) {
        stop("`mid.gap` must be NULL or one non-negative number.", call. = FALSE)
    }
    if (!is.numeric(p.min) || length(p.min) != 1L ||
        !is.finite(p.min) || p.min <= 0 || p.min > 1) {
        stop("`p.min` must be one number in (0, 1].", call. = FALSE)
    }

    probe.cols <- PairCol(probe.col, "probe.col")
    chr.cols <- PairCol(chr.col, "chr.col")
    gene.cols <- PairCol(gene.col, "gene.col", allow.null = TRUE)
    pos.cols <- PairCol(pos.col, "pos.col")
    p.cols <- PairCol(p.col, "p.col")
    heidi.cols <- PairCol(heidi.col, "heidi.col", allow.null = TRUE)

    dat1 <- ReadSMR(
        x = smr1,
        side = "top",
        probe.col = probe.cols[[1L]],
        chr.col = chr.cols[[1L]],
        gene.col = gene.cols[[1L]],
        pos.col = pos.cols[[1L]],
        p.col = p.cols[[1L]],
        heidi.col = heidi.cols[[1L]],
        heidi.threshold = heidi.threshold
    )
    dat2 <- ReadSMR(
        x = smr2,
        side = "bottom",
        probe.col = probe.cols[[2L]],
        chr.col = chr.cols[[2L]],
        gene.col = gene.cols[[2L]],
        pos.col = pos.cols[[2L]],
        p.col = p.cols[[2L]],
        heidi.col = heidi.cols[[2L]],
        heidi.threshold = heidi.threshold
    )

    ntest <- c(
        data.table::uniqueN(dat1$probeID),
        data.table::uniqueN(dat2$probeID)
    )
    thresholds <- as.list(smr.alpha / ntest)
    dat1[, p_SMR_adj := pmin(p_SMR * ntest[[1L]], 1)]
    dat2[, p_SMR_adj := pmin(p_SMR * ntest[[2L]], 1)]
    dat1[, sig := p_SMR_adj < smr.alpha]
    dat2[, sig := p_SMR_adj < smr.alpha]

    pass1 <- unique(dat1[sig & heidi_pass, probeID])
    pass2 <- unique(dat2[sig & heidi_pass, probeID])
    dat1[, specific := sig & heidi_pass & !(probeID %in% pass2)]
    dat2[, specific := sig & heidi_pass & !(probeID %in% pass1)]

    dat <- data.table::rbindlist(list(dat1, dat2), use.names = TRUE)
    chr_info <- dat[, .(chr_length = max(BP, na.rm = TRUE)), by = Chr]
    chr_info[, chr_order := ChrOrder(Chr)]
    data.table::setorder(chr_info, chr_order, Chr)
    chr_info[, offset := data.table::shift(cumsum(chr_length), fill = 0)]
    chr_info[, chr_index := seq_len(.N)]

    dat[chr_info, on = "Chr", `:=`(
        offset = i.offset,
        chr_index = i.chr_index
    )]
    dat[, x := BP + offset]
    dat[, logp := -log10(pmax(p_SMR, p.min))]

    axis_dat <- chr_info[, .(
        Chr,
        center = offset + chr_length / 2
    )]
    max_logp <- max(
        dat$logp,
        -log10(pmax(unlist(thresholds), p.min)),
        na.rm = TRUE
    )
    gap.auto <- is.null(mid.gap)
    if (gap.auto) {
        mid.gap <- max_logp * 0.10
    }
    dat[, y := ifelse(side == "top", logp + mid.gap, -(logp + mid.gap))]

    raw_breaks <- pretty(c(0, max_logp), n = 5)
    raw_breaks <- unique(c(
        0,
        raw_breaks[raw_breaks > 0 & raw_breaks <= max_logp]
    ))

    result <- list(
        dat = dat,
        chr_info = chr_info,
        axis_dat = axis_dat,
        threshold = unlist(thresholds, use.names = FALSE),
        threshold.y = c(
            mid.gap - log10(pmax(thresholds[[1L]], p.min)),
            -(mid.gap - log10(pmax(thresholds[[2L]], p.min)))
        ),
        max.logp = max_logp,
        y.breaks = c(-(rev(raw_breaks) + mid.gap), raw_breaks + mid.gap),
        y.labels = c(rev(raw_breaks), raw_breaks),
        mid.gap = mid.gap,
        p.min = p.min,
        settings = list(
            heidi.threshold = heidi.threshold,
            heidi.enabled = !is.null(heidi.col),
            smr.adjust.method = "bonferroni",
            smr.alpha = smr.alpha,
            ntest = ntest,
            mid.gap.auto = gap.auto
        )
    )
    class(result) <- "MiamiData"
    result
}


# =============================================================================
# Stage 3: highlight and label helpers
# =============================================================================
CheckCol <- function(x, name, allow.multiple = FALSE) {
    valid_length <- if (allow.multiple) length(x) >= 1L else length(x) == 1L
    if (!is.character(x) || !valid_length || anyNA(x) || any(!nzchar(x))) {
        stop(sprintf("`%s` must contain %s valid colour value(s).",
                     name, if (allow.multiple) "one or more" else "one"),
             call. = FALSE)
    }
    invisible(TRUE)
}


HighlightIndex <- function(
    dat,
    highlight,
    highlight.by
) {
    side_ok <- dat$side == "top"

    if (is.null(highlight) || identical(highlight, FALSE) || !length(highlight)) {
        return(rep(FALSE, nrow(dat)))
    }
    if (is.logical(highlight)) {
        if (length(highlight) != 1L || is.na(highlight)) {
            stop("Logical `highlight` must be a single TRUE or FALSE.", call. = FALSE)
        }
        return(side_ok & dat$specific)
    }

    match_values <- function(values) {
        values <- as.character(values)
        switch(
            highlight.by,
            Gene = dat$Gene %in% values,
            probeID = dat$probeID %in% values,
            both = dat$Gene %in% values | dat$probeID %in% values
        )
    }

    if (is.list(highlight)) {
        highlight <- unlist(highlight, recursive = TRUE, use.names = FALSE)
        if (!is.atomic(highlight)) {
            stop("List `highlight` must contain gene or probe names.", call. = FALSE)
        }
        selected <- match_values(highlight)
    } else if (is.atomic(highlight)) {
        selected <- match_values(highlight)
    } else {
        stop("`highlight` must be TRUE/FALSE, a character vector, or a list.",
             call. = FALSE)
    }
    side_ok & selected
}


LabelData <- function(
    highlighted_dat,
    highlight,
    highlight.text,
    highlight.by,
    max.labels
) {
    if (!nrow(highlighted_dat) || is.null(highlight.text) ||
        identical(highlight.text, FALSE) || !length(highlight.text) ||
        max.labels == 0) {
        highlighted_dat[, label := character(.N)]
        return(highlighted_dat[0])
    }

    label_dat <- data.table::copy(highlighted_dat)
    if (isTRUE(highlight.text)) {
        label_dat[, label := ifelse(
            !is.na(Gene) & nzchar(Gene), Gene, probeID
        )]
    } else if (is.character(highlight.text)) {
        if (is.character(highlight) && length(highlight.text) == length(highlight)) {
            label_map <- stats::setNames(highlight.text, highlight)
            key <- switch(
                highlight.by,
                Gene = label_dat$Gene,
                probeID = label_dat$probeID,
                both = ifelse(label_dat$Gene %in% highlight,
                              label_dat$Gene, label_dat$probeID)
            )
            label_dat[, label := unname(label_map[key])]
        } else if (length(highlight.text) == 1L) {
            label_dat[, label := highlight.text]
        } else {
            stop(paste0(
                "Character `highlight.text` must have length one, or match a ",
                "character `highlight` vector."
            ), call. = FALSE)
        }
    } else {
        stop("`highlight.text` must be TRUE/FALSE, NULL, or character.",
             call. = FALSE)
    }

    label_dat <- label_dat[!is.na(label) & nzchar(label)]
    data.table::setorder(label_dat, p_SMR)
    label_dat <- unique(label_dat, by = c("side", "label"))
    if (is.finite(max.labels) && nrow(label_dat) > max.labels) {
        label_dat <- label_dat[seq_len(as.integer(max.labels))]
    }
    label_dat
}


# =============================================================================
# Stage 4: draw the Miami plot (MiamiPlot)
# =============================================================================
# plot.name must contain the top and bottom plot names.
#
# highlight = TRUE: automatically highlight first-file-specific signals.
# highlight = c("GENE1", "GENE2"): manually highlight genes in the top plot.
# highlight = list(Gene = c("GENE1", "GENE2")): list input is also accepted.
# highlight = FALSE: do not highlight any point.
# highlight.text = FALSE: highlight points without gene labels or leader lines.
# Only probes passing both SMR and HEIDI are drawn as solid signal points.
# SMR-significant probes failing HEIDI follow the background-point style.
# chr.cex, axis.cex, and lab.cex control chromosome, tick-label, and axis-title sizes.
#
# The function returns a ggplot object for print() or ggplot2::ggsave().
# =============================================================================
MiamiPlot <- function(
    data,
    plot.name,
    highlight = TRUE,
    highlight.by = c("Gene", "probeID", "both"),
    highlight.text = TRUE,
    highlight.text.cex = 1,
    highlight.text.col = "black",
    highlight.text.font = 3,
    highlight.col = "#D73027",
    highlight.cex = 2,
    highlight.pch = 16,
    col = c("#BDBDBD", "#737373"),
    cex = 0.9,
    pch = 16,
    alpha = 0.65,
    signal.col = "#222222",
    signal.cex = 2,
    threshold.col = "#D73027",
    threshold.lty = "dashed",
    threshold.lwd = 0.6,
    threshold.text = TRUE,
    plot.name.col = c("#74BF74", "#FFAA60"),
    plot.name.cex = 1.3,
    chr.cex = 1.2,
    axis.cex = 1.2,
    lab.cex = 1.2,
    max.labels = 30L,
    title = NULL,
    xlab = "Chromosome",
    ylab = expression(-log[10](italic(P)[plain(SMR)]))
) {
    CheckPkg("ggplot2")

    if (!inherits(data, "MiamiData")) {
        stop("`data` must be returned by `ReadMiamiData()`.", call. = FALSE)
    }
    if (missing(plot.name) || length(plot.name) != 2L ||
        anyNA(plot.name) || any(!nzchar(as.character(plot.name)))) {
        stop("`plot.name` is required and must contain top and bottom labels.", call. = FALSE)
    }
    plot.name <- as.character(plot.name)
    highlight.by <- match.arg(highlight.by)
    CheckCol(col, "col", allow.multiple = TRUE)
    CheckCol(highlight.col, "highlight.col")
    CheckCol(highlight.text.col, "highlight.text.col")
    CheckCol(signal.col, "signal.col")
    CheckCol(threshold.col, "threshold.col")
    CheckCol(plot.name.col, "plot.name.col", allow.multiple = TRUE)
    plot.name.col <- rep(plot.name.col, length.out = 2L)

    for (x in c("highlight.text.cex", "highlight.cex", "cex",
                "signal.cex", "threshold.lwd", "plot.name.cex",
                "chr.cex", "axis.cex", "lab.cex")) {
        value <- get(x, inherits = FALSE)
        if (!is.numeric(value) || length(value) != 1L ||
            !is.finite(value) || value < 0) {
            stop(sprintf("`%s` must be one non-negative number.", x), call. = FALSE)
        }
    }
    if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
        alpha < 0 || alpha > 1) {
        stop("`alpha` must be one number between 0 and 1.", call. = FALSE)
    }
    if (!is.numeric(max.labels) || length(max.labels) != 1L ||
        is.na(max.labels) || max.labels < 0) {
        stop("`max.labels` must be a non-negative number or Inf.", call. = FALSE)
    }

    dat <- data.table::copy(data$dat)
    chr_palette <- rep(col, length.out = nrow(data$chr_info))
    dat[, base_col := chr_palette[chr_index]]
    dat[, highlighted := HighlightIndex(
        dat = .SD,
        highlight = highlight,
        highlight.by = highlight.by
    )]

    background <- dat[sig == FALSE | heidi_pass == FALSE]
    accepted <- dat[sig == TRUE & heidi_pass == TRUE & highlighted == FALSE]
    highlighted_dat <- dat[highlighted == TRUE]

    max_logp <- data$max.logp
    mid.gap <- data$mid.gap
    axis.tick <- mid.gap * (0.22 / 1.2)
    y.limit <- mid.gap + max_logp + max(0.5, max_logp * 0.04)

    p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_hline(
            yintercept = data$threshold.y,
            linetype = threshold.lty,
            linewidth = threshold.lwd,
            colour = threshold.col
        ) +
        ggplot2::geom_point(
            data = background,
            ggplot2::aes(colour = base_col),
            size = cex,
            shape = pch,
            alpha = alpha
        ) +
        ggplot2::scale_colour_identity() +
        ggplot2::geom_point(
            data = accepted,
            size = signal.cex,
            shape = 16,
            colour = signal.col
        ) +
        ggplot2::geom_point(
            data = highlighted_dat,
            size = highlight.cex,
            shape = highlight.pch,
            colour = highlight.col
        ) +
        ggplot2::annotate(
            "rect",
            xmin = -Inf, xmax = Inf,
            ymin = -mid.gap, ymax = mid.gap,
            fill = "white", colour = NA
        ) +
        ggplot2::geom_hline(
            yintercept = c(-mid.gap, mid.gap),
            linewidth = 0.45,
            colour = "black"
        ) +
        ggplot2::geom_segment(
            data = data$axis_dat,
            ggplot2::aes(
                x = center, xend = center,
                y = mid.gap, yend = mid.gap - axis.tick
            ),
            inherit.aes = FALSE,
            linewidth = 0.45,
            colour = "black"
        ) +
        ggplot2::geom_segment(
            data = data$axis_dat,
            ggplot2::aes(
                x = center, xend = center,
                y = -mid.gap, yend = -mid.gap + axis.tick
            ),
            inherit.aes = FALSE,
            linewidth = 0.45,
            colour = "black"
        ) +
        ggplot2::geom_text(
            data = data$axis_dat,
            ggplot2::aes(x = center, y = 0, label = Chr),
            inherit.aes = FALSE,
            size = 3.5 * chr.cex,
            colour = "black"
        ) +
        ggplot2::annotate(
            "text",
            x = Inf,
            y = mid.gap + max_logp * 0.90,
            label = plot.name[[1L]],
            hjust = 1.1,
            colour = plot.name.col[[1L]],
            fontface = "bold",
            size = 3.8 * plot.name.cex
        ) +
        ggplot2::annotate(
            "text",
            x = Inf,
            y = -(mid.gap + max_logp * 0.90),
            label = plot.name[[2L]],
            hjust = 1.1,
            colour = plot.name.col[[2L]],
            fontface = "bold",
            size = 3.8 * plot.name.cex
        ) +
        ggplot2::scale_x_continuous(
            expand = ggplot2::expansion(mult = c(0.005, 0.005))
        ) +
        ggplot2::scale_y_continuous(
            breaks = data$y.breaks,
            labels = data$y.labels,
            expand = ggplot2::expansion(mult = c(0.02, 0.02))
        ) +
        ggplot2::coord_cartesian(
            xlim = range(dat$x),
            ylim = c(-y.limit, y.limit),
            clip = "off"
        ) +
        ggplot2::labs(title = title, x = xlab, y = ylab) +
        ggplot2::theme_classic() +
        ggplot2::theme(
            plot.title = ggplot2::element_text(size = 15, face = "bold", hjust = 0.5),
            axis.title = ggplot2::element_text(
                size = 12 * lab.cex,
                colour = "black"
            ),
            axis.text = ggplot2::element_text(
                size = 12 * axis.cex,
                colour = "black"
            ),
            axis.text.x = ggplot2::element_blank(),
            axis.line.x = ggplot2::element_blank(),
            axis.ticks.x = ggplot2::element_blank(),
            legend.position = "none",
            plot.margin = ggplot2::margin(8, 15, 8, 5.5)
        )

    if (isTRUE(threshold.text)) {
        threshold_labels <- data.frame(
            x = Inf,
            y = data$threshold.y,
            label = paste0(
                "italic(P) == ",
                format(data$threshold, scientific = TRUE, digits = 3)
            ),
            vjust = c(-0.5, 1.5)
        )
        p <- p + ggplot2::geom_text(
            data = threshold_labels,
            ggplot2::aes(x = x, y = y, label = label, vjust = vjust),
            inherit.aes = FALSE,
            parse = TRUE,
            hjust = 1.1,
            size = 3.6 * axis.cex,
            colour = threshold.col
        )
    }

    label_dat <- LabelData(
        highlighted_dat = highlighted_dat,
        highlight = highlight,
        highlight.text = highlight.text,
        highlight.by = highlight.by,
        max.labels = max.labels
    )
    if (nrow(label_dat) > 0L) {
        # Keep the original label layout: a vertical line rises from the point,
        # then bends towards a vertically written gene label above the panel.
        label_pad <- max(1.5, max_logp * 0.08)
        label_y <- y.limit + label_pad
        data.table::setorder(label_dat, x)
        label_dat[, label_x := x]

        label_gap <- diff(range(dat$x)) / 70
        if (nrow(label_dat) > 1L && is.finite(label_gap) && label_gap > 0) {
            for (i in 2:nrow(label_dat)) {
                label_dat$label_x[[i]] <- max(
                    label_dat$label_x[[i]],
                    label_dat$label_x[[i - 1L]] + label_gap
                )
            }
            if (label_dat$label_x[[nrow(label_dat)]] > max(dat$x)) {
                label_dat$label_x[[nrow(label_dat)]] <- max(dat$x)
                for (i in (nrow(label_dat) - 1L):1L) {
                    label_dat$label_x[[i]] <- min(
                        label_dat$label_x[[i]],
                        label_dat$label_x[[i + 1L]] - label_gap
                    )
                }
            }
            if (label_dat$label_x[[1L]] < min(dat$x)) {
                label_dat[, label_x := label_x + min(dat$x) - label_x[[1L]]]
            }
        }
        label_dat[, `:=`(
            label_y_plot = label_y,
            bend_y = y.limit + 0.3
        )]

        p <- p +
            ggplot2::geom_segment(
                data = label_dat,
                ggplot2::aes(x = x, xend = x, y = y, yend = bend_y),
                inherit.aes = FALSE,
                colour = "grey80",
                linewidth = 0.35
            ) +
            ggplot2::geom_segment(
                data = label_dat,
                ggplot2::aes(
                    x = x, xend = label_x,
                    y = bend_y, yend = label_y_plot
                ),
                inherit.aes = FALSE,
                colour = "grey80",
                linewidth = 0.35
            ) +
            ggplot2::geom_text(
                data = label_dat,
                ggplot2::aes(x = label_x, y = label_y_plot, label = label),
                inherit.aes = FALSE,
                angle = 90,
                hjust = 0,
                vjust = 0.5,
                size = 4.5 * highlight.text.cex,
                colour = highlight.text.col,
                fontface = highlight.text.font,
                check_overlap = TRUE
            ) +
            ggplot2::theme(
                plot.margin = ggplot2::margin(100, 15, 8, 5.5)
            )
    }

    p
}
