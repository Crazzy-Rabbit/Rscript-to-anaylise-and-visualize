# 对选择信号进行Z检验，以判断显著性，P < 0.005
# 设置已知的 FST 值
fst <- read.table("fst_chinese-other.windowed.weir.fst", sep='\t', header=TRUE)
mean_fst <- mean(fst$WEIGHTED_FST)
sd_fst <- sd(fst$WEIGHTED_FST)
  
# 计算 Z 分数
z_score <- ((fst$WEIGHTED_FST - mean_fst) / sd_fst )
# 使用 pnorm() 函数计算双尾检验下的 P 值
p_value <- 2*pnorm(abs(z_score), lower.tail = FALSE)

# 输出结果
result_df <-data.frame(fst,z_score, p_value)
write.table(result_df, file = "output_table.txt", sep = "\t", 
            quote = FALSE, row.names = FALSE)


library(ggplot2)
#绘制选择信号值的频数分布直方图
fst <- read.table("fst_chinese-other.windowed.weir.fst", sep='\t', header=TRUE)
x <- (fst$WEIGHTED_FST)

df <- data.frame(x)
p1 = ggplot(df, aes(x)) + 
      geom_histogram(aes(y = after_stat(count)), 
                 breaks = seq(min(df$x), max(df$x), length.out = 100),
                 color = "DarkCyan", fill = "DarkCyan") +
      coord_flip() + #让图沿着纸面翻转180，
      theme_classic()+ # 去除灰色背景及网格线
      theme(axis.text.y = element_blank()) +
      labs( y = "Frequency") + xlab(NULL)
p1

library(ggplot2)
#绘制选择信号值的频数分布直方图
fst <- read.table("fst_chinese-other.windowed.weir.fst", sep='\t', header=TRUE)
x <- (fst$WEIGHTED_FST)

df <- data.frame(x)
p2 = ggplot(df, aes(x)) + 
     geom_histogram(aes(y = after_stat(count)), 
                 breaks = seq(min(df$x), max(df$x), length.out = 100),
                 color = "DarkCyan", fill = "DarkCyan") +
      theme_classic()+ # 去除灰色背景及网格线
      labs( y = "Frequency") + xlab(NULL) +
      theme(axis.text.x = element_blank())
p2

library("patchwork")
# 将三个图拼接在一起
(p2 + p1) + p3






## 如xpehh ihs这些已经标准化之后的数据
# 设置已知的 Z 分数(也就是标准化后的xpehh ihs)和显著性水平

xpehh <- read.table("9.xpehh",
                    sep='\t', header=FALSE)
z_score <- xpehh$V5
# 使用 pnorm() 函数计算 Z 分数对应的 P 值
p_value <- 2*pnorm(q = z_score, lower.tail = FALSE)
# 输出结果
result_df <-data.frame(xpehh, p_value)
write.table(result_df, file = "output_xpehh.txt", sep = "\t", 
            quote = FALSE, row.names = FALSE)


library(ggplot2)
#绘制选择信号值的频数分布直方图
xpehh <- read.table("9.xpehh",
                  sep='\t', header=FALSE)
x <- (xpehh$V5)
df <- data.frame(x)
p3 = ggplot(df, aes(x)) + 
  geom_histogram(aes(y = after_stat(count)), 
                 breaks = seq(min(df$x), max(df$x), length.out = 100),
                 color = "DarkCyan", fill = "DarkCyan") +
  theme_classic()+ # 去除灰色背景及网格线
  labs( y = "Frequency") + xlab(NULL) +
  theme(axis.text.x = element_blank())

p3
