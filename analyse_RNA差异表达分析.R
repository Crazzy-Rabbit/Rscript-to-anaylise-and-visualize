############################
# 安装包
# if (!requireNamespace("BiocManager", quietly = TRUE))
# install.packages("BiocManager")

# BiocManager::install("DESeq2")
# install.packages("corrplot")
# install.packages("PerformanceAnalytics")
# install.packages("factoextra")

#######  venn图  ######
# install.packages("VennDiagram")
###
a =  read.table("all_fcount.matrix.txt", header = T)

a1=subset(a,SRR13107018_sort.bam>=1 & SRR13107019_sort.bam>=1 & SRR13107020_sort.bam>=1)
a2=subset(a,SRR13107021_sort.bam>=1 & SRR13107022_sort.bam>=1 & SRR13107023_sort.bam>=1)
GENE1=a1$Geneid
GENE2=a2$Geneid
x=as.data.frame(a1,a2)
x=paste(a1,a2)

library(openxlsx)
SE <- read.xlsx("se.xlsx")
RI <- read.xlsx("ri.xlsx")
MXE <- read.xlsx("mxe.xlsx")
A5SS <- read.xlsx("a5ss.xlsx")
A3SS <- read.xlsx("a3ss.xlsx")
SE=SE$GeneID
RI=RI$GeneID
MXE=MXE$GeneID
A5SS=A5SS$GeneID
A3SS=A3SS$GeneID

x=paste(SE,RI,MXE,A5SS,A3SS)

library(VennDiagram)
venn.diagram(  x = list(SE,RI,MXE,A5SS,A3SS),
  category.names = c("SE","RI","MXE","A5SS","A3SS"),
 filename = 'venn.png',
 output=TRUE,
  lwd = 1,
  lty =1,
  col = c('red', 'blue', 'green', 'orange','purple'),
  fill = c('red', 'blue', 'green', 'orange','purple'),
  cex = 0.8,
  cat.cex = 1, 
  fontface = "bold",
  cat.col = c('red', 'blue', 'green', 'orange','purple')
) 


################  FPKM的计算  #####################
# install.packages("tidyverse")
# install.packages("data.table")
####
rm(list=ls()) 
options(stringsAsFactors = F)  
library(tidyverse) 
# ggplot2 stringer dplyr tidyr readr purrr  tibble forcats 
library(data.table)
a1 <- fread('all.featurecounts.txt', header = T, data.table = F)
### counts矩阵的构建 
counts <- a1[,7:ncol(a1)] 
rownames(counts) <- a1$Geneid

### 从featurecounts 原始输出文件counts.txt中提取Geneid、Length(转录本长度)， 
geneid_efflen <- subset(a1,select = c("Geneid","Length"))        
colnames(geneid_efflen) <- c("geneid","efflen")   
geneid_efflen_fc <- geneid_efflen
dim(geneid_efflen) 
efflen <- geneid_efflen[match(rownames(counts),                               
                              geneid_efflen$geneid),"efflen"] 

###################################### FPKM/RPKM (Fragments/Reads Per Kilobase Million )  每千个碱基的转录每百万映射读取的Fragments/reads 
counts2FPKM <- function(count=count, efflength=efflen){    
  PMSC_counts <- sum(count)/1e6   #counts的每百万缩放因子 (“per million” scaling factor) 深度标准化   
  FPM <- count/PMSC_counts        #每百万reads/Fragments (Reads/Fragments Per Million) 长度标准化   
  FPM/(efflength/1000)                                       
}
FPKM <- as.data.frame(apply(counts,2,counts2FPKM))
colnames(FPKM) <- c("Simmental_1","Simmental_2","Simmental_3","Wagyu_1","Wagyu_2","Wagyu_3") # 修改列名
FPKM <- FPKM[rowSums(FPKM)>1,] # 去除全部为0的列
colSums(FPKM) 


