setwd("D:/百度网盘同步文件/BaiduSyncdisk/21-24吉大硕士/2021-2024毕业设计/22.09.26-牛-毕业/06_CNV与SNP比较")
library(ggplot2)
library(ggthemes)
library(viridis) # 颜色
library(ggpval) # P值
library(eoffice) # 加载包

a=read.table("chart-selection_all-CNV.txt",header=T)

p = ggplot(a,aes(x=G,y=FST,fill=G))+
  geom_violin(width =.6)+
  geom_boxplot(fill ="white", color="grey", width = .1, outlier.size = 0.4)+
  geom_hline(yintercept = 0.4318, linetype = "dashed", color = "black")+
  labs(x="",y=expression(paste(italic('F')[ST],'-SNP')))+
  scale_fill_viridis(discrete=TRUE, alpha=0.9) +
  theme_few()+
  theme(legend.position="none")+
  theme(axis.text=element_text(face="bold"))

## 默认为Wilcoxon秩和检验
add_pval(p, pairs = list(c(1, 2)), response = 'FST')

topptx(filename = "CNV周围SNP的FST.pptx")

## Wilcoxon秩和检验,检查两组数据平均值是否有显著性
all = read.table("all-cnv.windowed.weir.fst",header=T)
select = read.table("CNV-selection.windowed.weir.fst",header=T)

x = all$WEIGHTED_FST
y = select$WEIGHTED_FST
wilcox.test(x,y,alternative="less",exact=FALSE,correct=FALSE)
