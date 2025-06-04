# ===========================================================================================//
# @Author  :    Loren Shi
# @Time    :    2025/04/27 10:37:43
# @File    :    plot_Locouszoom.R
# @Mails   :    crazzy_rabbit@163.com
# @line    :    https://github.com/Crazzy-Rabbit
#
# R script to draw regional plot for GWAS indenpendent SNP
#
# Notes:
#   GWAS sums: the data should contain following columns: "CHR" "SNP" "p"
#   LD info: users can get LD info of target SNP by PLINK, follow cmd can used:
#            plink --bfile $bfile \
#            --ld-snp $snp \
#            --ld-window-kb 2000 \
#            --ld-window 99999 \
#            --ld-window-r2 0 \
#            --r2 \
#            --out r2_2000kb
#
# Amendment:
#  2025/04/27
#  1. script completed 
#  2. first realeased
#  2025/06/04
#  1. fixed the bug that generate two xlab
#  2. fixed some error
# Usages:
#     source("plot_Locouszoom.R")
#     LZData <- ReadLocusZoomData(gwas="gwas_chrpos.gz", ld_info="plink.ld", snp="rs641221")
#     pdf('locuszoom.pdf',width = 6,height = 4)
#     plot_locuszoom(data=pltdt, genelist="glist_hg19_refseq.txt")
#     dev.off()
# ===========================================================================================//
library(data.table)
ReadLocusZoomData <- function(gwas, ld_info, snp, flank=500000){
    gwas=fread(gwas)
    if(!all(c("SNP", "p", "CHR") %in% names(gwas))) stop("The gwas you provide not contains columns SNP, CHR, and p")
    gwas=gwas[,c("CHR", "SNP", "p")]
    
    ld=fread(ld_info, select=c(2, 5:7))
    if(!all(c("BP_A", "BP_B", "SNP_B", "R2") %in% names(ld))) stop("Please generate ld file using plink")
    names(ld)=c("BP_A", "POS", "SNP", "R2")

    top_snp=subset(gwas, SNP==snp)
    top_snp$POS=unique(ld$BP_A)

    #-------------- extract SNP LD info ---//
    snp_ld=merge(gwas,ld,by="SNP")
    region_data=subset(snp_ld, POS >= (top_snp$POS-flank) & POS <= (top_snp$POS+flank))
    region_data=region_data[order(region_data$POS),]
    
    return_list=list(topsnp=top_snp, region_dt=region_data)
    return(return_list)
}

