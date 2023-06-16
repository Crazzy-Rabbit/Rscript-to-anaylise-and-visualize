library(pheatmap)
library(ComplexHeatmap)

# setwd("D:/生信/夜雨声烦/硕士/毕业论文/22.09.26-牛-毕业/22.10.07-文章实验/22.11.17-gene单倍型/单倍型图")

group = read.table("sample_plot.list.txt", stringsAsFactors = F) ##两列，1：ID，2：品种
names(group) <- c("ID","GroupClass")
rownames(group) <- group$ID
group$ID <- NULL

new_order <- c("JPBC", "Mongolian", "Kazakh", "Yanbian") # 新的组顺序
group$GroupClass <- factor(group$GroupClass, levels = new_order)

data2=read.table ("LRP2BP.SNP.biallele.txt", header = TRUE, stringsAsFactors = F) # 转置后的文件，ID这些头文件去掉
data2=data.matrix(data2)

rowcol = c("#873186", "#E20593",  "#6BB93F", "#18A2CA") # "#3364BC", "#000000", "#F37020", "#DBB71D"
names(rowcol) <- unique(group$GroupClass)
ra_col <- list(GroupClass=rowcol)

my_annotation <- rowAnnotation(df=group,col=list(GroupClass=rowcol),gp=gpar(fontsize=12)) # 添加注释条

my.heatmap <- Heatmap(matrix=data2,cluster_rows=F,cluster_columns=F,
                      show_row_names=F,show_column_names=F,
                      show_row_dend=F,show_column_dend=F,use_raster=F,
                      col = c("#F7F8D5", "#BF3826"),#修改两种单倍型颜色 # "#357546", "#daa521"
                      left_annotation = my_annotation,
                      show_heatmap_legend = FALSE)
                      # bottom_annotation = ta, 在图的底部加注释，比如：在外显子还是内含子上

my.heatmap
