
##曼哈顿图
# install.packages('qqman')

#########需要一个5列的表格1列为序号  2列为SNP（rs） 3列为染色体  4列为位置  5列为Fst
#####  "#8DA0CB","#E78AC3","#A6D854","#FFD92F","#E5C494","#66C2A5","#FC8D62"

library('qqman')
data1 <- read.table("FST.csv",header = T,sep = ',') 
color_set <- c("#801e91","#344fa8","#f7cb34","#a8a8aa","#ffe4c7")

par(cex=0.9,font=2)       # 调整整个图的大小比例
 par(cex.lab=1.5)   # 调整坐标轴标题大小
par(cex.axis=1)    # 调整坐标轴刻度线大小
manhattan(data1,col=color_set, logp  = F,ylab='Fst',ylim=c(0,0.8),
          genomewideline=-log10(5e-800),suggestiveline = -log10(1e-800) )

abline(lty = 1 , h =0.255368, col = "red",lwd = 3)
#444444
##logp一般为F,若为T则y轴取值为-logp值  
##ylim=c(0,7) 可限制y轴的范围   
# col   :  线条的颜色
# lty   :  线条的类型
# lwd  :  线条的宽度
######常用参数
# suggestiveline  设置"suggestive"线的阈值，默认为-log10(1e-5)，因此如果不想要这个线，可以放大这个值
# genomewideline  设置"genome-wide significant"线的阈值，默认为-log10(5e-8)
# highlight   高亮感兴趣的SNP位点，  snps = c("51157","51158","51159")
# logp    设置是否对Pvalue去log10值
# annotatePval    注释低于指定p-value阈值的位点
# annotateTop 是否只注释低于指定p-value阈值位点中的top hit
############加与y轴相交的虚线  abline(lty = 2 , h = 0.42)



library(CMplot)

data1 <- read.table("IHS.csv",header = T,sep = ',') 
color_set <- c("#801e91","#344fa8","#f7cb34","#a8a8aa","#ffe4c7")
CMplot(data1, plot.type="m", LOG10=F,       
       chr.den.col=NULL, col = color_set,      
       threshold = 0.186813, threshold.col = "red", threshold.lwd= 2, threshold.lty =1,      
       amplify = FALSE, file.output=T, height=5, width = 10,     
       ylab = "iHS",
       ###ylab = expression(paste(italic('F'),st)),
       
       pch =".", cex =4, dpi = 600, file = "jpg",memo = "IHS")


## 可视化在每个染色体上选择信号的值
library(ggplot2)

data<-read.table("Fst_JBC-EU.windowed.weir.fst",header=T)
sc3 = subset(data,CHROM=="10")
p <- ggplot(sc3,aes(x=BIN_END/1000000,y=WEIGHTED_FST)) + 
  geom_point(size=0.5, colour="blue") + xlab("Physical distance (Mb)")+ ylab("Fst") + ylim(0,1)
p + theme_bw()
