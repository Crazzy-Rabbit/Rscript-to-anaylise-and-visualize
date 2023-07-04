# -*- coding: utf-8 -*-
"""
Created on Mon Jan 15 20:28:05 2018

@author: Caiyd
"""

import json
import click
CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
from itertools import cycle


def load_allchrom_data(infile, chr_col, loc_col, val_col, log_trans, neg_logtrans):
    """
    infile contain several chromosomes
    """
    df = pd.read_csv(infile,
                     sep='\t',
                     usecols = [chr_col, loc_col, val_col],
                     dtype={chr_col: str,
                            loc_col: float,
                            val_col: float})
    if log_trans:
        df.loc[:, val_col] = np.log10(df[val_col].values)
    elif neg_logtrans:
        df.loc[:, val_col] = -np.log10(df[val_col].values)
    df.dropna(inplace=True)
    return df

def load_cutoff(cutoff, log_trans, neg_logtrans):
    with open(cutoff) as f:
        cutoff = {}
        for line in f:
            tline = line.strip().split()
            value = float(tline[1])
            if log_trans:
                value = np.log10(value)
            elif neg_logtrans:
                value = -np.log10(value)
            cutoff[tline[0]] = value
    return cutoff


def plot(df, chr_col, loc_col, val_col, xlabel, ylabel, ylim, invert_yaxis, top_xaxis, cutoff,
         highlight, outfile, ticklabelsize, figsize, axlabelsize, markersize, fill_regions,
         windowsize):
    sns.set_style('white', {'ytick.major.size': 3, 'xtick.major.size': 3})
    fig, ax = plt.subplots(1, 1, figsize=figsize)
#    offsets = {}
    loc_offset = 0
    xticks = []
    xticklabels = []
    
    # for fill_between
    valmax = df[val_col].max()
    valmin = df[val_col].min()
    if ylim:
        y1, y2 = ylim
    else:
        y1 = valmin
        y2 = valmax * 1.05

    # plot val
    for chrom, color in zip(df[chr_col].unique(), cycle(['#1B2C62', '#4695BC'])):
#        offsets[chrom] = loc_offset
        tmpdf = df.loc[df[chr_col]==chrom, [loc_col, val_col]]
        tmpdf[loc_col] += loc_offset
        xticklabels.append(chrom)
        xticks.append(tmpdf[loc_col].median())
        tmpdf.plot(kind='scatter', x=loc_col, y=val_col, ax=ax, s=markersize, color=color, marker='o')
        if isinstance(highlight, pd.DataFrame):
            hdf = highlight.loc[highlight[chr_col]==chrom, [loc_col, val_col]]
            if hdf.shape[0] > 0:
                hdf[loc_col] += loc_offset
                hdf.plot(kind='scatter', x=loc_col, y=val_col, ax=ax, s=markersize, color='#55A868', marker='o')
        if cutoff:
            ax.hlines(cutoff[chrom], tmpdf[loc_col].values[0], tmpdf[loc_col].values[-1], colors='#CEAF7D', linestyles='dashed')

        # fill_between region
        if isinstance(fill_regions, pd.DataFrame):
            regions = fill_regions.loc[fill_regions['chrom']==chrom, ['start', 'end']].values
            if regions.shape[0] > 0:
                regions += loc_offset
                for region in regions:
                    # region: list [float, float]
                    ax.fill_between(region, y1, y2, color='grey', alpha=0.6)

        # plot mean value line
        if windowsize:
            tmpdf['window_index'] = tmpdf[loc_col] // windowsize
            tmpdf.groupby('window_index').agg({loc_col: np.median,
                                            val_col: np.median}).plot(x=loc_col, y=val_col, kind='line', ax=ax)


        loc_offset = tmpdf[loc_col].values[-1] # assume loc is sorted
    ax.set_xlabel(xlabel, fontsize=axlabelsize)
    ax.set_ylabel(ylabel, fontsize=axlabelsize)
    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')
    plt.xticks(xticks, xticklabels)
    ax.spines['left'].set_linewidth(2)
    ax.spines['bottom'].set_linewidth(2)
    plt.subplots_adjust(left=0.05, right=0.99)
    plt.tick_params(axis='both', which='both', direction='out', width=2, length=6, labelsize=ticklabelsize)
    ax.set_xlim([df[loc_col].values[0], tmpdf[loc_col].values[-1]])

    # adjust ylim
    if ylim:
        ax.set_ylim(ylim)

    # adjust axis
    if invert_yaxis:
        ax.invert_yaxis()
    if top_xaxis:
        ax.xaxis.tick_top()
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.xaxis.set_label_position('top')
    else:
        ax.spines['right'].set_visible(False)
        ax.spines['top'].set_visible(False)

    # adjust font size
    for label in (ax.get_xticklabels() + ax.get_yticklabels()):
        label.set_fontsize(ticklabelsize)

    # hide legend
    ax.legend().set_visible(False)
    plt.savefig(f'{outfile}', dpi=450)
    plt.close()


