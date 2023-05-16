## 选择信号组合图
library(ggplot2)
library(RColorBrewer)

# 读取选择信号结果文件，确保chr start end这三列的头文件为"CHROM","BIN_START","BIN_END"，染色体号都是一种
fst_data <- read.table("fst_chinese-other.windowed.weir.fst", header = TRUE)

data2 <- read.table("ln_ratio.txt", header = TRUE)

data3 <- read.table("chinese_other.NC.xpclr", sep='\t', header = TRUE)

# 只保留FST和PI值区间相同的记录
# 两个画图时
# merged_data <- merge(fst_data, data2, 
#                     by=c("CHROM","BIN_START","BIN_END"))

# 3个画图时
merged_data <- merge(merge(fst_data, data2, 
                           by=c("CHROM","BIN_START","BIN_END")), 
                     data3, by=c("CHROM","BIN_START","BIN_END"))

# 生成冷色调的渐变色
color_pal <- rev(colorRampPalette(brewer.pal(n=11, name = "Spectral"))(10))
color_selection <- color_pal[c(2, 3, 4, 8, 9)] # 1-10都代表一种颜色

# 绘制组合图
ggplot(data = merged_data, aes(x=WEIGHTED_FST, y=ln_ratio)) + 
  geom_point(aes(color = xpclr_norm), alpha = 1, size = 4) +
  geom_point(shape = NA) + #忽略点的轮廓
  scale_color_gradientn(colors = color_selection) +
  
  labs(# title="FST vs PI",
       x="FST",
       y="ln_ratio") +
  
  geom_hline(yintercept = 0.4, linetype = "dashed", color = "black") +
  geom_vline(xintercept = 0.17, linetype = "dashed", color = "black") +
  theme_classic()+ # 去除灰色背景及网格线
  theme(panel.border = element_rect(fill=NA, color="black", linetype ="solid")) #添加边框
