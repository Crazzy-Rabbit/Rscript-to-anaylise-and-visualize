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
# Part of code are adopted from plot_smr script which provided by SMR
#
# Amendment:
#  2025/04/27
#    1. script completed 
#    2. first realeased
#
#  2025/06/04
#    1. fix the bug that generate two xlab
#    2. fix some error
#    3. Optimize the problem of gene and genename display overlap
#
# Usages:
#     source("plot_Locouszoom.R")
#     LZData <- ReadLocusZoomData(gwas="gwas_chrpos.gz", ld_info="plink.ld", snp="rs641221")
#     pdf('locuszoom.pdf',width = 6,height = 4)
#     plot_locuszoom(data=pltdt, genelist="glist_hg19_refseq.txt")
#     dev.off()
# ===========================================================================================//
is.installed <- function(mypkg){
    is.element(mypkg, installed.packages()[,1])
}
# check if package "TeachingDemos" is installed
if (!is.installed("TeachingDemos")){
    install.packages("TeachingDemos");
}
library(TeachingDemos)
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

GeneRowNum = function(GENELIST) {
    BP_THRESH = 0.03; MAX_ROW = 5
    # get the start and end position
    GENELIST = GENELIST[!duplicated(GENELIST$GENE),]
    START1 = as.numeric(GENELIST$GENESTART); 
    END1 = as.numeric(GENELIST$GENEEND)
    STRLENGTH = nchar(as.character(GENELIST$GENE))
    MIDPOINT = (START1 + END1)/2
    START2 = MIDPOINT-STRLENGTH/250; 
    END2 = MIDPOINT+STRLENGTH/250
    START = cbind(START1, START2); 
    END = cbind(END1, END2);
    START = apply(START, 1, min); 
    END = apply(END, 1, max)
    GENELIST = data.frame(GENELIST, START, END)
    GENELIST = GENELIST[order(as.numeric(GENELIST$END)),]
    START = as.numeric(GENELIST$START); END = as.numeric(GENELIST$END)
    # get the row index for each gene
    NBUF = dim(GENELIST)[1]
    ROWINDX = rep(1, NBUF)
    ROWEND = as.numeric(rep(0, MAX_ROW))
    MOVEFLAG = as.numeric(rep(0, NBUF))
    if(NBUF>1) {
        for( k in 2 : NBUF ) {
            ITERFLAG=FALSE
            if(START[k] < END[k-1]) {
                INDXBUF=ROWINDX[k-1]+1
            } else INDXBUF = 1
            if(INDXBUF>MAX_ROW) INDXBUF=1;
            REPTIME=0
            repeat{
                if( ROWEND[INDXBUF] > START[k] ) {
                    ITERFLAG=FALSE
                    INDXBUF=INDXBUF+1
                    if(INDXBUF>MAX_ROW) INDXBUF = 1
                } else {
                    ITERFLAG=TRUE
                }
                if(ITERFLAG) break;
                REPTIME = REPTIME+1
                if(REPTIME==MAX_ROW) break;
            }
            ROWINDX[k]=INDXBUF;

            if( (abs(ROWEND[ROWINDX[k]]-START[k]) < BP_THRESH)
            | ((ROWEND[ROWINDX[k]]-START[k])>0) ) {
                MOVEFLAG[k] = 1
                SNBUF = tail(which(ROWINDX[c(1:k)]==ROWINDX[k]), n=2)[1]
                MOVEFLAG[SNBUF] = MOVEFLAG[SNBUF] - 1
            }
            if(ROWEND[ROWINDX[k]]<END[k]) {
                ROWEND[ROWINDX[k]] = END[k]  }
        }
    }
    GENEROW = data.frame(as.character(GENELIST$GENE),
    as.character(GENELIST$ORIENTATION),
    as.numeric(GENELIST$GENESTART),
    as.numeric(GENELIST$GENEEND),
    ROWINDX, MOVEFLAG)
    colnames(GENEROW) = c("GENE", "ORIENTATION", "START", "END", "ROW", "MOVEFLAG")
    return(GENEROW)
}

