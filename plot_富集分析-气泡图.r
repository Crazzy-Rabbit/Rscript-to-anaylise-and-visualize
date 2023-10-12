# GO气泡图
# BiocManager::install("openxlsx")

library(ggplot2)
library(openxlsx)

goinput <- read.xlsx("go.xlsx")
x=goinput$GeneRatio
y=factor(goinput$Description,levels = goinput$Description)

p = ggplot(goinput,aes(x,y))
p1 = p + geom_point(aes(size=Count,color=-0.5*log(pvalue),shape=ONTOLOGY,))+
  scale_color_gradient(low = "SpringGreen", high = "OrangeRed")
p2 = p1 + labs(color=expression(-log[10](pvalue)),
               size="Count", x="GeneRatio", y="Go_term",
               title="Go enrichment of test Genes")
p2




## KEGG气泡图
library(ggplot2)
library(openxlsx)

kegginput <- read.xlsx("kegg.xlsx")
x=kegginput$pvalue
y=factor(kegginput$Term,levels = kegginput$Term)

p = ggplot(kegginput,aes(x,y))
p1 = p + geom_point(aes(size=Count,color=-0.5*log(pvalue)))+
         scale_color_gradient(low = "BLUE", high = "OrangeRed")
p2 = p1 + labs(color=expression(-log[10](pvalue)),
               size="Count", x="P value", y="KEGG",
               title="KEGG pathway of Target Genes")
p2