##########当前推荐使用 TPM 进行相关性分析、PCA分析等 (Transcripts Per Kilobase Million)  每千个碱基的转录每百万映射读取的Transcripts 
counts2TPM <- function(count=count, efflength=efflen){   
  RPK <- count/(efflength/1000)   #每千碱基reads (reads per kilobase) 长度标准化   
  PMSC_rpk <- sum(RPK)/1e6        #RPK的每百万缩放因子 (“per million” scaling factor ) 深度标准化   
  RPK/PMSC_rpk                       
}
TPM <- as.data.frame(apply(counts,2,counts2TPM))
colnames(TPM) <- c("Simmental_1","Simmental_2","Simmental_3","Wagyu_1","Wagyu_2","Wagyu_3")# 修改列名
TPM <- TPM[rowSums(TPM)>1,] # 去除全部为0的列
colSums(TPM)

###########################    Spearman相关性分析 使用TPM值  ################################
sp.data<- cor(TPM, method = "spearman")
# 图展示
library(corrplot)
corrplot(sp.data,
         order = "AOE", # 指定相关系数排序的方法，可以是特征向量角序(AOE)、第一主成分顺序(FPC)、层次聚类顺序(hclust)
         type = "full", # 展示类型。默认为全显full，还有upper和lower
         addCoef.col = "grey")# 添加相关系数值

# hclust聚类展示 , 有框框
corrplot(sp.data, order = "hclust", addrect = 2, rect.col = "black",hclust.method = "ward.D2")
## 表格展示
library(PerformanceAnalytics)
chart.Correlation(sp.data,histogram = T,pch=19)

###################### PCA  使用TPM值 ############################
data <- t(TPM)
data.pca <- prcomp(data, scale. = T)  #对数据标准化后做PCA，这是后续作图的文件 
summary(data.pca)

write.table(data.pca$rotation, file="PC.xls", quote=F, sep = "\t") 

write.table(predict(data.pca), file="newTab.xls", quote=F, sep = "\t") 

pca.sum=summary(data.pca) 
write.table(pca.sum$importance, file="importance.xls", quote=F, sep = "\t") 

library(factoextra)
group=c("M_Han",rep("M_DP",3),rep("L_Han",3),"L_DP","M_Han","M_Han","L_DP","L_DP")
fviz_pca_ind(data.pca, col.ind=group, 
             mean.point=F,
             label = "none",
             addEllipses = T,
             legend.title="Groups",
               ellipse.type="confidence", 
              ellipse.level=0.9,
             palette = c("#CC3333", "#339999",'red','blue'))+
  theme(panel.border = element_rect(fill=NA,color="black", size=1, linetype="solid"))




################################ DESeq2 ##################################

##  数据读入和处理
rm(list=ls()) 
countdata<- read.table("all_fcount.matrix.txt", header=TRUE,row.names = 1)
head(countdata) 

##  过滤低丰度counts
##  过滤featurecounts后，每个样本计数小于等于10的！！！！！！！
countdata.filter<-countdata[rowSums(countdata)>=1&apply(countdata,1,function(x){all(x>=10)}),]
head(countdata.filter) 
dim(countdata.filter)

#####################  dds矩阵的创建 ####################
library(DESeq2)
condition <- factor(c(rep("Zebu",5),rep("Holstein",5)))
coldata <- data.frame(row.names=colnames(countdata.filter), condition)
dds <- DESeqDataSetFromMatrix(countData=countdata.filter, colData=coldata, design=~condition)


###############  PCA分析 使用对dds矩阵处理后的vst或rld值#################### 
#计算每个样本的归一化系数
vsd <- vst(dds,blind = FALSE)  ## 方差稳定变换
names(colData(vsd))  # 样本信息的列名,多了1列sizeFactor，colData(vsd)$sizeFactor
names(rowData(vsd))   # 基因信息的列名,多了4列

rld <- rlog(dds,blind = FALSE)  ## 正则化对数变换
names(colData(rld))  # 样本信息的列名,多了1列sizeFactor，colData(vsd)$sizeFactor
names(rowData(rld))
# rlog函数将count data转换为log2尺度，以最小化有small counts的行的样本间差异，并使library size标准化
## vst函数快速估计离散趋势并应用方差稳定变换。
## 数据集小于30个样品可以用rlog，数据集大于30个样品用vst，因为rlog速度慢
# 转换的目的是，为了确保所有基因有大致相同的贡献
plotPCA( DESeqTransform(raw), intgroup=c("condition"))+theme_bw()+ theme(panel.grid.major = element_blank(), #删除主网格线
                                                            panel.grid.minor = element_blank())
