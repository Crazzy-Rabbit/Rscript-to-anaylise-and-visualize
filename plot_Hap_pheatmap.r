# 不同组之间有缝隙，更加直观
library(pheatmap)
group = read.table("sample_plot.list.txt", stringsAsFactors = F) ##两列，1：ID，2：品种
names(group) <- c("ID","Group")
rownames(group) <- group$ID
group$ID <- NULL

new_order <- c("JPBC", "Mongolian", "Kazakh", "Yanbian") # 新的组顺序
group$Group <- factor(group$Group, levels = new_order)

data2=read.table ("LRP2BP.SNP.biallele.txt", header = TRUE, stringsAsFactors = F) # 转置后的文件
data2=data.matrix(data2)

rowcol = c("#873186", "#E20593",  "#6BB93F", "#18A2CA")# "#3364BC", "#000000", "#F37020", "#DBB71D"
names(rowcol) <- unique(group$Group)
ra_col <- list(Group=rowcol)
my_annotation <- rowAnnotation(df=group,col=list(Group=rowcol),gp=gpar(fontsize=12)) # 添加注释条
gap_line <- c(11,21,32) # 数量划分，分开每组的热图

p = pheatmap(data2, cluster_row = FALSE,cluster_col = FALSE,
             gaps_row=gap_line,legend =FALSE,
             labels_col = rep("",ncol(data2)),labels_row=rep("",nrow(data2)),
             color=c("#F7F8D5", "#BF3826"),angle_col = "0")

p + my_annotation
