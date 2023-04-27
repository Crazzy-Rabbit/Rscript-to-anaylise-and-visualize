
# 做箱型图


a=read.table("1-ROH.txt",header=T)

a$Breed <- factor(a$Breed,levels=c("Angus","Holstein","Simmental","Shorthorn",
                             "Charolais","Mishima-Ushi","Hanwoo","JPBC","Kazakh",
                             "Mongolian","Yanbian","Wenling","Brahman")) ##修改图例顺序
#加载包
library(ggplot2)
library(RColorBrewer)
#作图
p = ggplot(a,aes(x=Breed,y=length,fill=Breed))+  
  geom_boxplot()+
  
   # ylim(0,0.02) +
  
  theme_bw()+ # 去除灰色背景
  theme(panel.border = element_rect(fill=NA,color="black", 
                                    size=0.5, linetype ="solid")) #添加边框


p + labs(x="Breed",y = "Length of ROH per individual(Mb)")+ 
   # theme(axis.text.x = element_blank()) + ## 去除坐标轴刻度标签\
  
  theme(axis.text.x = element_text(angle = 60, hjust = 1, vjust = 1)) +
  
   theme(legend.position = 'none')#去除图例


### 条形图
library(ggplot2)

# 创建数据框
df <- read.table("hohe.txt", header = T)
df$Breed <- factor(df$Breed,levels=c("Angus","Holstein","Simmental","Shorthorn",
                                   "Charolais","Mishima-Ushi","Hanwoo","JPBC","Kazakh",
                                   "Mongolian","Yanbian","Wenling","Brahman"))

# 将数据框转换为长格式
library(tidyr)
df_long <- pivot_longer(df, cols = c("HO", "HE"), names_to = "Category", values_to = "Value")

# 绘制条形图
ggplot(df_long, aes(x = Breed, y = Value, fill = Category)) +
  geom_bar(stat = "identity", position = "dodge",width = 0.5) +
  
  theme_bw()+ # 去除灰色背景
  theme(panel.border = element_rect(fill=NA,color="black", 
                                    size=0.5, linetype ="solid")) + #添加边框
  
  theme(legend.position = c(0.07, 0.9)) +
  
  theme(axis.text.x = element_text(angle = 60, hjust = 1, vjust = 1)) + 

  labs(x = "", y = "Heterozygosity") +
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) 





