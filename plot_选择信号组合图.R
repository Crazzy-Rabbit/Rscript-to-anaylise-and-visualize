## 选择信号组合图
library(ggplot2)
library(ggthemes)
library(RColorBrewer)

# 读取选择信号结果文件，确保chr start end这三列的头文件为"CHR","BP"，“value”染色体号都是一种
data1 <- read.table("wag_A-H.windowed.weir.fst",sep='\t', header = TRUE)
data2 <- read.table("A_H-Wag.norm.XPEHH",sep='\t', header = TRUE)
data3 <- read.table("wag_A-H-lnratio.txt", sep='\t', header = TRUE)

color_pal <- rev(colorRampPalette(brewer.pal(n=11, name = "Spectral"))(10))
color_selection <- color_pal[c(1, 2, 3, 8, 9)]
# 只保留FST和PI值区间相同的记录
if (exists("data3")){merged_data <- merge(merge(data1,data2,by=c("CHR","BP")),data3, by=c("CHR","BP"))
                    input_data <- merged_data[,c(3,1,2,4,6,8)]
                    names(input_data) <- c("SNP","CHR","BP","fst","XPEHH","pi")
} else {merged_data <- merge(data1, data2,by=c("CHR","BP"))
       input_data <- merged_data[,c(3,1,2,4,6)]
       names(input_data) <- c("SNP","CHR","BP","fst","pi")
       }

# 绘制组合图, 如果只是2种，则将color = XPEHH改为color = "black",任意色都可
ggplot(data = input_data, aes(x=fst, y=pi)) + 
  geom_point(aes(color = XPEHH), alpha = 0.8, size = 4) +
  geom_point(shape = NA) + 
  scale_color_gradientn(colors = color_selection) +
  labs(x=expression(paste(italic('F'),st)), y="-ln(θπ_W / θπ_AH)")+ # 看你的实际改
  geom_hline(yintercept = 1.0701, linetype = "dashed", color = "black") + # 阈值
  geom_vline(xintercept = 0.393674, linetype = "dashed", color = "black") +
  theme(axis.text = element_text(face="bold"))+
  theme_few()