# parmeters for plot
genemove=0.01; txt=1.1; cex=1.3; lab=1.1; axis=1; top_cex=1.2;

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

    if (is.null(genelist)) stop("Please provide the genelist file")
    xcenter=top_snp$POS;
    xchr=top_snp$CHR;
    xstart=(xcenter - flank)/1e6; 
    xend=(xcenter + flank)/1e6;

    glist=fread(genelist)
    glist[,2]=glist[,2]/1e6;
    glist[,3]=glist[,3]/1e6;    
    colnames(glist) = c("CHR", "GENESTART",  "GENEEND",  "GENE", "ORIENTATION")
    glist=glist[CHR==xchr & GENESTART >= xstart & GENEEND <= xend, ]
    generow = GeneRowNum(glist); # cols of generow: "GENE", "ORIENTATION", "START", "END", "ROW", "MOVEFLAG"
    num_row = max(as.numeric(generow$ROW));

    yMAX=ceiling(max(pXY, na.rm=T)) + 1;
    offset_map = ceiling(yMAX)/2;
    offset_map = max(offset_map, num_row * 2.5);
    dev_axis = 0.1*yMAX;
    if (dev_axis < 1.5) dev_axis=1.5;
    yaxis.min = -offset_map;
    yaxis.max = yMAX + 1;
    xmin=min(gwasBP,na.rm=T)-0.01; 
    xmax=max(gwasBP,na.rm=T)+0.01; 

    xlab=paste("Chromosome ", top_snp$CHR, " (Mb)")
    ylab=expression(-log[10] (italic(P)))
    #---------- plot GWAS p value ----//
    par(mar=c(5,5,3,2), xpd=TRUE)
    plot(gwasBP,pXY,pch=21,bg=color,col="gray30",cex=1.8,lwd=0.2,yaxt="n",xaxt="n",bty="n",
    xlab=xlab, ylab="", xlim=c(xmin,xmax), ylim=c(yaxis.min,yaxis.max ))
    xticks=round(seq(xmin,xmax,length.out=6),2)
    axis(1,at=xticks,lwd=1) 
    devbuf = yMAX/4
    axis(2,at=seq(0,yMAX,by=devbuf),labels=round(seq(0,yMAX,devbuf),0),lwd=1,las=1)
    mtext(ylab, side=2, line=3, at=(yMAX*1/2))
    segments(x0=min(gwasBP), y0=-0.5, x1=max(gwasBP), y1=-0.5, col="gray50", lwd=1, lty=2) 

    # top SNP
    points(top_snp$POS/1e6, -log10(top_snp$p), pch=23, bg="gold", cex=2, lwd=0.5)
    text(top_snp$POS/1e6, -log10(top_snp$p), labels=top_snp$SNP, pos=3, cex=0.8, offset=0.5)

    #-------- plot gene layer ----//    
    num_gene = dim(generow)[1]
    dist = offset_map / num_row;
    for (k in 1:num_row) {
        generowbuf = generow[which(as.numeric(generow[, 5]) == k), ]
        xstart = as.numeric(generowbuf[, 3])
        xend = as.numeric(generowbuf[, 4])
        snbuf = which(xend - xstart < 1e-3)
        if (length(snbuf) > 0) {
            xstart[snbuf] = xstart[snbuf] - 0.0025
            xend[snbuf] = xend[snbuf] + 0.0025
        }
        xcenter = (xstart+xend)/2
        xcenter = spread.labs(xcenter, mindiff=0.01, maxiter=1000, min=xmin, max=xmax)
        num_genebuf = dim(generowbuf)[1]
        for (l in 1:num_genebuf) {
            ofs=0.3
            if(l%%2==0) ofs=-0.8
            m = num_row - k
            ypos = m*dist + yaxis.min
            code = 1;
            if (generowbuf[l,2] == "+") code = 2;
            arrows(x0=xstart[l], y0=ypos, x1=xend[l], y1=ypos, code=code, length=0.07, ylim=c(yaxis.min, yaxis.max),
            col=colors()[75], lwd=1)
            movebuf = as.numeric(generowbuf[l,6]) * genemove
            text(x=xcenter[l]+movebuf, y=ypos, label=substitute(italic(genename), list(genename=as.character(generowbuf[l,1]))), pos=3, offset=ofs, col="black", cex=0.9)
        }
    }
    
    #----------------- plot legend ----//
    usr=par("usr");                    
    legend_width=0.02*(usr[2]-usr[1]);  # legend width set as 5% of fig region
    left_margin=0.02*(usr[2]-usr[1]);
    down_margin=0.05*(usr[4]-usr[3]);

    legend_x_left=usr[2]-legend_width-left_margin; 
    legend_x_right=usr[2]-left_margin;
    legend_y_top=usr[4]-down_margin;    
    legend_y_bottom=usr[4]-0.2*(usr[4]-usr[3])-down_margin;  
    legend_y_pos=seq(legend_y_bottom, legend_y_top, length.out=length(breaks)); 
    
    for (i in 1:(length(breaks)-1)) {
        rect(legend_x_left, legend_y_pos[i], legend_x_right, legend_y_pos[i+1], col=color_pal[i], border=NA)
    }
    text(x=legend_x_left-0.01*(usr[2]-usr[1]), y=legend_y_pos, labels=breaks, pos=2, cex=0.7, xpd=TRUE)
    text(x=(legend_x_left + legend_x_right)/2, y=legend_y_top+0.03*(usr[4]-usr[3]), labels=expression(italic(r)^2), cex=0.9, xpd=TRUE)
}
