#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
# @FileName      : ldBlockSim.py
# @Time          : 2026-08-04
# @Author        : Lulu Shi
# @Email         : shilulu@stu.wchscu.cn
# @description   : Simulate and draw one lower-triangular LD block as an editable vector PDF.
# @Usage         : python ldBlockSim.py -m 10 --color "#F5A461" --seed 1 -o EUR_ld
"""
from pathlib import Path
import random
import re
import click
from reportlab.lib import colors
from reportlab.pdfgen import canvas


def clamp(x, low=0.0, high=1.0):
    """Restrict a numeric value to [low, high]."""
    return max(low, min(high, x))


def normalize_hex_color(value):
    """Validate and normalize a hexadecimal color string."""
    value = value.strip()
    if not value.startswith("#"):
        value = "#" + value

    if re.fullmatch(r"#[0-9A-Fa-f]{3}", value):
        value = "#" + "".join(ch * 2 for ch in value[1:])

    if not re.fullmatch(r"#[0-9A-Fa-f]{6}", value):
        raise click.BadParameter("Color must be a hexadecimal value such as '#3577AC'.")

    return value.upper()


def color_callback(ctx, param, value):
    """Click callback for hexadecimal color options."""
    return normalize_hex_color(value)


def hex_to_rgb(hex_color):
    """Convert '#RRGGBB' to RGB values in [0, 1]."""
    h = hex_color.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def mix_with_white(hex_color, proportion=0.96):
    """Create a very light endpoint color by mixing a color with white."""
    r, g, b = hex_to_rgb(hex_color)
    return colors.Color(
        r + (1.0 - r) * proportion,
        g + (1.0 - g) * proportion,
        b + (1.0 - b) * proportion
    )


def gradient_color(value, low_color, high_color):
    """Map a value in [0, 1] to a continuous color gradient."""
    value = clamp(value)
    return colors.Color(
        low_color.red + (high_color.red - low_color.red) * value,
        low_color.green + (high_color.green - low_color.green) * value,
        low_color.blue + (high_color.blue - low_color.blue) * value
    )

# LD simulation
def make_ld_matrix(m, seed):
    """
    Simulate one symmetric LD-like matrix.

    LD is generated adaptively from the supplied SNP count. Nearby SNPs tend
    to have stronger LD, while more distant SNPs tend to have weaker LD.
    No explicit block-size parameter is required.
    """
    rng = random.Random(seed)
    matrix = [[0.0 for _ in range(m)] for _ in range(m)]

    decay_scale = max(1.5, m / 3.0)

    for i in range(m):
        matrix[i][i] = 1.0

        for j in range(i):
            distance = i - j
            expected = 0.12 + 0.78 * pow(2.718281828, -distance / decay_scale)
            local_shift = rng.uniform(-0.10, 0.10)
            noise = rng.uniform(-0.07, 0.07)
            value = clamp(expected + local_shift + noise)

            matrix[i][j] = value
            matrix[j][i] = value

    return matrix

# Vector drawing
def draw_ld_block(pdf, matrix, x0, y0, cell_size, low_color, high_color):
    """Draw one clean lower-triangular LD block."""
    n = len(matrix)
    panel_height = n * cell_size

    pdf.setLineWidth(0.45)
    pdf.setStrokeColor(colors.HexColor("#D5D5D5"))

    for i in range(n):
        for j in range(i + 1):
            x = x0 + j * cell_size
            y = y0 + panel_height - (i + 1) * cell_size
            value = matrix[i][j]

            pdf.setFillColor(gradient_color(value, low_color, high_color))
            pdf.rect(x, y, cell_size, cell_size, fill=1, stroke=1)


def draw_colorbar(pdf, x, y, width, height, low_color, high_color):
    """Draw a borderless vector colorbar with labels 0, 0.5, and 1."""
    steps = max(120, int(height * 2))
    step_height = height / steps

    for k in range(steps):
        t = k / (steps - 1)
        pdf.setFillColor(gradient_color(t, low_color, high_color))
        pdf.rect(x, y + k * step_height, width, step_height + 0.25, fill=1, stroke=0)

    pdf.setFillColor(colors.black)
    pdf.setFont("Helvetica", 9)
    label_x = x + width + 5
    pdf.drawString(label_x, y - 2, "0")
    pdf.drawString(label_x, y + height / 2 - 2, "0.5")
    pdf.drawString(label_x, y + height - 2, "1")


def resolve_output_path(output_prefix):
    """Convert an output prefix into a PDF path and create its directory."""
    path = Path(output_prefix).expanduser()

    if path.suffix.lower() != ".pdf":
        path = Path(str(path) + ".pdf")

    path.parent.mkdir(parents=True, exist_ok=True)
    return path


@click.command(context_settings={"help_option_names": ["-h", "--help"]})
@click.option("-m", "--snp-count", type=click.IntRange(min=2), default=10, show_default=True, help="Number of SNPs in the simulated LD block.")
@click.option("--color", type=str, default="#3577AC", show_default=True, callback=color_callback, help="High-LD endpoint color in hexadecimal notation.")
@click.option("--seed", type=int, default=123, show_default=True, help="Random seed.")
@click.option("-o", "--output-prefix", type=str, required=True, help="Output prefix or PDF path.")
def main(snp_count, color, seed, output_prefix):
    """Simulate and draw one clean lower-triangular LD block."""
    matrix = make_ld_matrix(snp_count, seed)
    output_pdf = resolve_output_path(output_prefix)

    high_color = colors.HexColor(color)
    low_color = mix_with_white(color)

    cell_size = 24.0
    margin = 12.0
    colorbar_gap = 18.0
    colorbar_width = 12.0
    label_space = 28.0

    matrix_size = snp_count * cell_size
    page_width = 2 * margin + matrix_size + colorbar_gap + colorbar_width + label_space
    page_height = 2 * margin + matrix_size

    pdf = canvas.Canvas(str(output_pdf), pagesize=(page_width, page_height))
    pdf.setFillColor(colors.white)
    pdf.rect(0, 0, page_width, page_height, fill=1, stroke=0)

    draw_ld_block(pdf, matrix, margin, margin, cell_size, low_color, high_color)
    draw_colorbar(pdf, margin + matrix_size + colorbar_gap, margin, colorbar_width, matrix_size, low_color, high_color)

    pdf.showPage()
    pdf.save()

    click.echo(str(output_pdf))


if __name__ == "__main__":
    main()
