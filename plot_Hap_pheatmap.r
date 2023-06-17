# 不同组之间有缝隙，更加直观
library(pheatmap)
group = read.table("sample_plot.list.txt", row.names=1, stringsAsFactors = F) # 两列，1：ID，2：品种,ID与txt文件顺序一致
names(group) <- c("Group")

data=read.table("LRP2BP.SNP.biallele.txt",header=TRUE, stringsAsFactors = F) # 转置后的文件
data=data.matrix(data)

an_row = data.frame(Group=as.vector(group$Group))
rownames(an_row)=rownames(data)
ra_col <- list(Group=c(JPBC="#873186",Mongolian="#E20593",
                       Kazakh="#6BB93F",Yanbian="#18A2CA"))
# "#3364BC", "#000000", "#F37020", "#DBB71D"
gap_line <- c(11,21,32) # 数量划分，分开每组的热图

pheatmap(data,cluster_row=F,cluster_col=F,legend=F,
         show_rownames=FALSE,show_colnames=FALSE,
         annotation_legend=T,annotation_names_row=T,
         annotation_row=an_row,annotation_colors=ra_col,
         gaps_row=gap_line,
         color=c("#F7F8D5", "#BF3826"))