plot_locuszoom <- function(data, genelist, flank=500000) {
    #-------------- set color ---//
    color_func=colorRampPalette(c("#14128c","#29d8ca","#065f1a","#ec7807","#fc1403"));
    breaks=c(0,0.2,0.4,0.6,0.8,1.0);
    color_pal=color_func(length(breaks)-1)
    region_data=data$region_dt; 
    region_data$color=color_pal[cut(region_data$R2, breaks=breaks, include.lowest=TRUE)];
    
    #------------- plot parm ---//
    top_snp=data$topsnp;
    gwasBP=region_data$POS/1e6; 
    pXY=-log10(region_data$p); 
    color=region_data$color; 

    yMAX=ceiling(max(pXY));
    offset_gene=yMAX/4;
    dev_axis=1.5;
    xmin=min(gwasBP,na.rm=T)-0.01; 
    xmax=max(gwasBP,na.rm=T)+0.01; 
    ymin=-offset_gene-dev_axis; 
    ymax=yMAX;

    xlab=paste("Chromosome ", top_snp$CHR, " (Mb)")
    ylab=expression(-log[10] (italic(P)))
    
    #---------- plot start ----//
    par(mar=c(5,5,3,2), xpd=TRUE)
    plot(gwasBP,pXY,pch=21,bg=color,col="gray30",cex=1.8,lwd=0.2,yaxt="n",xaxt="n",bty="n",
    xlab=xlab, ylab="", xlim=c(xmin,xmax), ylim=c(ymin,ymax))
    xticks=round(seq(xmin,xmax,length.out=6),2)
    axis(1,at=xticks,lwd=1) 
    axis(2,at=seq(0,yMAX,by=yMAX/4),labels=round(seq(0,yMAX,yMAX/4),0),lwd=1,las=1)
    mtext(ylab, side=2, line=3, at=(yMAX*1/2))
    segments(x0=min(gwasBP), y0=-0.5, x1=max(gwasBP), y1=-0.5, col="gray50", lwd=1, lty=2) 

    # top SNP
    points(top_snp$POS/1e6, -log10(top_snp$p), pch=23, bg="gold", cex=2, lwd=0.5)
    text(top_snp$POS/1e6, -log10(top_snp$p), labels=top_snp$SNP, pos=3, cex=0.8, offset=0.5)

    #-------- plot gene ----//
    if (is.null(genelist)) stop("Please provide the genelist file")
    glist=fread(genelist, col.names=c("CHR", "start", "end", "GENE", "strand"))
    xcenter=top_snp$POS;
    xchr=top_snp$CHR;
    xstart=xcenter - flank; 
    xend=xcenter + flank;
    generow=glist[CHR == xchr & start >= xstart & end <= xend, ]
    generow$start=generow$start/1e6; 
    generow$end=generow$end/1e6;

    # plot gene layer
    generow[, layer := 1]; 
    generow[, x_center := (start+end)/2]
    if(nrow(generow) > 1) {
        for(i in 2:nrow(generow)) {
            overlap=generow[1:(i-1), any(end > generow$start[i] & start < generow$end[i])]
            current_layer=1
            while(any(overlap)) {
                current_layer=current_layer + 1
                same_layer_genes=generow[1:(i-1)][layer == current_layer]
                if(nrow(same_layer_genes) > 0) { overlap <- any(same_layer_genes$end > generow$start[i] & same_layer_genes$start < generow$end[i]) } 
                else { overlap <- FALSE }
            }
            generow$layer[i]=current_layer
        }
    }
    numrows=max(generow$layer)
    axis.start=ymin/2-1
    total_lay=abs(offset_gene+dev_axis)/5
    if (numrows %% 2==1){
        median_layer=(numrows+1)/2
        generow[, ypos := axis.start+(layer-median_layer)*0.8]
    } else {
        median_upper=numrows/2
        generow[, ypos := axis.start+(layer-median_upper-0.5)*0.8*total_lay]
    }

    for(i in 1:nrow(generow)) {
        arrow_code <- ifelse(generow$strand[i] == "+", 2, 1)
        glen <- generow$end[i]-generow$start[i]
        if (glen < 0.001) {
            arrows(x0=generow$x_center[i]-0.0005, y0=generow$ypos[i], x1=generow$x_center[i]+0.0005, y1=generow$ypos[i], length=0.07, code=arrow_code, col="darkgoldenrod", lwd=1.5)} 
        else {
            arrows(x0=generow$start[i], y0=generow$ypos[i], x1=generow$end[i], y1=generow$ypos[i], length=0.07, code=arrow_code, col="darkgoldenrod", lwd=1.5)}
        text(x=generow$x_center[i], y=generow$ypos[i], substitute(italic(gene), list(gene=generow$GENE[i])), pos=3, offset=0.3, cex=0.8, col="black")
    }
    
    #----------------- plot legend ----//
    usr=par("usr");                    
    legend_width=0.02*(usr[2]-usr[1]);  # legend width set as 5% of fig region
    left_margin=0.10*(usr[2]-usr[1]);
    down_margin=0.10*(usr[4]-usr[3]);

    legend_x_left=usr[2]-legend_width-left_margin; 
    legend_x_right=usr[2]-left_margin;
    legend_y_bottom=usr[4]-0.3*(usr[4]-usr[3])-down_margin;  
    legend_y_top=usr[4]-down_margin;                           
    legend_y_pos=seq(legend_y_bottom, legend_y_top, length.out=length(breaks)); 
    
    tit=expression(italic(r)^2)
    for (i in 1:(length(breaks)-1)) {
        rect(legend_x_left, legend_y_pos[i], legend_x_right, legend_y_pos[i+1], col=color_pal[i], border=NA)
    }
    text(x=legend_x_left, y=legend_y_pos, labels=breaks, pos=2, cex=0.7, xpd=TRUE)
    text(x=legend_x_left, y=legend_y_top, labels=tit, pos=3, cex=0.9)
}
