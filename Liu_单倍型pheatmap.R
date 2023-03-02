library(pheatmap)
library(ComplexHeatmap)

setwd("D:/桌面/毕业论文/22.09.26-牛-毕业/22.10.07-文章实验/22.11.17-gene/单倍型图")

group = read.table("sample_plot.list.txt", stringsAsFactors = F) ##两列，1：ID，2：品种
rownames(group) <- group$V1
group$V1 <- NULL
# names(group) <- c("breed")
data2=read.table ("LAMA1.SNP.biallele.txt", header = TRUE, stringsAsFactors = F)
data2=data.matrix(data2)

rowcol = c("gold", "orange",  "gray", "#649ca4"  )
# "Burlywood1", "yellow", "green", "orange", 
# "darkorchid4", "beige", "bisque", "aliceblue", 
# "azure", "aquamarine", "SlateBlue", "Gold2",
# "brown", "DarkSalmon", "Honeydew2", "DarkCyan", "VioletRed2"
names(rowcol) = names(table(group$V2))
names(table(group$V2))

#ta <- HeatmapAnnotation(df = groupcol, col = list(V2=colcol))
ra <- rowAnnotation(df = group, col = list(V2=rowcol))

my.heatmap <- Heatmap(matrix = data2,  cluster_rows = F, cluster_columns = F,
                      show_row_names = FALSE, show_column_names = FALSE, 
                      show_row_dend = FALSE, show_column_dend = FALSE,
                      #修改两种单倍型颜色
                      use_raster = F,
                      col = c("#357546", "#daa521")) # bottom_annotation = ta, 在图的底部加注释，比如：在外显子还是内含子上
my.heatmap + ra
