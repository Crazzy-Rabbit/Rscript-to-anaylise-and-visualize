## circol 图

#SNP chr    pos Somatic cell score  Milk yield Fat percentage
#1 SNP1   1  59082        0.000244361 0.000484255    0.001379210
#2 SNP2   1 118164        0.000532272 0.000039800    0.000598951

#########先合并数据
library(CMplot)
# 读取选择信号结果文件，确保chr start end这三列的头文件为"CHROM","BIN_START","BIN_END"，染色体号都是一种
data1 <- read.table("fst_chinese-other.windowed.weir.fst", header = TRUE)
data2 <- read.table("ln_ratio.txt", header = TRUE)
data3 <- read.table("chinese_other.NC.xpclr", sep='\t', header = TRUE)

# 只保留FST和PI值区间相同的记录
# 两个画图时
# merged_data <- merge(fst_data, data2, 
#                     by=c("CHROM","BIN_START","BIN_END"))
# 3个画图时
merged_data <- merge(merge(data1, data2, 
                           by=c("CHROM","BIN_START","BIN_END")), 
                     data3, by=c("CHROM","BIN_START","BIN_END"))

######## 绘图
CMplot(merged_data,type="p",plot.type="c",LOG10=FALSE,outward=TRUE,
       col=matrix(c("#4DAF4A",NA,NA,"dodgerblue4","deepskyblue",NA,"dodgerblue1", "olivedrab3", "darkgoldenrod1"), nrow=3, byrow=TRUE),
       chr.labels=paste("Chr",c(1:29),sep=""),threshold=NULL,
       r=1.2,cir.chr.h=1.5,axis.cex=1,
       cir.band=1,file="jpg", file.name="",dpi=300,
       chr.den.col="black",file.output=TRUE,verbose=TRUE,
       width=10,height=10)
