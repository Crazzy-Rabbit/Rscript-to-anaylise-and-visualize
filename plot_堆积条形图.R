library(ggplot2)
library(ggbreak)
data = read.table("wagyu_all_dis.txt", sep='\t', header=T)
data$Region <- factor(data$Region, level=c("ncRNA_splicing","splicing","UTR5","ncRNA_exonic","UTR3","upstream",
                                           "downstream","ncRNA_intronic","exonic","intronic","intergenic"))
data$Type <- factor(data$Type, level=c("Both type", "DUP type", "DEL type"))
m_col = c("#93DAD1","#7290CC", "#9870CB")

ggplot(data, aes(y= count, x = Region, fill = Type))+ 
       geom_bar(stat = "identity", position = "stack")+ 
  theme_classic()+     
  theme(legend.position = "top") + 
       theme(axis.text.y = element_text(face="bold"))+
       theme(axis.text.x = element_text(face="bold"))+
       labs(x="", y="Number of CNVRs") +
  theme(axis.text.x.top=element_blank(),axis.line.x.top=element_blank(),
        axis.text.x = element_text(face="bold",hjust = 1))+
  theme(axis.text.y.right=element_blank(),axis.ticks.y.right=element_blank(),
        axis.text.y = element_text(face="bold"))+
  scale_y_continuous(expand = c(0,0))+
  scale_y_break(c(50,140),space=0.2,
                scales=1.5,expand=c(0,0))+
  scale_fill_manual(values=m_col)+
  guides(fill=guide_legend(title=NULL, byrow=F))

# 百分比堆积图
library(ggplot2) # 480 360
df = read.table("wagyu_all_dis.txt", sep='\t', header=T)
df$Type <- factor(df$Type, level=c("DEL type", "DUP type", "Both type"))
m_col = c("#EEBB47","#93DAD1","#6DB0D7","#9870CB",
           "#C477A6","#2F71A7","#F5E745","#D8793F","#C63581","#6A3D9A")

ggplot(df, aes( x = Type, y=percent, fill = Region))+
  geom_bar(stat = "identity")+ 
  theme_minimal() +
  theme(legend.position = "top") + 
  coord_flip()+
  guides(fill=guide_legend(title=NULL, ncol = 4, byrow = F)) +
  theme(axis.text.y = element_text(face="bold"))+
  theme(axis.text.x = element_text(face="bold"))+
  labs(x="", y="Percentage of CNVRs (%)") +
  scale_y_continuous(expand = c(0,0))+
  scale_fill_manual(values=m_col)