@click.command(context_settings=CONTEXT_SETTINGS)
@click.option('--infile', help='tsv文件,包含header')
@click.option('--chr-col', help='染色体列名')
@click.option('--loc-col', help='x轴值列名')
@click.option('--val-col', help='y轴值列名')
@click.option('--log-trans', is_flag=True, default=False, help='对val列的值取以10为底的对数')
@click.option('--neg-logtrans', is_flag=True, default=False, help='对val列的值取以10为底的负对数(画p值)')
@click.option('--outfile', help='输出文件,根据拓展名判断输出格式')
@click.option('--xlabel', help='输入散点图x轴标签的名称')
@click.option('--ylabel', help='输入散点图y轴标签的名称')
@click.option('--ylim', nargs=2, type=float, default=None, help='y轴的显示范围,如0 1, 默认不限定')
@click.option('--invert-yaxis',  is_flag=True, default=False, help='flag, 翻转y轴, 默认不翻转')
@click.option('--top-xaxis',  is_flag=True, default=False, help='flag, 把x轴置于顶部, 默认在底部')
@click.option('--cutoff', default=None, help='两列，第一列染色体号，第二列对应的阈值')
@click.option('--highlight', default=None, help='和infile相同格式的文件,在该文件中的点会在曼哈顿图中单独高亮出来,default=None')
@click.option('--ticklabelsize', help='刻度文字大小', default=10)
@click.option('--figsize', nargs=2, type=float, help='图像长宽, 默认15 5', default=(15, 5))
@click.option('--axlabelsize', help='x轴y轴label文字大小', default=10)
@click.option('--markersize', default=6, help='散点大小, default is 6', type=float)
@click.option('--chroms', default=None, help='只用这些染色体,e.g --chr 6 --chr X will only plot chr6 and chrX.', multiple=True)
@click.option('--fill-regions', default=None, help='fill between regions in this <bed file> (no header)')
@click.option('--windowsize', default=None, help='draw mean value in a specific window size', type=int)
def main(infile, chr_col, loc_col, val_col, log_trans, neg_logtrans, outfile,
         xlabel, ylabel, ylim, invert_yaxis, top_xaxis, cutoff, highlight, ticklabelsize,
         figsize, axlabelsize, markersize, chroms, fill_regions, windowsize):
    """
    \b
    曼哈顿图
    使用infile中的chr_col和loc_col列作为x轴, 对应的val_col值画在y轴
    输出outfile, 根据outfile指定的拓展名输出相应的格式
    别人的脚本，我稍微改了下，出图更好看
    """
    print(__doc__)
    print(main.__doc__)
    df = load_allchrom_data(infile, chr_col, loc_col, val_col, log_trans, neg_logtrans)
    if chroms:
        print('use chroms:\n%s' % '\n'.join(chroms))
        chroms = set(chroms)
        df = df.loc[df[chr_col].isin(chroms), :]
    if highlight:
        highlight = load_allchrom_data(highlight, chr_col, loc_col, val_col, log_trans, neg_logtrans)
    if fill_regions:
        fill_regions = pd.read_csv(fill_regions, sep='\t', header=None, names=['chrom', 'start', 'end'],
                                   dtype={'chrom': str, 'start': float, 'end': float})
    if cutoff:
        cutoff = load_cutoff(cutoff, log_trans, neg_logtrans)
 
    plot(df, chr_col, loc_col, val_col, xlabel, ylabel, ylim, invert_yaxis, top_xaxis, cutoff,
         highlight, outfile, ticklabelsize, figsize, axlabelsize, markersize, fill_regions, windowsize)

if __name__ == '__main__':
    main()