plotPCA(vsd, intgroup=c("condition"))
plotPCA(rld, intgroup=c("condition"))



####### DESeq2进行差异分析 #####
dds <- DESeq(dds)
resdata<- results(dds,contrast = c("condition","Zebu","Holstein"))##此为前比后
table(resdata$padj<0.05 ) # Benjamini-Hochberg矫正后的p<0.05的基因数！！！！！！！
res_padj <- resdata[order(resdata$padj), ]  ##按照padj(矫正后的p值)列的值排序

write.table(res_padj,"diffexpr_padj_results.txt",quote = F,sep = '\t')#### 将结果文件保存到本地，打开在第一列头加gene


################   获取DEseq标准化的 counts   ################
#获取 normalized_counts
normalized_counts <- as.data.frame(counts(dds, normalized=TRUE))
write.csv(normalized_counts, file="normalized.csv")



####### DESeq2分析中得到的resdata进行绘制火山图  #####
rm(list=ls())  
resdata <- read.table("diffexpr_padj_results.txt",header = T,sep = '\t',row.names = 1)### 加载DESeq2中生成的resdata文件
resdata$label <- c(rownames(resdata)[1:10] ,rep(NA,(nrow(resdata)-10)))##对前10个基因进行标注

library(ggplot2)
ggplot(resdata,aes(x=log2FoldChange,y=-log10(padj))) +
##横向水平参考线，显著性--p值
geom_hline(yintercept = -log10(0.05),linetype = "dashed",color = "#999999")+
##纵向垂直参考线，差异倍数--foldchange
geom_vline(xintercept = c(-1 , 1),linetype = "dashed", color = "#999999")+

geom_point(aes(size = -log10(padj),color = -log10(padj))) +
scale_color_gradientn(values = seq(0,1,0.2),
                       colors = c("#39489f","#39bbec","#f9ed36","#f38466","#b81f25"))+
scale_size_continuous(range = c(0,3))+
  
###  theme_grey()为默认主题，theme_bw()为白色背景主题，theme_classic()为经典主题
theme_bw()+
theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = c(0.08,0.9),
        legend.justification = c(0,1))+
guides(col = guide_colourbar(title = "-Log10_q-value"),
         size = "none")+

geom_text(aes(label=c(label),color = -log10(padj)), size = 3, vjust = 1.5, hjust = 1)+

xlab("Log2FC")+ylab("-Log10(FDR q-value)") 
ggsave("vocanol_plot.pdf", height = 9 , width = 10)
  


####### 筛选差异基因 #####
subset(resdata,pvalue < 0.05) -> diff  ## 先筛选pvalue < 0.05的行！！！！！
subset(diff,log2FoldChange < -0.585) -> down  ## 筛选出下调的,1.5倍
subset(diff,log2FoldChange > 0.585) -> up  ## 筛选出上调的，1.5倍
dim(down) # 查看数据维度，即几行几列
dim(up)

#导出上、下调基因的那一列
up_names<-rownames(up)
write.table(up_names,'up_gene.txt',quote = F,sep = '\t',row.names = F)
down_names <- rownames(down)
write.table(down_names,'down_gene.txt',quote = F,sep = '\t',row.names = F)


#######  表达矩阵探索,选取差异表达的基因做热图  deseq后的排序文件 ######
library(pheatmap)
choose_gene=head(rownames(res_padj),50)  
choose_matrix=countdata.filter[choose_gene,]  #抽取差异表达显著的前50个基因
choose_matrix=t(scale(t(choose_matrix)))  #用t函数转置，scale函数标准化

png(filename = "DEG_pheatmap.png", width = 600, height = 1000)
pheatmap(choose_matrix)
dev.off()

