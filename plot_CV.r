library(ggplot2)
a=read.table("all_cv_plot.txt",header=T)
a$K=factor(a$K, levels=c("2","3","4","5","6","7","8"))

ggplot(a,aes(x=K,y=admix))+  
geom_boxplot(outlier.shape = NA)+
geom_jitter(width = 0.2, alpha = 0.2) +
  labs(x="k",y = "cross-validation erro")+ 
  theme_minimal() + 
  theme(axis.text.y = element_text(face="bold"))+
  theme(axis.text.x = element_text(face="bold"))+
  theme(panel.border = element_rect(fill=NA,color="black", 
                                  linewidth=0.5, linetype ="solid"))
