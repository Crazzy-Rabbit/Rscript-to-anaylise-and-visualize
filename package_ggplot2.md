##### 1.绘图函数
```
geom_line        #折线图
geom_point       #散点图
geom_bar         #条形图
geom_boxplot     #箱型图
geom_jitter      #抖动点
geom_violin      #小提琴图
geom_density     #密度图
geom_histogram   #直方图
```
散点图
```
ggplot(data,aes(x,y,
               fill,color,group))+
      geom_point(size, stroke, alpha, shape)

# shape        形状，1-25可选，20以上可设置填充和边框
# size         点的大小，倍数
# stroke       调整轮廓粗细
# alpha        透明度，一般是填充色透明度
```
条形图
```
ggplot(data,aes(x,y,
               fill,color,group))+
      geom_bar(stat='identity', position='stack', width)

#stat         默认为count，一般指定indetity
#position     位置调整，stack为堆叠，dodge为并行摆放，fill为按比例堆叠
#width        条带宽度
```
#### 2.图形调整参数
```
# 调整颜色、填充色和形状
scale_fill_manual(values=)
scale_color_manual(values=)
scale_shape_manual(values=)
scale_color_gradient(low = "SpringGreen", high = "OrangeRed")    # 设置连续色，2种

library(RColorBrewer)
m_col = brewer.pal(9,"Set1")
scale_color_gradientn(colors=m_cols)                             # 设置连续色，N种

# 轴标签、图例调整
scale_x_discrete(limits = unique(data$Source1))+                 # 固定X轴出现顺序和读入表格一致
scale_y_continuous(labels=percent)                               # y轴改为百分比形式
scale_x_continuous(expand=c(0.02,0),breaks = c(seq(0,29, by=2))) # 设置X轴标签为0，29间隔为2
theme(axis.text = element_text(face="bold", angle=45, hjust=1))  # 加粗、旋转XY标签，可用axis.text.x单独设置
labs(x="", y=" ")                                                # 设置XY轴标签

theme(lengend.position="none")                                   # 去除/修改图例位置，top,right,left,bottom等可用
theme(lengend.position=c(0.5,0.5))                               # 调整图例位置
guides(fill=guide_legend(title=NULL, byrow=F))                   # 去除图例
guides(col=F)                                                    # 去除图例
labs(color=" ")                                                  # 去除/修改图例标题

# 添加XY轴相应位置虚线
geom_hline(yintercept = 0.4, linetype = "dashed", color = "black")
geom_vline(xintercept = 0.17, linetype = "dashed", color = "black")


# 主题调整
默认主题
theme_classic() # 去除灰色背景和线，但只有左下边框
theme_bw()      # 去除灰色背景，有所有边框

library(ggthemes)
theme_few()     # 去除灰色背景和线，有全部边框
theme_base()    # 去除灰色背景和线，有全部边框，且放大XY轴标签
theme_minimal() # 去除灰色背景，只有网格线和图形
```
#### 坐标轴截断
```
library(ggbreak)

scale_y_break(c(100000,250000), space=0.2, scales=1, expand=c(0,0)) # 设置Y轴（100000，250000）位置截断，scales调整截断后比例
scale_x_break(c(100000,250000), space=0.2, scales=1, expand=c(0,0)) # X轴同理
```
#### 数据分组
```
facet_wrap(~gene)    # 比如这里对gene列进行分组可视化，放在一个图中
```

