library(ggplot2)
library(openxlsx)
library(RColorBrewer)
library(ggthemes)
library(patchwork)

phy.cols <- c("#1B9E77","#D95F02","#7570B3","#93DAD1", "#7290CC", "#9870CB")

kegginput <- read.xlsx("kegg.xlsx")
x=kegginput$logp
y=factor(kegginput$Term, levels=kegginput$Term)

# 这个是气泡图，但是我把keggpathway名字放在里图中，好看呢
p1 = ggplot(kegginput,aes(x=x,y=y))+ 
     geom_point(aes(size=Count,color=-0.5*log(pvalue)))+
     geom_text(aes(x=0, y=y,label=y, color=-0.5*log(pvalue)), 
               hjust=(0))+
     scale_color_gradient(low = "#1597A5", high = "#F66F69")  + 
     theme_bw()+
     labs(size="Count", color=expression(-log[10](pvalue)), title="KEGG pathway", x=expression(-log[10](pvalue)), y="")+
     theme(axis.text.x=element_text(face="bold"),
           axis.ticks = element_blank(),
           axis.text.y=element_blank())
p1

goinput <- read.xlsx("go.xlsx")
x1=goinput$logp
y1=factor(goinput$Term, levels=goinput$Term)
# 这个是柱状图+气泡图，但是我把goterm名字放在柱子上，好看呢
p2 = ggplot(goinput, aes(x=x1,y=y1))+ 
  geom_bar(stat="identity",width = 0.5,position = position_dodge(0.7),
           aes(fill=-0.5*log(pvalue)))+
  geom_point(aes(size=Count,color=-0.5*log(pvalue)), color="gray")+
  geom_text(aes(x=0, y=y1, label=y1), color="black",
            hjust=(0))+
  scale_color_gradient(low = "#73BAD6", high = "#FCA311")+ 
  scale_fill_gradient(low = "#73BAD6", high = "#FCA311")+ 
  theme_bw()+ 
  labs(size="Count", fill=expression(-log[10](pvalue)), title="GO terms", x=expression(-log[10](pvalue)), y="")+
  theme(axis.text.x = element_text(face="bold"),
        axis.ticks = element_blank(),
        axis.text.y = element_blank())
p2
