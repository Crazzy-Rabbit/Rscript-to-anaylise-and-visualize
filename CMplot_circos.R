## circol 图

# 输入文件格式参考，当然，我是分别输入，然后用merge函数根据染色体和位置进行合并来的
#SNP     chr  pos          cell score  Milk yield   Fat percentage
# SNP1   1  59082        0.000244361 0.000484255    0.001379210
# SNP2   1 118164        0.000532272 0.000039800    0.000598951

data1 <- read.table("wag_A-H.windowed.weir.fst",sep='\t', header = TRUE)
data2 <- read.table("A_H-Wag.norm.XPEHH",sep='\t', header = TRUE)
data3 <- read.table("wag_A-H-lnratio.txt", sep='\t', header = TRUE)

merged_data <- merge(merge(data1, data2, 
                           by=c("CHR","BP")), 
                     data3, by=c("CHR","BP"))
input_data <- merged_data[,c(3,1,2,4,6,8)]

######## 绘图
CMplot(input_data,type="p",plot.type="c",LOG10=FALSE,outward=TRUE,
       col=matrix(c("#4DAF4A", NA, NA,   
                    "dodgerblue4","deepskyblue", NA,
                    "dodgerblue1", "olivedrab3", "darkgoldenrod1"), 
                    nrow=3, byrow=TRUE),
       chr.labels=paste("Chr",c(1:29),sep=""),
       threshold=NULL,r=1.5,cir.chr.h=1.5,
       cir.band=1,file="jpg", dpi=600,chr.den.col="black",
       file.output=T,verbose=TRUE,width=10,height=10)
